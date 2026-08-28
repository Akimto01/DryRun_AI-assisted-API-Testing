*** Settings ***
Documentation    API CRUD tests for tasks against the Todoist API (v1).
Resource         ../../config/variables.robot
Resource         ../resources/keywords/test_data.resource

Suite Setup      Initialize Todoist API Session
Test Setup       Create Fresh Test Project For Task Tests
Test Teardown    Delete Test Project    ${TEST_PROJECT_ID}

Force Tags       api    tasks

*** Keywords ***
Create Fresh Test Project For Task Tests
    ${project_id}    ${project_name}=    Create Test Project    tasks-api
    Set Test Variable    ${TEST_PROJECT_ID}    ${project_id}

*** Test Cases ***
Create And Read A Task
    [Tags]    smoke
    ${task_id}    ${content}=    Create Test Task    ${TEST_PROJECT_ID}
    ${task}=    API Get Task    ${task_id}
    Should Be Equal    ${task}[content]    ${content}
    Should Be Equal    ${task}[project_id]    ${TEST_PROJECT_ID}
    Should Be Equal    ${task}[checked]    ${FALSE}

Update A Task
    [Tags]    regression
    ${task_id}    ${content}=    Create Test Task    ${TEST_PROJECT_ID}
    ${new_content}=    Generate Unique Name    ${TEST_DATA_PREFIX}_task-updated
    API Update Task    ${task_id}    ${new_content}
    ${task}=    API Get Task    ${task_id}
    Should Be Equal    ${task}[content]    ${new_content}

Complete And Delete A Task
    [Documentation]    Task deletion is a soft delete: GET on a deleted
    ...    task still returns 200 with is_deleted=true (verified live on
    ...    2026-08-28), unlike projects, which 404 once deleted.
    [Tags]    smoke
    ${task_id}    ${content}=    Create Test Task    ${TEST_PROJECT_ID}
    API Close Task    ${task_id}
    ${task}=    API Get Task    ${task_id}
    Should Be True    ${task}[checked]
    API Delete Task    ${task_id}
    ${task}=    API Get Task    ${task_id}
    Should Be True    ${task}[is_deleted]
