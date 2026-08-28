*** Settings ***
Documentation    Shared test-data keywords ("Create Test Project", "Delete
...              Test Project", "Create Test Task", "Delete Test Task", ...)
...              ensuring every test creates and destroys its own
...              uniquely-prefixed data, regardless of whether the test
...              itself drives the UI or the API. Cleanup always goes
...              through the API (even for UI tests) so it stays fast and
...              reliable.
Library          ../../../libraries/TestDataUtils.py
Resource         api_keywords.resource

*** Keywords ***
Create Test Project
    [Documentation]    Creates a project named TEST_<prefix>_<timestamp>_<random> and returns its id and name.
    [Arguments]    ${name_prefix}=project
    Initialize Todoist API Session
    ${name}=    Generate Unique Name    ${TEST_DATA_PREFIX}_${name_prefix}
    ${project}=    API Create Project    ${name}
    RETURN    ${project}[id]    ${name}

Delete Test Project
    [Arguments]    ${project_id}
    Initialize Todoist API Session
    API Delete Project    ${project_id}

Delete Test Project By Name
    [Documentation]    Looks up a project by its exact name and deletes it. Useful when a UI-created project's id was never captured.
    [Arguments]    ${name}
    Initialize Todoist API Session
    ${projects}=    API Get Projects
    FOR    ${project}    IN    @{projects}
        IF    $project['name'] == $name
            API Delete Project    ${project}[id]
            RETURN
        END
    END

Create Test Task
    [Documentation]    Creates a task named TEST_<prefix>_<timestamp>_<random> in the given project and returns its id and content.
    [Arguments]    ${project_id}    ${content_prefix}=task
    Initialize Todoist API Session
    ${content}=    Generate Unique Name    ${TEST_DATA_PREFIX}_${content_prefix}
    ${task}=    API Create Task    ${content}    ${project_id}
    RETURN    ${task}[id]    ${content}

Delete Test Task
    [Arguments]    ${task_id}
    Initialize Todoist API Session
    API Delete Task    ${task_id}

Create Test Section
    [Arguments]    ${project_id}    ${name_prefix}=section
    Initialize Todoist API Session
    ${name}=    Generate Unique Name    ${TEST_DATA_PREFIX}_${name_prefix}
    ${section}=    API Create Section    ${name}    ${project_id}
    RETURN    ${section}[id]    ${name}

Delete Test Section
    [Arguments]    ${section_id}
    Initialize Todoist API Session
    API Delete Section    ${section_id}

Project Should Be Listed Via Api
    [Documentation]    Fails unless a project named ${name} appears in the
    ...    API's project list. Meant to be wrapped in `Wait Until Keyword
    ...    Succeeds`: Todoist's UI updates optimistically (client-side)
    ...    before the API is guaranteed to reflect the same change, so a
    ...    single immediate check can see stale data - see
    ...    Docs/test_plan.md "Known limitations".
    [Arguments]    ${name}
    Initialize Todoist API Session
    ${projects}=    API Get Projects
    @{names}=    Evaluate    [p['name'] for p in $projects]
    List Should Contain Value    ${names}    ${name}

Project Should Have Name Via Api
    [Documentation]    Fails unless the project with id ${project_id} has
    ...    name ${expected_name} via the API. Meant to be wrapped in
    ...    `Wait Until Keyword Succeeds` for the same eventual-consistency
    ...    reason as `Project Should Be Listed Via Api`.
    [Arguments]    ${project_id}    ${expected_name}
    Initialize Todoist API Session
    ${project}=    API Get Project    ${project_id}
    Should Be Equal    ${project}[name]    ${expected_name}

Find Task By Content In Project
    [Documentation]    Fetches tasks for a project and returns the first one whose content matches exactly. Fails if none match.
    [Arguments]    ${project_id}    ${content}
    ${tasks}=    API Get Tasks By Project    ${project_id}
    FOR    ${task}    IN    @{tasks}
        IF    $task['content'] == $content
            RETURN    ${task}
        END
    END
    Fail    No task with content '${content}' found in project ${project_id}
