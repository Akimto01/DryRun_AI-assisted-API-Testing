*** Settings ***
Documentation    Shared UI keywords for opening Todoist, logging in, and
...              building locators for dynamically-named elements.
...              KNOWN LIMITATION: login and app-shell locators (in
...              tests/resources/locators/app_locators.robot) are
...              best-effort and have not been verified against a live
...              account - see Docs/test_plan.md "Known limitations".
Library          Browser
Resource         ../../../config/variables.robot
Resource         ../locators/app_locators.robot

*** Keywords ***
Open Todoist App
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Context
    New Page    ${APP_BASE_URL}

Log In To Todoist
    Should Not Be Empty    ${TODOIST_EMAIL}
    ...    msg=TODOIST_EMAIL is not set - UI tests need real test-account credentials. See config/credentials.template and Docs/test_plan.md "Known limitations".
    Should Not Be Empty    ${TODOIST_PASSWORD}
    ...    msg=TODOIST_PASSWORD is not set - UI tests need real test-account credentials. See config/credentials.template and Docs/test_plan.md "Known limitations".
    Fill Text    ${LOGIN_EMAIL_INPUT}    ${TODOIST_EMAIL}
    Fill Text    ${LOGIN_PASSWORD_INPUT}    ${TODOIST_PASSWORD}
    Click    ${LOGIN_SUBMIT_BUTTON}
    Wait For Elements State    ${APP_TASK_LIST}    visible    timeout=15s

Open Todoist App And Log In
    Open Todoist App
    Log In To Todoist

Close Todoist App
    Close Browser

Get Task Item Locator
    [Documentation]    Builds a locator matching the task row containing the given content.
    [Arguments]    ${content}
    RETURN    xpath=//div[@data-testid="task-item"][contains(., "${content}")]

Get Project Item Locator
    [Documentation]    Builds a locator matching the sidebar project entry with the given name.
    [Arguments]    ${name}
    RETURN    xpath=//div[@data-testid="project-list-item"][contains(., "${name}")]

Get Collaborator Row Locator
    [Documentation]    Builds a locator matching a project's collaborator/invite row for the given email.
    [Arguments]    ${email}
    RETURN    xpath=//div[@data-testid="collaborator-row"][contains(., "${email}")]
