*** Settings ***
Documentation    API CRUD tests for projects against the Todoist API (v1).
Resource         ../../config/variables.robot
Resource         ../resources/keywords/test_data.resource

Suite Setup      Initialize Todoist API Session

Force Tags       api    projects

*** Test Cases ***
Create And Read A Project
    [Tags]    smoke
    ${project_id}    ${name}=    Create Test Project    projects-api
    ${project}=    API Get Project    ${project_id}
    Should Be Equal    ${project}[name]    ${name}
    [Teardown]    Delete Test Project    ${project_id}

Rename A Project
    [Tags]    regression
    ${project_id}    ${name}=    Create Test Project    projects-api
    ${new_name}=    Generate Unique Name    ${TEST_DATA_PREFIX}_projects-api-renamed
    API Update Project    ${project_id}    ${new_name}
    ${project}=    API Get Project    ${project_id}
    Should Be Equal    ${project}[name]    ${new_name}
    [Teardown]    Delete Test Project    ${project_id}

Delete A Project
    [Tags]    smoke
    ${project_id}    ${name}=    Create Test Project    projects-api
    API Delete Project    ${project_id}
    ${resp}=    GET On Session    todoist    /projects/${project_id}    expected_status=anything
    Status Should Be    404    ${resp}
