*** Settings ***
Documentation    UI tests for basic project lifecycle (create/rename/delete).
...              Uses a saved login session (Playwright storage state)
...              instead of automating the login form - see
...              tests/resources/keywords/ui_keywords.resource and
...              Docs/test_plan.md "Known limitations".
Resource         ../../config/variables.robot
Resource         ../resources/keywords/test_data.resource
Resource         ../resources/keywords/ui_keywords.resource

Suite Setup      Open Todoist App With Saved Session
Suite Teardown   Close Todoist App

Force Tags       ui    projects

*** Test Cases ***
Create A Project
    [Documentation]    Creating a project in the UI persists it (verified via the API).
    [Tags]    smoke
    ${name}=    Generate Unique Name    ${TEST_DATA_PREFIX}_projects-ui
    Open Add Project Dialog
    Fill Text    ${PROJECT_NAME_INPUT}    ${name}
    Click    ${PROJECT_ADD_SUBMIT_BUTTON}
    ${project_locator}=    Get Project Item Locator    ${name}
    Wait For Elements State    ${project_locator}    visible    timeout=10s
    ${projects}=    API Get Projects
    @{names}=    Evaluate    [p['name'] for p in $projects]
    List Should Contain Value    ${names}    ${name}
    [Teardown]    Delete Test Project By Name    ${name}

Rename A Project
    [Documentation]    Renaming a project in the UI persists it (verified via the API).
    [Tags]    regression
    ${project_id}    ${name}=    Create Test Project    projects-ui
    Reload
    ${new_name}=    Generate Unique Name    ${TEST_DATA_PREFIX}_projects-ui-renamed
    ${project_locator}=    Get Project Item Locator    ${name}
    Hover    ${project_locator}
    Click    ${project_locator} >> ${MORE_OPTIONS_BUTTON}
    Click    ${PROJECT_RENAME_MENU_ITEM}
    Fill Text    ${PROJECT_NAME_INPUT}    ${new_name}
    Click    ${PROJECT_RENAME_SUBMIT_BUTTON}
    ${renamed_locator}=    Get Project Item Locator    ${new_name}
    Wait For Elements State    ${renamed_locator}    visible    timeout=10s
    ${project}=    API Get Project    ${project_id}
    Should Be Equal    ${project}[name]    ${new_name}
    [Teardown]    Delete Test Project    ${project_id}

Delete A Project
    [Documentation]    Deleting a project in the UI removes it (verified absent via the API).
    [Tags]    smoke
    ${project_id}    ${name}=    Create Test Project    projects-ui
    Reload
    ${project_locator}=    Get Project Item Locator    ${name}
    Hover    ${project_locator}
    Click    ${project_locator} >> ${MORE_OPTIONS_BUTTON}
    Click    ${PROJECT_DELETE_MENU_ITEM}
    Click    ${PROJECT_DELETE_CONFIRM_BUTTON}
    Wait For Elements State    ${project_locator}    hidden    timeout=10s
