*** Settings ***
Documentation    UI tests for recurring tasks.
...              TODO: extend with completing a recurring task and
...              asserting the next occurrence's due date, and with
...              editing/removing recurrence.
...              Uses a saved login session (Playwright storage state)
...              instead of automating the login form - see
...              tests/resources/keywords/ui_keywords.resource and
...              Docs/test_plan.md "Known limitations".
Resource         ../../config/variables.robot
Resource         ../resources/keywords/test_data.resource
Resource         ../resources/keywords/ui_keywords.resource

Suite Setup      Open Todoist App With Saved Session
Suite Teardown   Close Todoist App
Test Setup       Create Fresh Test Project For Recurring Tests
Test Teardown    Delete Test Project    ${TEST_PROJECT_ID}

Force Tags       ui    recurring

*** Keywords ***
Create Fresh Test Project For Recurring Tests
    ${project_id}    ${project_name}=    Create Test Project    recurring-ui
    Set Test Variable    ${TEST_PROJECT_ID}    ${project_id}
    ${project_locator}=    Get Project Item Locator    ${project_name}
    Click    ${project_locator}

*** Test Cases ***
Create A Recurring Task
    [Documentation]    TODO: extend with completing the task and verifying
    ...    the next due date rolls over correctly.
    [Tags]    regression
    ${content}=    Generate Unique Name    ${TEST_DATA_PREFIX}_recurring-task
    Click    ${ADD_TASK_BUTTON}
    Fill Text    ${TASK_CONTENT_INPUT}    ${content}
    Click    ${TASK_DUE_DATE_FIELD}
    Fill Text    ${TASK_DUE_DATE_FREEFORM}    every day
    Click    ${TASK_DUE_DATE_CONFIRM}
    Click    ${TASK_SAVE_BUTTON}
    ${task_locator}=    Get Task Item Locator    ${content}
    Wait For Elements State    ${task_locator}    visible    timeout=10s
    ${task}=    Find Task By Content In Project    ${TEST_PROJECT_ID}    ${content}
    Should Be True    ${task}[due][is_recurring]
