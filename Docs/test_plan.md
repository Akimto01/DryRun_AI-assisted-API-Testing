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
- **UI login is behind Cloudflare Turnstile, so it is never automated.**
  Live diagnosis (2026-08-28, throwaway `diagnose_login.yml` run - since
  removed) confirmed the earlier "unchecked consent checkbox" theory was
  wrong: the page has zero `input[type="checkbox"]` elements, and
  `aria-describedby="agreement-footnote"` just points at a plain text
  disclaimer with Terms-of-Service/Privacy-Policy links, not an
  interactive element. The actual blocker is a hidden Cloudflare
  Turnstile widget (`#cf-turnstile`) whose `cf-turnstile-response` token
  stays empty against a headless, scripted browser - which is exactly
  what Turnstile is designed to detect and block, so no locator fix can
  unblock the submit button.
  - **Resolution:** UI tests don't automate the login form at all.
    `scripts/generate_storage_state.py` has a human complete the real
    login (including Turnstile) once, in a real, visible Chrome window,
    and saves the resulting Playwright session (`storageState.json`).
    `Open Todoist App With Saved Session`
    (`tests/resources/keywords/ui_keywords.resource`) loads that session
    via `New Context storageState=...` instead of filling in the login
    form, and explicitly verifies the session is still valid (sidebar
    container visible, no redirect to `/auth/login`) before continuing.
  - **Residual limitation:** the saved session isn't permanent - Todoist
    sessions last on the order of days to weeks. When it expires, every
    UI suite (`tests/ui/tasks.robot`, `tests/ui/projects.robot`,
    `tests/ui/labels_filters.robot`, `tests/ui/sharing.robot`,
    `tests/ui/recurring_tasks.robot`) fails immediately at Suite Setup
    with an explicit message naming the fix
    (`scripts/generate_storage_state.py` + update the
    `TODOIST_STORAGE_STATE_B64` GitHub Secret), rather than a confusing
    timeout. Automating that refresh was considered and deliberately
    deferred - see `Docs/BACKLOG.md` for the trade-off (it would need a
    workflow with permission to rewrite repository secrets, a
    meaningfully larger security surface, for a manual step that likely
    only recurs every few weeks).
  - **False-negative fix (2026-08-28):** `Verify Todoist Session Is Valid`
    originally waited for `[data-testid="task-list"]`, which only renders
    when the current view actually has tasks in it. Against a test
    account with an empty Inbox, that element never appears, so the
    keyword reported the same "session invalid" message even though the
    saved session was authenticating fine (confirmed via `Get Url`
    returning `https://app.todoist.com/app/`, not a redirect to
    `/auth/login`, and a failure screenshot showing the logged-in account
    and an empty-Inbox placeholder). Replaced with
    `[data-testid="app-sidebar-container"]`, the sidebar shell that
    renders right after login regardless of whether the current view has
    any content.
- **Sharing tests use a single account.** `tests/ui/sharing.robot` can
  only verify that an invite becomes "pending" - verifying acceptance
  requires a second, real collaborator account (see `Docs/BACKLOG.md`).
