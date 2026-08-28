# Backlog

Ideas and known gaps for extending this framework, roughly in priority order.

- [ ] Verify `tests/resources/locators/app_locators.robot` and the UI
      login flow (`tests/resources/keywords/ui_keywords.resource`)
      against a real Todoist test account, and fix up any selectors that
      don't match. See Docs/test_plan.md "Known limitations".
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
