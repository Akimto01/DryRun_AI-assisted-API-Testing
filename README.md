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
  variables: `TODOIST_API_TOKEN`, `TODOIST_SHARE_TEST_EMAIL` (used by the
  sharing UI test), and `TODOIST_EMAIL` / `TODOIST_PASSWORD`.
- Locally: set them as environment variables or via your OS credential
  manager - never commit real values. `config/credentials.template`
  documents the full list with empty placeholders.
- In CI: supplied as GitHub Secrets (see `.github/workflows/`).
- **`TODOIST_EMAIL`/`TODOIST_PASSWORD` are kept as GitHub Secrets but are
  NOT wired into either CI workflow.** Todoist's login form is behind
  Cloudflare Turnstile, which blocks scripted logins (see
  `Docs/test_plan.md` → "Known limitations" for the diagnosis), so UI
  tests never automate the login form. These two variables only matter
  locally, as input to `scripts/generate_storage_state.py` (see below).
- **UI tests authenticate via a saved Playwright session instead.** A
  human runs `scripts/generate_storage_state.py` locally - it opens a
  real, visible Chrome window (`channel="chrome"`, not the bundled
  Chromium), prefills email/password if provided, and waits for the
  human to complete the actual login (solving any Turnstile challenge
  themselves). It then saves `storageState.json` (session cookies -
  gitignored, never commit it) via Playwright's
  `context.storage_state()`.
  1. Generate it locally:
     ```powershell
     $env:TODOIST_EMAIL = "you@example.com"
     $env:TODOIST_PASSWORD = "your-password"
     python scripts/generate_storage_state.py
     ```
     (Requires a real Google Chrome installation. If Playwright complains
     it can't find the `chrome` channel, run
     `python -m playwright install chrome` once.)
  2. Base64-encode the result and store it as the GitHub Secret
     `TODOIST_STORAGE_STATE_B64`:
     ```powershell
     $bytes = [IO.File]::ReadAllBytes("storageState.json")
     $b64 = [Convert]::ToBase64String($bytes)
     gh secret set TODOIST_STORAGE_STATE_B64 --body $b64
     ```
  3. Both `pr_gate.yml` and `nightly.yml` decode this secret back into
     `storageState.json` at the start of the job, and
     `Open Todoist App With Saved Session`
     (`tests/resources/keywords/ui_keywords.resource`) loads it via
     Browser Library's `New Context storageState=...` - no login form
     automation involved.
  4. Todoist sessions last on the order of days to weeks. When the saved
     session expires, UI tests fail immediately and loudly at Suite Setup
     with a message telling you to repeat steps 1-2 - see
     `Docs/test_plan.md` → "Known limitations" for why this is a manual
     step rather than an automated refresh.

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
main one: **Todoist's login form is behind Cloudflare Turnstile**, which
blocks scripted logins - confirmed live (2026-08-28) via a DOM dump
showing an empty `cf-turnstile-response` token, not a missing
consent/agreement checkbox as first suspected. UI tests work around this
by loading a pre-generated Playwright session instead of automating the
login form (see "How credentials are handled" above) - the residual
limitation is that this saved session needs periodic manual
regeneration once it expires.

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
├── scripts/
│   └── generate_storage_state.py   # One-off: human-driven login -> storageState.json
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
   lists (at minimum `TODOIST_API_TOKEN` for API tests).
4. For UI tests, generate a Playwright session once - see "How
   credentials are handled" above - and make sure `storageState.json`
   exists at the repo root (or set `TODOIST_STORAGE_STATE_PATH` to point
   at it elsewhere).

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
`TODOIST_STORAGE_STATE_B64`, and (optionally) `TODOIST_SHARE_TEST_EMAIL`
to be configured as repository/organization GitHub Secrets.
`TODOIST_EMAIL`/`TODOIST_PASSWORD` can also be kept as secrets for
convenience, but neither workflow reads them - see "How credentials are
handled" above.

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
