# Tasks: Simplified LinkedIn-Style Profile Platform (Rails Learning POC)

Spec: [specs/20260509080947-profile-platform/spec.md](specs/20260509080947-profile-platform/spec.md)

Each task below is one PR-sized vertical slice. T001 establishes the cross-cutting foundation; later tasks build on it and may ship behind feature flags so the main branch stays green.

---

## T001 — Foundation and mandated stack baseline

- **User Story**: Architecture — supports: T002, T003, T004, T005, T006, T007, T008, T009, T010, T011, T012, T013
- **Spec**: [specs/20260509080947-profile-platform/spec.md#constraints](specs/20260509080947-profile-platform/spec.md#constraints)
- **Goal**: A clean checkout boots the entire learning stack — application server, database, object store, background jobs, and observability — through a single Docker Compose command, and a developer can reach a placeholder signed-in session. The role model, authorization scaffolding, view layer, typing, and test toolchain are wired up end-to-end so every later task plugs into established slots rather than inventing infrastructure.
- **Scope**:
  - In: a one-command local environment that runs the app, the database, the object store, and the background-job worker together
  - In: the role concept (member, recruiter, admin) materialized as a single shared model with one role per account
  - In: a baseline authorization layer applied to a placeholder action so role-gating has a working precedent
  - In: a baseline view-layer convention and a baseline interactive surface used by a smoke-test page
  - In: a working background-job pathway exercised by at least one trivial enqueued job
  - In: structured request logs and distributed traces flowing for every request
  - In: the static-typing toolchain installed and producing a clean baseline
  - In: the test toolchain installed with a passing smoke suite that demonstrates HTTP fixtures, database cleanup, and factories
  - In: seeded admin account(s) for local use; member self-sign-up and recruiter-invite flows themselves are deferred to T002 and T010
  - Out: any user-facing feature beyond the smoke-test page
  - Out: production hardening (rate limiting, abuse detection, dashboards, SLAs)
- **Dependencies**: depends_on: []
- **Acceptance signals**:
  - cloning the repo and running the documented one-shot command yields a reachable signed-in session as a seeded admin in under five minutes
  - logs and traces for the smoke-test request are visible through the configured observability tooling
  - the placeholder gated action is reachable to the admin role and rejected for other roles
  - the smoke-test job runs through the background worker rather than inline
  - the test suite, the type checker, and the linter all pass on a clean checkout
- **Size**: L

---

## T002 — Member self-registration and sign-in

- **User Story**: As a member, I want to self-register and sign in, so that I can manage my own professional profile.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A new visitor can create a member account, sign in, and sign out through the UI. The same authentication mechanism is used uniformly and is ready to be extended to recruiter and admin roles by later tasks.
- **Scope**:
  - In: a public sign-up flow that creates a member-role account
  - In: a sign-in and sign-out flow shared across all roles
  - In: session lifecycle that survives navigation and ends on sign-out
  - Out: recruiter self-registration (recruiters are invite-only — T010)
  - Out: admin self-creation (admins are seeded — handled in T001)
  - Out: deactivation enforcement at sign-in (T012)
  - Out: profile editing surfaces (T003)
- **Dependencies**: depends_on: [T001]
- **Acceptance signals**:
  - a brand-new visitor can sign up, land in a signed-in state, sign out, and sign back in
  - newly-created accounts are members and cannot reach recruiter- or admin-only views
  - recruiter and admin sign-in works through the same form using their existing credentials
- **Size**: M

---

## T003 — Member basic profile

- **User Story**: As a member, I want to maintain my basic profile (name, headline, bio, work history, education, skills), so that recruiters can evaluate me.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in member can create and edit every public field of their profile through the UI, including adding and removing work-history and education entries and managing a skill list. The profile updates persist and the most recent update is timestamped for later use by recruiter views.
- **Scope**:
  - In: edit surface for name, headline, short bio
  - In: add, edit, and remove work-history entries
  - In: add, edit, and remove education entries
  - In: add and remove skills
  - In: a "last updated" timestamp captured on every save
  - Out: salary fields (T004)
  - Out: file uploads (T005)
  - Out: viewing another member's profile (T007)
- **Dependencies**: depends_on: [T002]
- **Acceptance signals**:
  - a signed-in member can fill out every basic-profile field through the UI and see the saved values on a subsequent visit
  - editing any basic-profile field updates the visible last-update timestamp on that profile
  - basic-profile fields are reachable only to the profile owner; salary fields are not present on this surface
- **Size**: M

---

## T004 — Member salary information (private)

- **User Story**: As a member, I want to keep my salary information separate from my public profile, so that only authorized roles can see it.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in member can record and edit their current salary and expected salary range on a surface separated from their public profile. The data is stored as private and is invisible to other members; recruiter and admin visibility are enabled by later tasks.
- **Scope**:
  - In: edit surface for current salary
  - In: edit surface for expected salary range
  - In: persistence as a private, role-gated record
  - Out: recruiter-facing salary view (T009)
  - Out: admin full-record view of salary (T011)
  - Out: peer member viewing of salary (explicitly forbidden — verified in T007)
- **Dependencies**: depends_on: [T003]
- **Acceptance signals**:
  - a signed-in member can enter and update both current and expected-range salary values through the UI
  - the salary surface is unreachable to other members and to signed-out visitors
  - the public profile surface from T003 shows no salary information
- **Size**: S

---

## T005 — Member file uploads (resume and supporting documents)

- **User Story**: As a member, I want to upload a resume and a small number of supporting documents, so that recruiters have material to review.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in member can upload exactly one current resume and a bounded number of supporting documents through the UI. Files are stored in the object store rather than in the primary database, and per-file plus per-user size caps are enforced and surfaced clearly when exceeded.
- **Scope**:
  - In: a resume slot that holds at most one file at a time and accepts common document formats
  - In: a supporting-documents area with a bounded count
  - In: per-file and per-user total size enforcement with user-visible feedback when caps are hit
  - In: object-store-backed persistence rather than in-database blobs
  - Out: replacing or deleting files (T006)
  - Out: image uploads (out of scope per spec)
- **Dependencies**: depends_on: [T003]
- **Acceptance signals**:
  - a signed-in member can attach a resume and supporting documents through the UI and see them listed on their profile area
  - attempting to exceed per-file or per-user size limits is rejected with a clear message and no partial upload remains
  - uploaded files are retrievable for the owner and absent from public member-to-member views
- **Size**: M

---

## T006 — Member file replace and remove

- **User Story**: As a member, I want to replace or remove files I have uploaded, so that I stay in control of my own data.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in member can replace their current resume with a new one and delete any uploaded supporting document through the UI. The resume slot continues to hold at most one file after a replacement.
- **Scope**:
  - In: replace flow for the resume slot
  - In: delete flow for supporting documents
  - In: delete flow for the resume slot
  - Out: any change to upload limits or formats (covered by T005)
- **Dependencies**: depends_on: [T005]
- **Acceptance signals**:
  - replacing a resume leaves exactly one current resume in place and the previous version is no longer reachable to the owner
  - a member can remove an uploaded supporting document and it disappears from their listing
  - a removed or replaced file is no longer retrievable through any role's view
- **Size**: S

---

## T007 — Member view of peer profiles

- **User Story**: As a member, I want to view other members' public profiles, so that I can see how peers present themselves.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in member can navigate to another active member's public profile and see their basic-profile fields, with salary and other private data omitted. Deactivated members are not visible to peer members on this surface.
- **Scope**:
  - In: a peer-profile view scoped to active members and basic-profile fields only
  - In: explicit absence of salary and other private fields
  - Out: directory browsing or search (recruiter feature — T008)
  - Out: signed-out visibility (out of scope per spec)
- **Dependencies**: depends_on: [T003]
- **Acceptance signals**:
  - a signed-in member can open another active member's profile and see their basic-profile fields
  - salary, uploaded files, and other private fields are not present on the peer-profile view
  - a deactivated member's profile is not reachable to peer members from this surface
- **Size**: S

---

## T008 — Recruiter directory with search and filter

- **User Story**: As a recruiter, I want to browse and search/filter the member directory, so that I can find candidates that match a need.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in recruiter sees a directory listing of all members — including deactivated ones — and can narrow the list by skill, current or most-recent job title, and recency of last profile update. The directory is the entry point recruiters use to land on a member's detail view.
- **Scope**:
  - In: a directory listing visible only to the recruiter role
  - In: inclusion of deactivated members in the listing
  - In: filtering by skill
  - In: filtering by current or most-recent job title
  - In: filtering by recency of last profile update
  - In: a navigation path from a directory row to a recruiter-side member detail view
  - Out: recruiter-side salary view content (T009)
  - Out: bookmarks, shortlists, saved searches (out of scope per spec)
  - Out: extra filter dimensions beyond the baseline three (deferred per spec)
- **Dependencies**: depends_on: [T003]
- **Acceptance signals**:
  - a signed-in recruiter sees every member account, with deactivated members marked in some visible way
  - applying a skill, title, or last-update filter narrows the list to matches and clearing the filter restores the full list
  - a member-detail link in the directory opens a recruiter-side member view
  - non-recruiter roles cannot reach the directory
- **Size**: M

---

## T009 — Recruiter view of salary and last-update timestamp

- **User Story**: As a recruiter, I want to view a member's salary information and the timestamp of their last profile update, so that I can prioritize active and budget-fit candidates.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in recruiter on a member-detail view sees the member's basic profile, current salary, expected salary range, and the timestamp of the member's most recent profile update. No other role sees this combined surface.
- **Scope**:
  - In: a recruiter-side member-detail view that shows basic profile + current salary + expected salary range + last-update timestamp
  - In: server-enforced role gating so non-recruiter callers are rejected
  - Out: directory listing and filtering (T008)
  - Out: file downloads (recruiter file access is not in this slice; revisit if the spec requires it later)
- **Dependencies**: depends_on: [T004, T008]
- **Acceptance signals**:
  - a signed-in recruiter on a member-detail view sees the basic profile, both salary values, and the last-update timestamp on a single page
  - a member or signed-out visitor reaching the same URL is rejected and sees no salary data
  - the last-update timestamp matches the most recent change made by that member
- **Size**: S

---

## T010 — Admin invitation flow for recruiter accounts

- **User Story**: As an admin, I want to invite recruiter accounts, so that recruiter access stays controlled.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in admin can issue an invitation that lets a specific person create exactly one recruiter account through a one-time acceptance flow. Recruiter self-registration remains impossible.
- **Scope**:
  - In: an admin-only invitation surface that records the intended recipient
  - In: a one-time invitation acceptance flow that provisions a recruiter-role account
  - In: a delivery mechanism sufficient for local use (the spec allows minimal notification)
  - In: an asynchronous send path (running through the background-job system)
  - Out: invitation revocation, expiry tuning, resend flows (not required by the spec)
  - Out: member or admin invitations (members self-register; admins are seeded)
- **Dependencies**: depends_on: [T002]
- **Acceptance signals**:
  - a signed-in admin can issue an invitation that an unauthenticated visitor can accept once to land on a signed-in recruiter session
  - an accepted invitation cannot be reused
  - a non-admin cannot reach the invitation surface and cannot self-register as a recruiter
  - the invitation send is dispatched through the background-job worker rather than inline
- **Size**: M

---

## T011 — Admin full-record view

- **User Story**: As an admin, I want to view every user's full record including private fields and files, so that I can audit and support the platform.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in admin can open any user's complete record and see basic profile, salary fields, uploaded files (with retrieval), role, and active/inactive status on a single audit-oriented surface.
- **Scope**:
  - In: an admin-only full-record view for any user
  - In: presence of every private field and uploaded-file reference, with download access for the admin
  - Out: editing of another user's data (not requested)
  - Out: deactivate/reactivate controls (T012)
- **Dependencies**: depends_on: [T003, T004, T005]
- **Acceptance signals**:
  - a signed-in admin can open any user and see basic profile, salary fields, and uploaded files on a single page
  - the admin can retrieve the actual file contents from this view
  - non-admin roles cannot reach this surface
- **Size**: S

---

## T012 — Admin deactivate and reactivate member

- **User Story**: As an admin, I want to deactivate and later reactivate a member, so that I can stop bad actors from signing in while their profile remains discoverable to recruiters.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in admin can flip any member between active and inactive states. A deactivated member cannot sign in or edit their profile, but their profile remains visible to recruiters in the directory and on detail views. Reactivation fully restores self-service.
- **Scope**:
  - In: an admin control to deactivate and reactivate a specific member
  - In: enforcement at sign-in so deactivated members cannot establish a session
  - In: enforcement on edit surfaces so a member who somehow has an existing session cannot mutate their profile while deactivated
  - In: continued recruiter-side visibility of deactivated members in directory and detail views
  - Out: hard deletion (out of scope per spec)
  - Out: peer-member visibility of deactivated members (covered by T007's active-only rule)
- **Dependencies**: depends_on: [T002, T008]
- **Acceptance signals**:
  - an admin can deactivate a member and that member's next sign-in attempt is rejected
  - a deactivated member's profile still appears in the recruiter directory and on the recruiter-side detail view
  - an admin can reactivate the same member and the member can sign in and edit their profile again
  - a peer member cannot reach a deactivated member's profile
- **Size**: M

---

## T013 — Admin user list with role and status

- **User Story**: As an admin, I want to see a list of all users with their role and status, so that I can find any account quickly.
- **Spec**: [specs/20260509080947-profile-platform/spec.md#user-stories](specs/20260509080947-profile-platform/spec.md#user-stories)
- **Goal**: A signed-in admin sees a single listing of every user account in the system together with each account's role and active/inactive status, with enough navigation to reach the deactivate/reactivate controls and the full-record view.
- **Scope**:
  - In: an admin-only listing of every account regardless of role or status
  - In: visible role and active/inactive status on each row
  - In: navigation from a row to the admin full-record view and to the deactivate/reactivate control
  - Out: editing user fields from this listing
  - Out: advanced filters; the spec only requires findability
- **Dependencies**: depends_on: [T011, T012]
- **Acceptance signals**:
  - a signed-in admin sees every member, recruiter, and admin account on one listing with role and status visible
  - the admin can navigate from any row to that user's full record and to the deactivate/reactivate control
  - non-admin roles cannot reach the listing
- **Size**: S
