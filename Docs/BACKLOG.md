# Backlog

Ideas and known gaps for extending this framework, roughly in priority order.

- [ ] Fix `Log In To Todoist` (`tests/resources/keywords/ui_keywords.resource`):
      live runs (2026-08-28, `pr_gate.yml` runs `33159448692` and
      `33159854560`) show the login submit button stays
      `aria-disabled="true"` (`aria-describedby="agreement-footnote"`)
      after filling email/password, so `Click ${LOGIN_SUBMIT_BUTTON}`
      times out. Candidate fix, *not yet applied* - inspect the actual
      login page (e.g. a Playwright trace/screenshot on failure) for the
      consent/agreement element referenced by `agreement-footnote`; if
      it's a simple checkbox, adding one `Click Element` (or equivalent
      Browser Library keyword) on it before the existing
      `Click ${LOGIN_SUBMIT_BUTTON}` call may be enough to unblock the
      button. Needs confirmation against the live page before editing
      the keyword - the exact selector isn't known yet.
- [ ] Once login succeeds, verify the rest of
      `tests/resources/locators/app_locators.robot` against the real
      account and fix up any selectors that don't match. See
      Docs/test_plan.md "Known limitations".
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
