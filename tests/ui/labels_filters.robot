*** Settings ***
Documentation    UI tests for labels and filters.
...              TODO: extend with filter creation/query coverage and
...              multi-label scenarios - only single-label assignment is
...              covered so far.
...              KNOWN LIMITATION: login and app-shell locators have not
...              been verified against a live account - see
...              Docs/test_plan.md "Known limitations".
Resource         ../../config/variables.robot
Resource         ../resources/keywords/test_data.resource
Resource         ../resources/keywords/ui_keywords.resource

Suite Setup      Open Todoist App And Log In
Suite Teardown   Close Todoist App
Test Setup       Create Fresh Test Project For Label Tests
Test Teardown    Delete Test Project    ${TEST_PROJECT_ID}

Force Tags       ui    labels    filters

*** Keywords ***
Create Fresh Test Project For Label Tests
    ${project_id}    ${project_name}=    Create Test Project    labels-ui
    Set Test Variable    ${TEST_PROJECT_ID}    ${project_id}
    ${project_locator}=    Get Project Item Locator    ${project_name}
    Click    ${project_locator}

*** Test Cases ***
Assign A Label To A Task
    [Documentation]    TODO: this file only covers assigning a single
    ...    label to a task. Extend with filter creation/query coverage
    ...    and multi-label scenarios.
    [Tags]    regression
    ${task_id}    ${content}=    Create Test Task    ${TEST_PROJECT_ID}
    Reload
    ${label_name}=    Generate Unique Name    ${TEST_DATA_PREFIX}_label
    ${task_locator}=    Get Task Item Locator    ${content}
    Click    ${task_locator}
    Fill Text    ${LABEL_PICKER_INPUT}    @${label_name}
    Keyboard Key    press    Enter
    ${task}=    API Get Task    ${task_id}
    List Should Contain Value    ${task}[labels]    ${label_name}
