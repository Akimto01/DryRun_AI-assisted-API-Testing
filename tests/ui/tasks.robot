*** Settings ***
Documentation    UI tests for basic task lifecycle (create/complete/delete).
...              Each test works inside its own throwaway project, created
...              via the API in Test Setup and torn down via the API in
...              Test Teardown - see tests/resources/keywords/test_data.resource.
...
...              KNOWN LIMITATION: login and app-shell locators in
...              tests/resources/locators/app_locators.robot have not
...              been verified against a live account - see
...              Docs/test_plan.md "Known limitations".
Resource         ../../config/variables.robot
Resource         ../resources/keywords/test_data.resource
Resource         ../resources/keywords/ui_keywords.resource

Suite Setup      Open Todoist App And Log In
Suite Teardown   Close Todoist App
Test Setup       Create Fresh Test Project For Task UI Tests
Test Teardown    Delete Test Project    ${TEST_PROJECT_ID}

Force Tags       ui    tasks

*** Keywords ***
Create Fresh Test Project For Task UI Tests
    ${project_id}    ${project_name}=    Create Test Project    tasks-ui
    Set Test Variable    ${TEST_PROJECT_ID}    ${project_id}
    ${project_locator}=    Get Project Item Locator    ${project_name}
    Click    ${project_locator}

*** Test Cases ***
Create A Task
    [Documentation]    Creating a task in the UI persists it (verified via the API).
    [Tags]    smoke
    ${content}=    Generate Unique Name    ${TEST_DATA_PREFIX}_task-ui
    Click    ${ADD_TASK_BUTTON}
    Fill Text    ${TASK_CONTENT_INPUT}    ${content}
    Click    ${TASK_SAVE_BUTTON}
    ${task_locator}=    Get Task Item Locator    ${content}
    Wait For Elements State    ${task_locator}    visible    timeout=10s
    ${task}=    Find Task By Content In Project    ${TEST_PROJECT_ID}    ${content}
    Should Be Equal    ${task}[content]    ${content}

Mark A Task As Complete
    [Documentation]    Completing a task in the UI reflects as checked=true via the API.
    [Tags]    smoke
    ${task_id}    ${content}=    Create Test Task    ${TEST_PROJECT_ID}
    Reload
    ${task_locator}=    Get Task Item Locator    ${content}
    Click    ${task_locator} >> ${TASK_CHECKBOX}
    ${task}=    API Get Task    ${task_id}
    Should Be True    ${task}[checked]

Delete A Task
    [Documentation]    Deleting a task in the UI removes it (verified absent via the API).
    [Tags]    regression
    ${task_id}    ${content}=    Create Test Task    ${TEST_PROJECT_ID}
    Reload
    ${task_locator}=    Get Task Item Locator    ${content}
    Hover    ${task_locator}
    Click    ${task_locator} >> ${MORE_OPTIONS_BUTTON}
    Click    ${TASK_DELETE_MENU_ITEM}
    Wait For Elements State    ${task_locator}    hidden    timeout=10s
