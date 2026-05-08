# Spec: Simplified LinkedIn-Style Profile Platform (Rails Learning POC)

## Overview

A small, locally-runnable web application that lets professionals maintain a public profile and lets recruiters discover and review them. The product exists primarily as a learning vehicle: it gives an experienced TypeScript developer an opportunity to exercise a complete, mandated Rails 8 stack end-to-end. Functionally it is a deliberately stripped-down LinkedIn — profiles, file uploads, and role-segregated visibility, with no social graph, feed, or messaging.

**Target users**: member, recruiter, admin.

## User Stories

- As a member, I want to self-register and sign in, so that I can manage my own professional profile.
- As a member, I want to maintain my basic profile (name, headline, bio, work history, education, skills), so that recruiters can evaluate me.
- As a member, I want to keep my salary information separate from my public profile, so that only authorized roles can see it.
- As a member, I want to upload a resume and a small number of supporting documents, so that recruiters have material to review.
- As a member, I want to replace or remove files I have uploaded, so that I stay in control of my own data.
- As a member, I want to view other members' public profiles, so that I can see how peers present themselves.
- As a recruiter, I want to browse and search/filter the member directory, so that I can find candidates that match a need.
- As a recruiter, I want to view a member's salary information and the timestamp of their last profile update, so that I can prioritize active and budget-fit candidates.
- As an admin, I want to invite recruiter accounts, so that recruiter access stays controlled.
- As an admin, I want to view every user's full record including private fields and files, so that I can audit and support the platform.
- As an admin, I want to deactivate and later reactivate a member, so that I can stop bad actors from signing in while their profile remains discoverable to recruiters.
- As an admin, I want to see a list of all users with their role and status, so that I can find any account quickly.

## Functional Requirements

- Member self-registration with sign-in and sign-out.
- Admin-only invitation flow that issues recruiter accounts; recruiters cannot self-register.
- Admin accounts are seeded for the local environment and cannot be self-created.
- Every account has exactly one role: member, recruiter, or admin.
- Members can create and edit their own basic profile, covering: name, headline, short bio, work history entries, education entries, and a skills list.
- Members can record private salary information consisting of current salary and expected salary range.
- Members can upload exactly one current resume in common document formats and replace it at any time.
- Members can upload a bounded number of additional supporting documents, subject to per-file and per-user total size caps.
- Members can delete any file they have uploaded.
- Members can view any active member's basic profile, but never another member's salary information or other private fields.
- Recruiters can view any member's basic profile, current and expected salary, and the timestamp of the member's most recent profile update.
- Recruiters can browse a directory listing all members, including deactivated ones.
- Recruiters can search and filter the directory by at least skill, current/most-recent job title, and recency of last update.
- Admins can view every user's complete record, including private fields and uploaded files.
- Admins can deactivate a member: a deactivated member cannot sign in or edit their profile, but recruiters continue to see that member's profile in the directory and on detail views.
- Admins can reactivate a previously deactivated member, restoring full self-service.
- Admins can list every user in the system together with role and active/inactive status.
- Authorization is enforced server-side on every action; role-restricted information is never delivered to a viewer who lacks the matching role.
- Uploaded files are stored in an object store rather than embedded in the primary database.
- Long-running or post-action work runs asynchronously in a background job system without blocking user-facing requests.
- The application emits structured logs and distributed traces for every request so that the learning stack's observability tools can be exercised against real traffic.

## Success Metrics

- Every functional requirement above is reachable through the user interface in a single locally-running environment with no external cloud dependencies.
- Each technology in the mandated learning stack is exercised on at least one production code path the user actually traverses, not only in scaffolding or examples.
- A new member can sign up and publish a complete basic profile in under 5 minutes.
- A recruiter can locate a candidate via search or filter and open their salary view in under 30 seconds.
- An admin can find any user and toggle their active state in under 30 seconds.
- Automated authorization tests find no path where a member sees another member's salary, a recruiter sees admin-only data, or a deactivated member completes a sign-in.
- The full system starts from a clean checkout to a usable signed-in session in under 5 minutes on a developer laptop.

## Out of Scope

- Posts, feed, comments, likes, or any social content stream.
- Connections, follow/follower graph, or any networking features.
- In-app messaging or chat between any roles.
- Recruiter bookmarks, shortlists, or saved searches.
- Public profile pages visible to logged-out visitors.
- Email or push notifications beyond what the recruiter-invitation flow strictly needs.
- Image uploads, including profile photos and portfolio images.
- Multi-tenant or organization accounts; recruiters act as individuals.
- Resume parsing, candidate scoring, or AI-driven matching.
- Hard deletion of users; the only lifecycle is deactivate / reactivate.
- Native mobile apps; the POC is a responsive web application only.
- Production-grade hardening: rate limiting, abuse detection, advanced observability dashboards, and SLAs.

## Constraints

- The project's primary purpose is to teach a specific Rails-centred stack, so the technology choices are themselves hard requirements rather than implementation freedoms. The mandated stack: Rails 8, Solid Queue (background jobs), Sorbet with Tapioca (static typing), Hotwire (frontend interactivity), ViewComponent, Pundit (authorization policies), Minitest (tests), FactoryBot (test data), VCR + WebMock (HTTP fixtures), Database Cleaner, OpenTelemetry (traces), SQLite (database), Lograge (logs), Falcon (application server), and an S3-compatible object store such as SeaWeedFS.
- The full system, including database, object store, and any supporting services, must run locally via a single Docker Compose invocation with no external cloud dependencies.
- Authentication uses a single mandated approach applied uniformly to all three roles.
- Per-file and per-user file-size limits must be enforced, but exact thresholds are tuned during implementation rather than fixed up front.
- Deferred: the exact authentication library choice (the input names "passport" but a Rails-native equivalent may be substituted at implementation time as long as the role model is preserved).
- Deferred: precise file-size and per-user file-count caps; sensible POC defaults are acceptable until real usage data exists.
- Deferred: directory search and filter dimensions beyond the baseline (skill, title, last-update recency) can be expanded after the first usable build.
