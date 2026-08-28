# Implementation Plan — Todoist Test Framework

This is the consolidated, permanent record of the architectural decisions
behind this framework. It summarizes what's already documented in
`README.md` ("Framework Overview") and `Docs/test_plan.md` - if this file
and those ever disagree, **README.md and Docs/test_plan.md are the
source of truth for their respective areas** (this file is a pointer/
summary, not a second place to edit those facts).

## 1. Stack and language
- Robot Framework (Python) jako test runner
- Browser Library (Playwright) pro UI testy
- RequestsLibrary pro API testy
- Python 3.11+, GitHub Actions pro CI

## 2. Where API lives
- REST API: `https://api.todoist.com/api/v1` (pozn.: původně plánováno
  `rest/v2`, opraveno po živém ověření — v2 je mrtvý/neexistující
  endpoint, viz README.md "Where API lives" pro plné zdůvodnění včetně
  rozdílů v response shape a asymetrie hard/soft delete)
- Web UI target: `https://todoist.com` / `https://app.todoist.com`
- Obě adresy jako proměnné v `config/variables.robot`

## 3. Which use cases are critical
- Critical path (smoke): tasks (create/complete/delete), projects
  (create/rename/delete)
- Regression: labels & filters, sharing, recurring tasks
- Zdůvodnění priorit stejné jako v `Docs/test_plan.md` ("Prioritization
  rationale") - není duplikováno zde

## 4. How credentials are handled
- `TODOIST_API_TOKEN`, `TODOIST_EMAIL`, `TODOIST_PASSWORD` — samostatné
  proměnné, nikdy spojené do jednoho stringu
- Lokálně: Windows Credential Manager (případně env proměnné pro
  dočasné session), nikdy v repu ani v `.env` commitnutém do gitu
- CI: GitHub Secrets, namapované do env v `pr_gate.yml` a `nightly.yml`
  (namapování ověřeno živě - viz sekce 8)
- `config/credentials.template` v repu jako dokumentační vzor bez
  reálných hodnot

## 5. When tests run
- PR/push gate (`pr_gate.yml`): smoke + regression, vyloučit
  `known_defect`, runner `ubuntu-latest`
- Nightly cron (`nightly.yml`, 02:00 UTC): kompletní sada včetně
  `known_defect`
- Manuální spuštění přes `workflow_dispatch` s parametrem `include_tags`
  pro výběr tagů — na **obou** workflow. Na `pr_gate.yml` výchozí hodnota
  `smoke,regression` (stejné jako běžné push/PR chování) a
  `known_defect` je vždy vyloučen bez ohledu na zvolené tagy; na
  `nightly.yml` výchozí je "spustit vše" (včetně `known_defect`,
  reportovaného jako SKIP při selhání).

> Řešeno 2026-08-28: `pr_gate.yml` dřív mělo `workflow_dispatch` bez
> parametru. Teď má stejný `include_tags` vstup jako `nightly.yml`, jen
> s jiným výchozím chováním (viz výše) - `README.md` ("When tests run")
> to popisuje pro obě workflow zvlášť.

## 6. How results are presented
- `log.html` a `report.html` jako CI artefakty (Robot Framework nativní
  výstup)
- Nightly run: e-mailový souhrn (placeholder krok pro Resend integraci)
- `Docs/test_plan.md` jako živá tabulka pokrytí (funkční oblast → tagy →
  stav: pokryto/částečně/TODO)

## 7. Known limitations / open items
- UI login postaven na standardním email+password formuláři (Google/Apple
  SSO by Playwright blokoval). **Login fails on a disabled submit
  button, not on missing credentials** - `TODOIST_EMAIL`/
  `TODOIST_PASSWORD` are configured and `pr_gate.yml` has run live
  against them (2026-08-28, runs `33159448692` and `33159854560`); see
  `Docs/test_plan.md` → "Known limitations" for the exact failure
  (`Click ${LOGIN_SUBMIT_BUTTON}` in `Log In To Todoist`) and root-cause
  hypothesis (unhandled consent/agreement element) - authoritative, not
  duplicated in full here
- `DELETE /tasks/{id}` je soft delete (`is_deleted: true`),
  `DELETE /projects/{id}` je hard delete (404) — asymetrie
  zdokumentovaná v README a promítnutá do assertions v
  `tests/api/tasks_api.robot`
- `tests/ui/sharing.robot` zatím pracuje jen s jedním účtem (pending
  invite), akceptace pozvánky z druhého účtu není ověřená
- Struktura `tests/`, `config/` atd. je přímo v kořeni repa, ne ve
  vnořené složce `TodoistTestFramework/` — repo samo je projekt

> Řešeno 2026-08-28: formulace o UI loginu byla zastaralá (popisovala
> stav "credentials chybí, nikdy neběželo naživo" z doby scaffoldingu).
> Nahrazena přesným popisem výše, sjednoceným s `README.md` a
> `Docs/test_plan.md`.

## 8. Next steps
- Opravit `Log In To Todoist`
  (`tests/resources/keywords/ui_keywords.resource`), aby zvládl
  consent/agreement prvek blokující submit button (viz sekce 7 a
  `Docs/BACKLOG.md` pro kandidátní opravu), pak doladit/re-testovat
  zbytek UI locators proti živému účtu
- Rozšířit `labels_filters`, `sharing`, `recurring_tasks` a
  `sections_api` o zbývající scénáře
- Dotáhnout Resend e-mail krok v nightly workflow
- Začít plnit `config/known_defects.yaml` reálnými nálezy
