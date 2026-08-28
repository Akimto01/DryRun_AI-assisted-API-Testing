# Todoist Test Framework

A practice/demo test automation framework for the Todoist web app,
inspired by the TestDesignHelper project (Robot Framework + Browser
Library, GitHub Actions CI).

## Framework Overview

### Stack and language
- [Robot Framework](https://robotframework.org/) (Python) as the test runner
- [Browser Library](https://robotframework-browser.org/) (Playwright) for UI tests
- [RequestsLibrary](https://github.com/MarketSquare/robotframework-requests) for API tests
- Python 3.11+, GitHub Actions for CI

### Where API lives
- REST API: `https://api.todoist.com/api/v1`
- Web UI target: `https://todoist.com` / `https://app.todoist.com`
- Both are defined as variables in `config/variables.robot`

> **Why `/api/v1` and not `/rest/v2`?** The original design targeted
> `https://api.todoist.com/rest/v2`, but that endpoint has been sunset by
> Todoist and now returns `HTTP 410 Gone`. This framework was built
> against the current `https://api.todoist.com/api/v1` endpoint instead,
> verified live with a real account on 2026-08-28 (full
> create → rename → close → delete cycle for both projects and tasks).
> Note the response shape differs slightly from the old v2 API: list
> endpoints (e.g. `GET /projects`) return a `{"results": [...], "next_cursor": ...}`
> envelope rather than a bare array, and updates go through
> `POST /projects/{id}` / `POST /tasks/{id}` rather than PATCH/PUT. Also
> note the asymmetry between resources: deleting a **project** is a hard
> delete (`GET` on it afterwards 404s), but deleting a **task** is a
> *soft* delete (`GET` still returns 200 with `is_deleted: true`) - both
> verified live. `tests/api/tasks_api.robot` asserts on `is_deleted`
> rather than a 404 for this reason.

### Which use cases are critical
- **Smoke (critical path):** tasks (create/complete/delete), projects
  (create/rename/delete)
- **Regression:** labels & filters, sharing, recurring tasks
- See `Docs/test_plan.md` for the full coverage table and the reasoning
  behind this prioritization.

### How credentials are handled
- API token and login credentials are **only** ever read from environment
  variables: `TODOIST_API_TOKEN`, and optionally `TODOIST_EMAIL` /
  `TODOIST_PASSWORD` (needed for UI tests) and `TODOIST_SHARE_TEST_EMAIL`
  (used by the sharing UI test).
- Locally: set them as environment variables or via your OS credential
  manager - never commit real values. `config/credentials.template`
  documents the full list with empty placeholders.
- In CI: supplied as GitHub Secrets (see `.github/workflows/`).

### When tests run
- **PR/push gate** (`.github/workflows/pr_gate.yml`): `smoke` +
  `regression`, excluding `known_defect`, on `ubuntu-latest`.
- **Nightly** (`.github/workflows/nightly.yml`, cron `0 2 * * *` UTC): the
  full suite, including `known_defect` tests (run with
  `--skiponfailure known_defect` so they report as SKIP rather than FAIL).
- **Manual** (`workflow_dispatch`, available on **both** workflows): each
  takes an optional comma-separated `include_tags` input to run a
  specific subset. On `pr_gate.yml` it defaults to `smoke,regression`
  (matching its normal PR/push behavior) and `known_defect` is always
  excluded regardless of what's selected; on `nightly.yml` it defaults to
  running everything (including `known_defect`, reported as SKIP on
  failure).

### How results are presented
- `log.html` and `report.html` (plus `output.xml`) are uploaded as CI
  artifacts on every run (`results/` locally).
- The nightly workflow has a placeholder step for emailing a summary via
  [Resend](https://resend.com) - not yet implemented, see `Docs/BACKLOG.md`.
- `Docs/test_plan.md` tracks coverage as a table: functional area → tags
  → status (pokryto / částečně / TODO).

## Known limitations

See `Docs/test_plan.md` → "Known limitations" for the full list. The
main one: **UI login fails on a disabled submit button, not on missing
credentials.** `TODOIST_EMAIL`/`TODOIST_PASSWORD` are configured as
GitHub Secrets and `pr_gate.yml` has run live against them (2026-08-28,
runs `33159448692` and `33159854560`) - see `Docs/test_plan.md` for the
exact failure and root-cause hypothesis before you trust the UI suites.

## Project structure

```
.
├── tests/
│   ├── ui/                    # Browser Library UI tests
│   ├── api/                   # RequestsLibrary API tests
│   └── resources/
│       ├── keywords/          # Shared keywords (API helpers, test-data lifecycle, UI helpers)
│       ├── locators/          # UI selectors
│       └── test_data/         # Sample YAML test data
├── libraries/                 # Small custom Python library (e.g. unique-name generation)
├── config/
│   ├── variables.robot        # API/UI base URLs, credentials (from env), Browser settings
│   ├── credentials.template   # Documents required env vars - no real values
│   └── known_defects.yaml     # known_defect registry
├── .github/workflows/
│   ├── pr_gate.yml
│   └── nightly.yml
├── run-tests.ps1               # Entry point
├── requirements.txt
└── Docs/
    ├── CHANGELOG.md
    ├── BACKLOG.md
    └── test_plan.md
```

## Setup

1. Install Python 3.11+.
2. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   rfbrowser init
   ```
3. Copy `config/credentials.template` and set the environment variables it
   lists (at minimum `TODOIST_API_TOKEN` for API tests; also
   `TODOIST_EMAIL` / `TODOIST_PASSWORD` for UI tests).

## Running locally

```powershell
# Everything
./run-tests.ps1

# Only API tests
./run-tests.ps1 -Suite api

# Only UI tests
./run-tests.ps1 -Suite ui

# Only smoke tests, excluding known defects
./run-tests.ps1 -Include smoke -Exclude known_defect

# Include known_defect tests but don't fail the build on them
./run-tests.ps1 -ExtraArgs '--skiponfailure','known_defect'
```

Results (`log.html`, `report.html`, `output.xml`) are written to
`results/` by default (`-ResultsDir` to change it).

## Running in CI

Pushes/PRs trigger `pr_gate.yml` automatically (smoke + regression).
`nightly.yml` runs on its own schedule, or on demand via the "Run
workflow" button in the Actions tab. Both require `TODOIST_API_TOKEN`,
`TODOIST_EMAIL`, `TODOIST_PASSWORD`, and (optionally)
`TODOIST_SHARE_TEST_EMAIL` to be configured as repository/organization
GitHub Secrets.

## Known defects registry

`config/known_defects.yaml` tracks live, already-known bugs. A test that
guards one is tagged `known_defect` plus the defect id (e.g.
`known_defect`, `TODOIST-1`) and always asserts the **correct**,
spec-conformant behavior - never a weakened version of it. Run with
`--skiponfailure known_defect` (as the nightly workflow does) to have
such a test report as SKIP instead of FAIL: the defect stays visible in
`report.html` without breaking the build. See the comments at the top of
`config/known_defects.yaml` for the full convention, including what to do
when a known_defect test unexpectedly turns green.
