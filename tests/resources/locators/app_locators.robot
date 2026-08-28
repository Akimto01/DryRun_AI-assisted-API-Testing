*** Settings ***
Documentation    Selectors for the Todoist web app (app.todoist.com).
...              These are best-effort, based on Todoist's publicly
...              observable UI structure and have not been exhaustively
...              verified against a live account - adjust as needed. Note
...              there are no login-form selectors here: the login form
...              itself is never automated (Todoist's login is behind
...              Cloudflare Turnstile, which blocks scripted logins) - see
...              tests/resources/keywords/ui_keywords.resource
...              ("Open Todoist App With Saved Session") and
...              Docs/test_plan.md "Known limitations".

*** Variables ***
# --- App shell ---
# Verified live (2026-08-28) against a real logged-in session: the sidebar
# container (holds the account name) renders right after login regardless
# of whether the current view (e.g. an empty Inbox) has any tasks - unlike
# [data-testid="task-list"], which only renders when the view has content
# and previously caused false "session invalid" failures on empty Inboxes.
${APP_SIDEBAR_CONTAINER}       [data-testid="app-sidebar-container"]
# Verified live (2026-08-28): real aria-label is Czech ("Další akce"), not
# the English "More options" this locator originally guessed - see the
# "Projects sidebar" note below on why the UI is in Czech at all.
${MORE_OPTIONS_BUTTON}         [aria-label="Další akce"]

# --- Tasks ---
${ADD_TASK_BUTTON}             [data-testid="add-task-button"]
${TASK_CONTENT_INPUT}          [data-testid="task-content-input"]
${TASK_SAVE_BUTTON}            text=Add task
${TASK_CHECKBOX}               [data-testid="task-checkbox"]
${TASK_DELETE_MENU_ITEM}       text=Delete task

# --- Projects sidebar ---
# Verified live (2026-08-28) against a real logged-in session. Two findings
# that don't reduce to just fixing variable values:
#   1. The account's Todoist UI language is Czech. Forcing English via
#      New Context locale/extraHTTPHeaders and via a "?lang=en" URL param
#      were both tried live and neither changes the rendered language -
#      Todoist reads UI language from a server-side account setting, not
#      the client - and changing the real account's language was ruled
#      out (it's used outside these tests too). So these locators target
#      the actual Czech text/attributes instead of guessed English ones.
#      See Docs/test_plan.md "Known limitations".
#   2. There is no standalone "add project" button. The sidebar "+" only
#      renders in the DOM after hovering the "Moje projekty" section
#      header, and opens a small menu rather than a form directly - see
#      `Open Add Project Dialog` in ui_keywords.resource.
${PROJECTS_SECTION_HEADER}        text=Moje projekty
${PROJECTS_SECTION_MENU_BUTTON}   [aria-label="Nabídka Moje projekty"]
${ADD_PROJECT_MENU_ITEM}          css=[role="menu"] >> text="Přidat projekt"
# No data-testid or aria-label/placeholder exists on the real name field -
# there IS an input with aria-label="Napište název projektu", but it's a
# separate, zero-size decoy/autocomplete field (confirmed via
# getBoundingClientRect: 0x0), not the one the screenshot shows text going
# into. The actual field (shared by the create and rename dialogs) only
# has name="name" and is otherwise unlabelled.
${PROJECT_NAME_INPUT}             input[name="name"]
# Create and rename use different dialogs with different submit button
# text ("Přidat" vs "Uložit") - not the same button, so not one variable.
${PROJECT_ADD_SUBMIT_BUTTON}      text="Přidat"
${PROJECT_RENAME_SUBMIT_BUTTON}   text="Uložit"
# Scoped to the open "Další akce" dropdown (role=menu) because the delete
# confirmation dialog's own button has the exact same text ("Smazat") -
# see PROJECT_DELETE_CONFIRM_BUTTON below for how that one is
# disambiguated instead.
${PROJECT_RENAME_MENU_ITEM}       css=[role="menu"] >> text="Upravit"
${PROJECT_DELETE_MENU_ITEM}       css=[role="menu"] >> text="Smazat"
# The delete confirmation dialog has no role="dialog"/testid to scope by
# (only auto-generated hashed CSS classes) - but its confirm button is the
# dialog's default/auto-focused action, marked data-autofocus="true",
# which reliably distinguishes it from the identically-labelled "Smazat"
# menu item above.
${PROJECT_DELETE_CONFIRM_BUTTON}  [data-autofocus="true"]

# --- Labels ---
${LABEL_PICKER_INPUT}          [data-testid="label-picker-input"]

# --- Sharing ---
${SHARE_BUTTON}                [data-testid="project-share-button"]
${SHARE_EMAIL_INPUT}           input[placeholder="Enter email or name"]
${SHARE_INVITE_BUTTON}         text=Invite
${SHARE_REMOVE_BUTTON}         [aria-label="Remove"]

# --- Recurring tasks ---
${TASK_DUE_DATE_FIELD}         text=Due date
${TASK_DUE_DATE_FREEFORM}      input[placeholder="Type a due date"]
${TASK_DUE_DATE_CONFIRM}       text=Add
