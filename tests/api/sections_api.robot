*** Settings ***
Documentation    API tests for sections against the Todoist API (v1).
...              TODO: extend with rename, reorder, and delete-section
...              coverage, and with moving tasks between sections.
Resource         ../../config/variables.robot
Resource         ../resources/keywords/test_data.resource

Suite Setup      Initialize Todoist API Session
Test Setup       Create Fresh Test Project For Section Tests
Test Teardown    Delete Test Project    ${TEST_PROJECT_ID}

Force Tags       api    sections

*** Keywords ***
Create Fresh Test Project For Section Tests
    ${project_id}    ${project_name}=    Create Test Project    sections-api
    Set Test Variable    ${TEST_PROJECT_ID}    ${project_id}

*** Test Cases ***
Create A Section In A Project
    [Documentation]    TODO: add rename/reorder/delete-section coverage.
    [Tags]    regression
    ${section_id}    ${name}=    Create Test Section    ${TEST_PROJECT_ID}
    ${resp}=    GET On Session    todoist    /sections/${section_id}
    Status Should Be    200    ${resp}
    Should Be Equal    ${resp.json()}[name]    ${name}
