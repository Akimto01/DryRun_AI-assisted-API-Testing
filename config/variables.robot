*** Settings ***
Documentation    Central configuration for the Todoist test framework.
...              All values that could identify or authenticate against a
...              real account are sourced from environment variables so
...              nothing sensitive is ever committed. See
...              config/credentials.template for the variables a developer
...              needs to set locally, and README.md for how CI supplies
...              them via GitHub Secrets.

*** Variables ***
# --- API ---
# NOTE: Todoist's old REST API v2 (rest/v2) has been sunset and now
# returns HTTP 410 Gone. This framework targets the current /api/v1
# endpoint instead - verified live against a real account on 2026-08-28
# (full create/rename/close/delete cycle for projects and tasks). See
# README.md ("Where API lives") for the full explanation.
${API_BASE_URL}             https://api.todoist.com/api/v1

# --- Web UI ---
${WEB_BASE_URL}             https://todoist.com
${APP_BASE_URL}             https://app.todoist.com

# --- Credentials (never hardcode - always sourced from the environment) ---
${TODOIST_API_TOKEN}        %{TODOIST_API_TOKEN=}
${TODOIST_EMAIL}            %{TODOIST_EMAIL=}
${TODOIST_PASSWORD}         %{TODOIST_PASSWORD=}

# Optional: used by tests/ui/sharing.robot to invite a collaborator.
# Set to a real, distinct mailbox you control to also verify acceptance.
${SHARE_TEST_EMAIL}         %{TODOIST_SHARE_TEST_EMAIL=share-test-placeholder@example.com}

# --- Browser Library ---
${BROWSER}                  chromium
${HEADLESS}                 ${TRUE}

# --- Test data ---
${TEST_DATA_PREFIX}         TEST
