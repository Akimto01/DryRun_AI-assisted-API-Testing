*** Settings ***
Documentation    Selectors for the Todoist web app (app.todoist.com).
...              These are best-effort, based on Todoist's publicly
...              observable UI structure - they have NOT been verified
...              against a live account, because no TODOIST_EMAIL /
...              TODOIST_PASSWORD were available while this framework was
...              scaffolded (only an API token was provided). Verify and
...              adjust these before relying on the UI suites - see
...              Docs/test_plan.md "Known limitations".

*** Variables ***
# --- Login ---
${LOGIN_EMAIL_INPUT}           input[type="email"]
${LOGIN_PASSWORD_INPUT}        input[type="password"]
${LOGIN_SUBMIT_BUTTON}         button[type="submit"]

# --- App shell ---
${APP_TASK_LIST}               [data-testid="task-list"]
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
