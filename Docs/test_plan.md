# Test Plan

## Prioritization rationale

- **Smoke (critical path):** tasks (create/complete/delete) and projects
  (create/rename/delete) are the operations every other Todoist feature
  builds on - if these break, the app is unusable and every other test
  area becomes hard to interpret. They run on every PR/push and must stay
  fast and green.
- **Regression:** labels & filters, sharing, and recurring tasks are
  important but secondary - they extend the core task/project model
  rather than replace it, and are more tolerant of being caught a few
  hours later on a PR (or overnight) than the smoke path.
- **known_defect:** reserved for tests that pin down a live, already-known
  bug with the *correct* expected behavior (never a weakened assertion).
  Excluded from the PR gate so a known issue never blocks a merge; run
  nightly with `--skiponfailure known_defect` so failures show as SKIP
  (visible in the report) instead of breaking the build. See
  `config/known_defects.yaml` for the registry and full convention.

## Coverage

| Funkční oblast     | Tagy                         | Stav       | Poznámka |
|--------------------|-------------------------------|------------|----------|
| Tasks (API)        | `api`, `tasks`                 | pokryto    | Create/read/update/complete/delete against a live-verified `/api/v1` endpoint. |
| Tasks (UI)         | `ui`, `tasks`                   | pokryto    | Create/complete/delete. **Known limitation** - see below. |
| Projects (API)     | `api`, `projects`               | pokryto    | Create/read/rename/delete. |
| Projects (UI)      | `ui`, `projects`                 | pokryto    | Create/rename/delete. **Known limitation** - see below. |
| Sections (API)      | `api`, `sections`                | částečně   | Only create + read covered; rename/reorder/delete are TODO (`tests/api/sections_api.robot`). |
| Labels & Filters (UI) | `ui`, `labels`, `filters`      | částečně   | Only single-label assignment covered; filter creation/query and multi-label scenarios are TODO (`tests/ui/labels_filters.robot`). **Known limitation** - see below. |
| Sharing (UI)       | `ui`, `sharing`                  | částečně   | Only the pending-invite state is covered with one account; accepted-collaboration and permission changes are TODO (`tests/ui/sharing.robot`). **Known limitation** - see below. |
| Recurring tasks (UI) | `ui`, `recurring`               | částečně   | Only creation of a recurring task is covered; completing it and verifying the next due date is TODO (`tests/ui/recurring_tasks.robot`). **Known limitation** - see below. |

## Known limitations

- **API base URL:** the original spec referenced `https://api.todoist.com/rest/v2`,
  which is deprecated and returns HTTP 410 Gone. The framework uses the
  current `https://api.todoist.com/api/v1` endpoint instead - verified
  live on 2026-08-28 (full create/rename/close/delete cycle for both
  projects and tasks). See `README.md` ("Where API lives") for details.
- **UI login/app-shell locators are unverified against a live account.**
  No `TODOIST_EMAIL` / `TODOIST_PASSWORD` were available while this
  framework was scaffolded (only an API token was provided), so the
  selectors in `tests/resources/locators/app_locators.robot` are
  best-effort, based on Todoist's publicly observable UI structure, not
  confirmed by an actual login/UI run. This affects every UI suite that
  depends on `Open Todoist App And Log In`:
  `tests/ui/tasks.robot`, `tests/ui/projects.robot`,
  `tests/ui/labels_filters.robot`, `tests/ui/sharing.robot`, and
  `tests/ui/recurring_tasks.robot`. Before relying on these suites,
  run them against a real test account and adjust the locators/flow as
  needed.
- **Sharing tests use a single account.** `tests/ui/sharing.robot` can
  only verify that an invite becomes "pending" - verifying acceptance
  requires a second, real collaborator account (see `Docs/BACKLOG.md`).
