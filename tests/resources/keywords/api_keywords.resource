*** Settings ***
Documentation    Low-level HTTP helpers for the Todoist API (v1). Endpoint
...              shapes below were verified live against a real account on
...              2026-08-28 (create/rename/close/delete for both projects
...              and tasks; list endpoints return a {"results": [...]}
...              envelope).
Library          RequestsLibrary
Library          Collections
Resource         ../../../config/variables.robot

*** Keywords ***
Initialize Todoist API Session
    [Documentation]    Creates (or reuses) the shared RequestsLibrary session named "todoist".
    Should Not Be Empty    ${TODOIST_API_TOKEN}
    ...    msg=TODOIST_API_TOKEN is not set. Copy config/credentials.template and export it before running API-backed tests.
    &{headers}=    Create Dictionary    Authorization=Bearer ${TODOIST_API_TOKEN}    Content-Type=application/json
    Create Session    todoist    ${API_BASE_URL}    headers=${headers}

API Get Projects
    ${resp}=    GET On Session    todoist    /projects
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}[results]

API Create Project
    [Arguments]    ${name}
    ${resp}=    POST On Session    todoist    /projects    json=${{ {"name": $name} }}
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}

API Get Project
    [Arguments]    ${project_id}
    ${resp}=    GET On Session    todoist    /projects/${project_id}
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}

API Update Project
    [Arguments]    ${project_id}    ${name}
    ${resp}=    POST On Session    todoist    /projects/${project_id}    json=${{ {"name": $name} }}
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}

API Delete Project
    [Arguments]    ${project_id}
    ${resp}=    DELETE On Session    todoist    /projects/${project_id}    expected_status=anything
    Run Keyword If    ${resp.status_code} not in (204, 404)
    ...    Fail    Unexpected status deleting project ${project_id}: ${resp.status_code}

API Get Tasks By Project
    [Arguments]    ${project_id}
    ${resp}=    GET On Session    todoist    /tasks    params=${{ {"project_id": $project_id} }}
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}[results]

API Create Task
    [Arguments]    ${content}    ${project_id}
    ${resp}=    POST On Session    todoist    /tasks    json=${{ {"content": $content, "project_id": $project_id} }}
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}

API Get Task
    [Arguments]    ${task_id}
    ${resp}=    GET On Session    todoist    /tasks/${task_id}
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}

API Update Task
    [Arguments]    ${task_id}    ${content}
    ${resp}=    POST On Session    todoist    /tasks/${task_id}    json=${{ {"content": $content} }}
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}

API Close Task
    [Arguments]    ${task_id}
    ${resp}=    POST On Session    todoist    /tasks/${task_id}/close
    Status Should Be    204    ${resp}

API Delete Task
    [Arguments]    ${task_id}
    ${resp}=    DELETE On Session    todoist    /tasks/${task_id}    expected_status=anything
    Run Keyword If    ${resp.status_code} not in (204, 404)
    ...    Fail    Unexpected status deleting task ${task_id}: ${resp.status_code}

API Create Section
    [Arguments]    ${name}    ${project_id}
    ${resp}=    POST On Session    todoist    /sections    json=${{ {"name": $name, "project_id": $project_id} }}
    Status Should Be    200    ${resp}
    RETURN    ${resp.json()}

API Delete Section
    [Arguments]    ${section_id}
    ${resp}=    DELETE On Session    todoist    /sections/${section_id}    expected_status=anything
    Run Keyword If    ${resp.status_code} not in (204, 404)
    ...    Fail    Unexpected status deleting section ${section_id}: ${resp.status_code}
