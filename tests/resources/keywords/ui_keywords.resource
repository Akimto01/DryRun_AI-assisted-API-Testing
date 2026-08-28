*** Settings ***
Documentation    Shared UI keywords for opening Todoist with a saved
...              login session, and for building locators for
...              dynamically-named elements. Todoist's login form is
...              behind Cloudflare Turnstile, which blocks scripted
...              logins - so UI tests never automate the login form
...              itself. Instead they load a Playwright storage state
...              (session cookies) generated ahead of time by a human via
...              scripts/generate_storage_state.py. See Docs/test_plan.md
...              "Known limitations" for the full diagnosis.
Library          Browser
Resource         ../../../config/variables.robot
Resource         ../locators/app_locators.robot

*** Variables ***
${STORAGE_STATE_INVALID_MESSAGE}    Uložená Playwright session vypršela nebo je neplatná. Spusť lokálně scripts/generate_storage_state.py a aktualizuj GitHub Secret TODOIST_STORAGE_STATE_B64.

*** Keywords ***
Open Todoist App With Saved Session
    [Documentation]    Opens Todoist using a previously-generated
    ...    Playwright storage state (see scripts/generate_storage_state.py
    ...    and ${STORAGE_STATE_PATH} in config/variables.robot) instead of
    ...    automating the login form. Fails loudly with actionable
    ...    guidance if the saved session turns out to be missing/expired.
    Should Not Be Empty    ${STORAGE_STATE_PATH}
    ...    msg=STORAGE_STATE_PATH is not set. See config/variables.robot and README.md "How credentials are handled".
    New Browser    browser=${BROWSER}    headless=${HEADLESS}
    New Context    storageState=${STORAGE_STATE_PATH}
    New Page    ${APP_BASE_URL}
    Verify Todoist Session Is Valid

Verify Todoist Session Is Valid
    [Documentation]    Confirms the loaded storage state actually
    ...    authenticated us, rather than letting a stale/expired session
    ...    surface later as a confusing timeout deep inside a test.
    ${current_url}=    Get Url
    IF    'auth/login' in $current_url
        Fail    ${STORAGE_STATE_INVALID_MESSAGE}
    END
    TRY
        Wait For Elements State    ${APP_TASK_LIST}    visible    timeout=10s
    EXCEPT
        Fail    ${STORAGE_STATE_INVALID_MESSAGE}
    END

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
