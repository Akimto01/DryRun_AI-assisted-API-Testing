*** Settings ***
Documentation    UI tests for project sharing/collaboration.
...              TODO: extend with a second real collaborator account to
...              verify the accepted (not just pending) collaboration
...              state, and with role/permission changes.
...              KNOWN LIMITATION: login and app-shell locators have not
...              been verified against a live account - see
...              Docs/test_plan.md "Known limitations".
Resource         ../../config/variables.robot
Resource         ../resources/keywords/test_data.resource
Resource         ../resources/keywords/ui_keywords.resource

Suite Setup      Open Todoist App And Log In
Suite Teardown   Close Todoist App
Test Setup       Create Fresh Test Project For Sharing Tests
Test Teardown    Delete Test Project    ${TEST_PROJECT_ID}

Force Tags       ui    sharing

*** Keywords ***
Create Fresh Test Project For Sharing Tests
    ${project_id}    ${project_name}=    Create Test Project    sharing-ui
    Set Test Variable    ${TEST_PROJECT_ID}    ${project_id}
    ${project_locator}=    Get Project Item Locator    ${project_name}
    Click    ${project_locator}

*** Test Cases ***
Invite A Collaborator To A Project
    [Documentation]    TODO: only verifies the pending-invite state with a
    ...    single account. Extend with a second collaborator account to
    ...    verify acceptance and permission handling - see Docs/BACKLOG.md.
    [Tags]    regression
    Click    ${SHARE_BUTTON}
    Fill Text    ${SHARE_EMAIL_INPUT}    ${SHARE_TEST_EMAIL}
    Click    ${SHARE_INVITE_BUTTON}
    ${collaborator_locator}=    Get Collaborator Row Locator    ${SHARE_TEST_EMAIL}
    Wait For Elements State    ${collaborator_locator}    visible    timeout=10s
    [Teardown]    Remove Test Collaborator And Project    ${collaborator_locator}

*** Keywords ***
Remove Test Collaborator And Project
    [Arguments]    ${collaborator_locator}
    Run Keyword And Ignore Error    Click    ${collaborator_locator} >> ${SHARE_REMOVE_BUTTON}
    Delete Test Project    ${TEST_PROJECT_ID}
