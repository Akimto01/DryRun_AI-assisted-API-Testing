# Backlog

Ideas and known gaps for extending this framework, roughly in priority order.

- [x] ~~Fix `Log In To Todoist` by clicking a consent/agreement
      checkbox~~ - **superseded, hypothesis disproven.** A live DOM dump
      (2026-08-28, throwaway `diagnose_login.yml`/`scripts/diagnose_login.py`,
      since removed) found zero `input[type="checkbox"]` elements on the
      login page; `aria-describedby="agreement-footnote"` just points at
      a plain-text ToS/Privacy disclaimer, not an interactive element.
      The actual blocker is a hidden Cloudflare Turnstile widget
      (`#cf-turnstile`) with an empty `cf-turnstile-response` token -
      anti-bot detection, not a missed click. See Docs/test_plan.md
      "Known limitations" for the full diagnosis.
- [x] Implemented persisted-storage-state login (2026-08-28):
      `scripts/generate_storage_state.py` (human completes the real
      login once, headed Chrome) + `Open Todoist App With Saved Session`
      (`tests/resources/keywords/ui_keywords.resource`) loading it via
      `New Context storageState=...`, restored in CI from the
      `TODOIST_STORAGE_STATE_B64` secret. UI tests no longer automate
      the login form at all.
- [ ] **Not yet done: actually generate `storageState.json` and set the
      `TODOIST_STORAGE_STATE_B64` GitHub Secret** - requires a human
      (with real Todoist credentials) to run
      `scripts/generate_storage_state.py` locally; an AI agent can't
      complete Turnstile/interactive login on someone's behalf. Until
      this is done, every UI suite will fail loudly at Suite Setup with
      a message pointing back to this step.
- [ ] Once a real `storageState.json` exists, verify
      `Open Todoist App With Saved Session` and the rest of
      `tests/resources/locators/app_locators.robot` against the live
      account and fix up any selectors that don't match.
- [ ] **Considered and deliberately deferred: automated storageState
      refresh.** A scheduled workflow could try to keep the session
      alive by periodically re-exporting `storage_state()` after a test
      run and writing it back to the GitHub Secret - but doing that
      requires a workflow with permission to rewrite repository secrets
      (the default `GITHUB_TOKEN` can't; it would need a PAT stored as
      another secret), which is a meaningfully larger attack surface if
      the workflow or a dependency is ever compromised. It also
      wouldn't eliminate manual regeneration entirely - a hard session
      expiry, password change, or logout-everywhere would still need
      it. Revisit only if manual regeneration (expected every few
      weeks) turns out to be a real operational pain in practice.
- [ ] **Systemic risk: test account's free-tier 5-project limit.**
      Discovered 2026-08-28 while fixing `tests/ui/projects.robot`
      locators: leftover `TEST_*` projects from earlier failed/interrupted
      runs (teardown never ran, e.g. due to the Suite-Setup and locator
      bugs just fixed) had filled all 5 free-tier project slots. Once
      full, Todoist replaces the "Add project" dialog with a "Try Pro"
      paywall modal, so any future teardown failure won't just leak one
      project - it'll eventually block every UI test that creates a
      project with a confusing paywall failure instead of the real cause.
      Possible fixes: (a) setup-time cleanup - delete everything with the
      `TEST_` prefix before the UI suite runs, so a bad run can never
      accumulate past one cycle; or (b) a periodic (manual or scheduled)
      sweep of `TEST_*` projects independent of any single run's
      teardown. Not implemented - no code changed for this, just noting
      the risk.
- [ ] Extend `tests/ui/labels_filters.robot` with filter creation/query
      coverage and multi-label scenarios.
- [ ] Extend `tests/ui/sharing.robot` with a second real collaborator
      account to verify accepted (not just pending) collaboration state,
      and permission/role changes.
- [ ] Extend `tests/ui/recurring_tasks.robot` with completing a recurring
      task and asserting the next occurrence's due date.
- [ ] Extend `tests/api/sections_api.robot` with rename, reorder, delete,
      and moving tasks between sections.
- [ ] Implement the nightly email summary step in
      `.github/workflows/nightly.yml` using Resend (currently a
      placeholder echo step) - requires a `RESEND_API_KEY` secret and a
      small notification script/action.
- [ ] Populate `config/known_defects.yaml` with real defects as they're
      found, and tag the guarding tests with `known_defect` + the defect
      id (see the registry file's header comment for the full
      convention).
