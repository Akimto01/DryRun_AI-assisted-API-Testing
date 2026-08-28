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
${MORE_OPTIONS_BUTTON}         [aria-label="More options"]

# --- Tasks ---
${ADD_TASK_BUTTON}             [data-testid="add-task-button"]
${TASK_CONTENT_INPUT}          [data-testid="task-content-input"]
${TASK_SAVE_BUTTON}            text=Add task
${TASK_CHECKBOX}               [data-testid="task-checkbox"]
${TASK_DELETE_MENU_ITEM}       text=Delete task

# --- Projects sidebar ---
${ADD_PROJECT_BUTTON}          [data-testid="add-project-button"]
${PROJECT_NAME_INPUT}          [data-testid="project-name-input"]
${PROJECT_ADD_SUBMIT_BUTTON}   text=Add
${PROJECT_RENAME_MENU_ITEM}    text=Edit
${PROJECT_DELETE_MENU_ITEM}    text=Delete
${PROJECT_DELETE_CONFIRM_BUTTON}    text=Delete project

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
