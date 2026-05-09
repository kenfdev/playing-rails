# Plan: T001 — Foundation and mandated stack baseline

Spec: [spec.md](spec.md)
Task: [tasks.md#t001--foundation-and-mandated-stack-baseline](tasks.md)

This plan implements T001 end-to-end. It captures every decision already made with the user, so the implementing agent does **not** need to re-ask them.

## Decisions (already made — do not re-ask)

| Topic | Decision |
|---|---|
| Application server | Replace Puma with **Falcon**. |
| S3-compatible object store | **SeaweedFS** (the spec names it explicitly). Lives in the root `docker-compose.yml`. |
| Compose model | Shared infra (SeaweedFS, OTel Collector, Jaeger, Traefik) in the **root** `docker-compose.yml`. The per-worktree `app` container in `.worktree/docker-compose.yml` runs the Rails web process **and** the Solid Queue worker as parallel processes via `Procfile.dev` + `bin/dev`. No separate worker container per worktree. |
| Trace backend | OTel Collector → Jaeger UI. App exports OTLP to the collector; collector forwards to Jaeger. |
| Auth library | **Keep the Rails 8 built-in auth generator** that's already in the repo (`User`, `Session`, `Authentication` concern, `SessionsController`, `PasswordsController`). Do not introduce Devise/Rodauth. T001 only **adds** a `role` column to `users` and an `Authorization` concern wired to Pundit. |
| Sorbet strictness | All app files start at `# typed: false`. Tapioca generates gem + DSL RBIs. `srb tc` must pass on the baseline. Per-file upgrades come in later tasks. |
| Smoke surface | A single admin-only page at `GET /admin/smoke` that exercises Pundit + ViewComponent + Hotwire + an enqueued Solid Queue job in one place. |
| Test toolchain | Minitest (already in place) + FactoryBot + VCR + WebMock + Database Cleaner. |
| Logging | Lograge with structured (JSON) output in production-like envs; Rails default in development is fine if Lograge is configured behind an env flag. The smoke request should produce a structured log line. |

## Acceptance signals (from tasks.md — must hold at the end)

1. Cloning the repo and running the documented one-shot command yields a reachable signed-in session as a seeded admin in under five minutes.
2. Logs and traces for the smoke-test request are visible through the configured observability tooling (Jaeger UI shows the trace; the structured log line appears).
3. The placeholder gated action is reachable to the admin role and rejected for other roles.
4. The smoke-test job runs through the background worker rather than inline.
5. The test suite, the type checker, and the linter all pass on a clean checkout.

## What's already in the repo (do not redo)

- Rails 8.1.3 on Ruby 3.3.10 (`.ruby-version`).
- Rails 8 auth generator output: `app/models/user.rb`, `app/models/session.rb`, `app/models/current.rb`, `app/controllers/sessions_controller.rb`, `app/controllers/passwords_controller.rb`, `app/controllers/concerns/authentication.rb` (assumed — verify), routes for `resource :session` and `resources :passwords`.
- Migrations for `users` and `sessions` tables.
- Solid Queue / Cache / Cable gems present in the Gemfile (worker process not yet wired into Procfile).
- Hotwire (turbo-rails, stimulus-rails), Importmap, Tailwind, Propshaft.
- Capybara + Selenium for system tests.
- Two-tier compose: root `docker-compose.yml` (Traefik on `devnet-playing-rails`); per-worktree `.worktree/docker-compose.yml` brings up the `app` dev container.
- `Procfile.dev` currently has only `web: bin/rails server` and `css: bin/rails tailwindcss:watch`.

## Execution order

Sub-steps are sequenced so the tree stays bootable between commits where possible. Track each as a sub-task.

### 1. Gemfile changes

Add (default group unless noted):

```ruby
# Application server (replaces puma)
gem "falcon"

# Authorization
gem "pundit"

# View layer
gem "view_component"

# Static typing
gem "sorbet-static-and-runtime"
gem "tapioca", require: false, group: :development

# Logs and traces
gem "lograge"
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"

# Object store (Active Storage S3 adapter)
gem "aws-sdk-s3", require: false
```

In `group :development, :test`:

```ruby
gem "factory_bot_rails"
gem "vcr"
gem "webmock"
gem "database_cleaner-active_record"
```

Remove: `gem "puma"`. Falcon replaces it.

Run: `bundle install` (inside the `app` container).

### 2. Falcon as the dev web server

Update `Procfile.dev`:

```
web: bundle exec falcon serve --bind http://0.0.0.0:3000
css: bin/rails tailwindcss:watch
jobs: bin/jobs
```

Verify `bin/dev` exists and uses `foreman start -f Procfile.dev` (Rails 8 default). If `bin/jobs` is missing, run `bin/rails solid_queue:install` (if not yet) — Rails 8.1 typically already wires this.

Make sure `traefik`'s `loadbalancer.server.port=3000` in `.worktree/docker-compose.yml` still matches Falcon's bind port (it does — leave 3000).

### 3. Add `role` to `User` and seed an admin

New migration `db/migrate/<ts>_add_role_and_active_to_users.rb`:

```ruby
class AddRoleAndActiveToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :active, :boolean, null: false, default: true
    add_index :users, :role
  end
end
```

> Rationale for adding `active` here even though deactivation is T012: it keeps a single migration touching `users` for foundation-level columns, and T012's logic just toggles + enforces. This is acceptable foundation work.

Update `app/models/user.rb`:

```ruby
class User < ApplicationRecord
  enum :role, { member: 0, recruiter: 1, admin: 2 }

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
```

`db/seeds.rb` — seed an admin and at least one member + one recruiter so the smoke flows are usable:

```ruby
User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password = ENV.fetch("SEED_ADMIN_PASSWORD", "admin-password")
  u.role = :admin
end
# (member + recruiter optional but recommended for later tasks)
```

`bin/rails db:migrate db:seed`.

### 4. Pundit baseline

`bin/rails g pundit:install` → creates `app/policies/application_policy.rb`.

Add an `Authorization` concern at `app/controllers/concerns/authorization.rb`:

```ruby
module Authorization
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :forbidden
  end

  private

  def forbidden
    render plain: "Forbidden", status: :forbidden
  end

  def pundit_user
    Current.user
  end
end
```

Include it in `ApplicationController`. Verify `Current.user` is the right binding (the Rails 8 auth generator ships with `Current` — confirm and adapt if the binding name differs).

### 5. ViewComponent baseline

`bin/rails g view_component:install` (or hand-create `lib/component_preview.rb` and add to autoload paths). Confirm by generating the smoke component in step 9 and rendering it.

### 6. Lograge

`config/initializers/lograge.rb`:

```ruby
Rails.application.configure do
  config.lograge.enabled = ENV["LOGRAGE_ENABLED"] != "false"
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    { time: event.time, params: event.payload[:params]&.except("controller", "action"), trace_id: OpenTelemetry::Trace.current_span&.context&.hex_trace_id }
  end
end
```

Enable in development too (the spec wants observability exercised against real traffic).

### 7. OpenTelemetry

`config/initializers/opentelemetry.rb`:

```ruby
require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = ENV.fetch("OTEL_SERVICE_NAME", "playing-rails")
  c.use_all
end
```

Set the OTLP endpoint via env in `.worktree/.env.app` (the `app` container's env file):

```
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
OTEL_SERVICE_NAME=playing-rails
```

Falcon is fiber-based — confirm `opentelemetry-instrumentation-rack` (pulled in by `instrumentation-all`) reports cleanly under Falcon. If a span doesn't appear in Jaeger after the smoke request, check that `Rack` and `ActionPack` instrumentations are enabled and that the OTLP HTTP endpoint is reachable from the `app` container (they share `devnet`).

### 8. Active Storage backed by SeaweedFS

`config/storage.yml` — add a `seaweed` service:

```yaml
seaweed:
  service: S3
  endpoint: <%= ENV.fetch("S3_ENDPOINT", "http://seaweedfs:8333") %>
  access_key_id: <%= ENV.fetch("S3_ACCESS_KEY_ID", "any") %>
  secret_access_key: <%= ENV.fetch("S3_SECRET_ACCESS_KEY", "any") %>
  region: <%= ENV.fetch("S3_REGION", "us-east-1") %>
  bucket: <%= ENV.fetch("S3_BUCKET", "playing-rails-#{ENV['BRANCH_NAME'] || 'main'}") %>
  force_path_style: true
```

`config/environments/development.rb` and `production.rb`:

```ruby
config.active_storage.service = :seaweed
```

Bucket creation: SeaweedFS's S3 gateway auto-creates buckets on first PUT for most clients, but `aws-sdk-s3` does not. Add a small idempotent bucket-ensure step. Two acceptable shapes:

1. A Rails initializer that calls `S3::Client#create_bucket` on boot (rescue `BucketAlreadyOwnedByYou`).
2. A rake task `storage:ensure_bucket` invoked from `bin/docker-entrypoint` or from the `app` container's startup.

Pick (2) — initializers running side-effects on boot is a smell. Wire it into the container start path so the bucket exists before Active Storage is exercised.

### 9. Smoke page (`GET /admin/smoke`)

Routes (`config/routes.rb`):

```ruby
namespace :admin do
  get  "smoke", to: "smoke#show"
  post "smoke/enqueue", to: "smoke#enqueue"
end
root "admin/smoke#show" # acceptable for T001; can move later
```

Controller `app/controllers/admin/smoke_controller.rb`:

```ruby
class Admin::SmokeController < ApplicationController
  before_action :require_authentication
  def show
    authorize :smoke, :show?
  end
  def enqueue
    authorize :smoke, :enqueue?
    SmokeJob.perform_later(Current.user.id)
    redirect_to admin_smoke_path, notice: "Job enqueued"
  end
end
```

Policy `app/policies/smoke_policy.rb`:

```ruby
class SmokePolicy < ApplicationPolicy
  def show?    = user&.admin?
  def enqueue? = user&.admin?
end
```

ViewComponent `app/components/smoke_card_component.rb` + ERB sibling rendering: who you're signed in as, the role, a Turbo Frame `id="smoke-status"` with an initial state, a button that POSTs to `/admin/smoke/enqueue`.

Job `app/jobs/smoke_job.rb`:

```ruby
class SmokeJob < ApplicationJob
  queue_as :default
  def perform(user_id)
    Rails.logger.info({ event: "smoke_job", user_id: user_id }.to_json)
    OpenTelemetry::Trace.current_span&.add_event("smoke_job_ran")
  end
end
```

Confirm the controller include chain: `ApplicationController` includes `Authentication` (for `require_authentication` / `Current.user`) and `Authorization` (for Pundit + the `pundit_user` binding to `Current.user`).

### 10. Sorbet + Tapioca

```
bundle exec tapioca init
bundle exec tapioca gems
bundle exec tapioca dsl
bundle exec srb tc
```

Add `# typed: false` magic comments to all existing app files (Tapioca's init does this for new files; existing files may need a sweep). `srb tc` must pass.

### 11. Test toolchain

`test/test_helper.rb` — add:

```ruby
require "factory_bot_rails"
require "webmock/minitest"
require "vcr"
require "database_cleaner/active_record"

VCR.configure do |c|
  c.cassette_library_dir = "test/vcr_cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata! rescue nil
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup    { DatabaseCleaner.strategy = :transaction; DatabaseCleaner.start }
  teardown { DatabaseCleaner.clean }
end
```

`test/factories/users.rb` — basic factory covering all three roles.

Smoke tests:

- `test/controllers/admin/smoke_controller_test.rb` — admin signs in and sees 200; member and recruiter see 403; unauthenticated visitor redirects to sign-in.
- `test/jobs/smoke_job_test.rb` — `assert_enqueued_with` from a controller post; `perform_later` actually exercises the job runner in a separate test.
- A trivial VCR + WebMock sanity test (e.g. stub a `GET https://example.com` and confirm the cassette path).

`bin/rails test` must be green.

### 12. Root `docker-compose.yml` — add infra

Add three services to the existing root compose alongside `traefik`:

```yaml
  seaweedfs:
    image: chrislusf/seaweedfs:latest
    container_name: "seaweedfs-${PROJECT_NAME:-playing-rails}"
    command: server -s3 -dir=/data
    ports:
      - "${SEAWEED_S3_PORT:-8333}:8333"   # S3 API
      - "${SEAWEED_FILER_PORT:-8888}:8888"
      - "${SEAWEED_MASTER_PORT:-9333}:9333"
    volumes:
      - seaweed-data:/data
    networks: [devnet]
    restart: unless-stopped

  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    container_name: "otel-collector-${PROJECT_NAME:-playing-rails}"
    command: ["--config=/etc/otelcol/config.yaml"]
    volumes:
      - ./config/otel-collector.yaml:/etc/otelcol/config.yaml:ro
    networks: [devnet]
    restart: unless-stopped

  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: "jaeger-${PROJECT_NAME:-playing-rails}"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
    ports:
      - "${JAEGER_UI_PORT:-16686}:16686"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.jaeger.rule=Host(`jaeger.${PROJECT_NAME:-playing-rails}.localhost`)"
      - "traefik.http.routers.jaeger.entrypoints=web"
      - "traefik.http.services.jaeger.loadbalancer.server.port=16686"
    networks: [devnet]
    restart: unless-stopped

volumes:
  seaweed-data:
    name: "${PROJECT_NAME:-playing-rails}-seaweed"
```

Create `config/otel-collector.yaml` (project root or wherever the compose mount points — keep the path consistent with the compose file above):

```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:
exporters:
  otlp/jaeger:
    endpoint: jaeger:4317
    tls:
      insecure: true
service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [otlp/jaeger]
```

### 13. README — document the one-command boot

Replace the placeholder `README.md` with concrete steps:

1. Pre-reqs: Docker Desktop, `wt` (worktrunk).
2. From the repo root: `docker compose up -d` to start shared infra (Traefik, SeaweedFS, OTel Collector, Jaeger).
3. Standard worktree creation flow brings up the per-worktree `app` container; run `bin/setup` inside it.
4. Inside the `app` container: `bin/dev` runs Falcon + Tailwind + Solid Queue worker.
5. URLs:
   - App: `http://<branch>.playing-rails.localhost`
   - Jaeger: `http://jaeger.playing-rails.localhost`
   - Traefik dashboard: `http://traefik.playing-rails.localhost`
6. Default seeded admin: `admin@example.com` / `$SEED_ADMIN_PASSWORD` (default `admin-password`).
7. Acceptance walk-through: sign in as admin, hit `/admin/smoke`, click the button, refresh — Turbo Frame state changes; Jaeger UI shows a trace for the request and the job; structured log line appears in the app process output.

### 14. Verification pass

Run, all from inside the `app` container:

- `bin/rails db:migrate db:seed`
- `bin/rails test`
- `bundle exec rubocop`
- `bundle exec srb tc`
- `bundle exec brakeman --no-pager` (optional but quick win)
- Manually: sign in as admin, visit `/admin/smoke`, click "Enqueue", verify (a) Turbo Frame state, (b) Jaeger trace, (c) Lograge JSON line in the `web` log, (d) `jobs` log line for `SmokeJob`.
- Sign in as a member: `/admin/smoke` returns 403.

## Out of scope for T001 (do not pull forward)

- Member basic profile model and edit screens (T003).
- Salary model (T004).
- File-upload UI for resumes / supporting docs (T005). Active Storage **plumbing** to SeaweedFS is in scope; the user-facing upload feature is not.
- Recruiter directory (T008), recruiter detail view (T009).
- Admin invite flow, full-record view, deactivate/reactivate, user list (T010–T013).
- Production hardening (rate limiting, dashboards, SLAs).

## Risk notes

- **Falcon + OpenTelemetry**: Falcon's fiber-per-request model has historically tripped some OTel rack instrumentation. If a smoke request produces no Jaeger trace, first verify reachability (`curl http://otel-collector:4318` from inside `app`), then check that the rack instrumentation isn't disabled by a fiber-context issue.
- **SeaweedFS S3 + aws-sdk-s3**: needs `force_path_style: true` and explicit `region`. Bucket auto-create is not guaranteed; use the rake task approach above.
- **Sorbet on a fresh codebase**: `tapioca dsl` may complain about gems with unusual loaders. Pin versions if needed and add `sorbet/tapioca/config.yml` with `--exclude` for noisy gems rather than upgrading strictness.
- **Pundit + the `Current.user` binding**: the Rails 8 generator stores the current user on `Current`. Make sure `pundit_user` returns it; otherwise policies receive `nil` and look broken.

## When done

Single short summary line of the form: `T001 done — admin can sign in, /admin/smoke gated, smoke job traced and logged via Jaeger + Lograge, srb/rubocop/tests green.`
