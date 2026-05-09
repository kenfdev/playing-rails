# playing-rails

A learning-focused Rails 8.1 stack: Falcon + SQLite + Solid Queue + ViewComponent + Pundit + Sorbet, with Active Storage backed by SeaweedFS and OpenTelemetry traces flowing into Jaeger.

## Prerequisites

- Docker (Desktop or compatible)
- The [container-wt](https://github.com/kenfdev/container-wt) `wt` worktree CLI on `PATH`

Everything else (Ruby, Bundler, system libs) lives inside the per-worktree `app` container.

## One-time host setup

From the repo root, start the **shared infrastructure** containers (Traefik, SeaweedFS, OTel Collector, Jaeger):

```sh
docker compose up -d
```

These run independently of any worktree and are reused across branches.

## Per-worktree boot

Use the standard `wt` flow to materialize a worktree and bring up its `app` container. From inside the running `app` container:

```sh
bin/setup        # bundle install, db:prepare, ensure S3 bucket
bin/dev          # falcon (web) + tailwind --watch + bin/jobs (Solid Queue)
```

`bin/setup` is idempotent — re-run any time.

## URLs

| Surface | URL |
|---|---|
| App (this branch) | `http://<branch>.playing-rails.localhost` |
| Jaeger UI | `http://jaeger.playing-rails.localhost` |
| Traefik dashboard | `http://traefik.playing-rails.localhost` |

## Seeded accounts

`bin/rails db:seed` creates three accounts (idempotent). Defaults are gated by env vars so they can be overridden.

| Email | Role | Password env |
|---|---|---|
| `admin@example.com` | admin | `SEED_ADMIN_PASSWORD` (default `admin-password`) |
| `recruiter@example.com` | recruiter | `SEED_RECRUITER_PASSWORD` (default `recruiter-password`) |
| `member@example.com` | member | `SEED_MEMBER_PASSWORD` (default `member-password`) |

## Smoke test

1. Sign in as `admin@example.com`.
2. Land on `/admin/smoke` (the root path also points here).
3. Click **Enqueue smoke job** — the controller authorizes via Pundit, enqueues `SmokeJob`, and redirects.
4. Verify:
   - **Jaeger UI** shows a trace for `GET /admin/smoke` and a span for the `SmokeJob`.
   - The `web` process emits a single-line JSON log (Lograge) with a `trace_id` field.
   - The `jobs` process emits the `smoke_job` event line.
5. Sign out, sign in as `member@example.com`, hit `/admin/smoke` — expect HTTP 403.

## Verification commands

Inside the `app` container:

```sh
bin/rails db:migrate db:seed
bin/rails test
bundle exec srb tc
bundle exec rubocop
bundle exec brakeman --no-pager
```

All five must succeed on a clean checkout.
