"""
Generates a Playwright storage state (session cookies) for the UI test
suite, by having a human complete the real Todoist login - including any
Cloudflare Turnstile challenge - in a real, visible Chrome window.

Playwright/Robot Framework cannot automate the login form itself:
Todoist's login is protected by Cloudflare Turnstile, which is designed
to block scripted logins. See Docs/test_plan.md "Known limitations" for
the full diagnosis. UI tests instead load a pre-generated session via
the "Open Todoist App With Saved Session" keyword
(tests/resources/keywords/ui_keywords.resource).

Usage (run locally, never in CI):
    TODOIST_EMAIL=you@example.com TODOIST_PASSWORD=secret python scripts/generate_storage_state.py

Produces storageState.json in the repo root (gitignored - never commit
it, it is as sensitive as a live session token). Next step: base64-encode
it and store it as the TODOIST_STORAGE_STATE_B64 GitHub Secret - see
README.md ("How credentials are handled") for the exact commands.

Requires a real Google Chrome installation (uses channel="chrome", not
the Playwright-bundled Chromium) and a visible display - it opens a
real, headed browser window on purpose.
"""
import os
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright

APP_BASE_URL = os.environ.get("APP_BASE_URL", "https://app.todoist.com")
EMAIL = os.environ.get("TODOIST_EMAIL", "")
PASSWORD = os.environ.get("TODOIST_PASSWORD", "")
OUT_PATH = Path(os.environ.get("STORAGE_STATE_PATH", "storageState.json"))


def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(channel="chrome", headless=False)
        context = browser.new_context()
        page = context.new_page()

        page.goto(APP_BASE_URL, wait_until="load")

        if EMAIL:
            try:
                page.locator('input[type="email"]').fill(EMAIL, timeout=10000)
            except Exception:
                print("Could not prefill the email field - fill it in manually.")
        if PASSWORD:
            try:
                page.locator('input[type="password"]').fill(PASSWORD, timeout=10000)
            except Exception:
                print("Could not prefill the password field - fill it in manually.")

        print()
        print("A real Chrome window has opened. Please:")
        print("  1. Check the email/password fields (prefilled if credentials were provided).")
        print("  2. Click 'Log in', and solve any Cloudflare Turnstile / other challenge yourself.")
        print("  3. Wait until you actually see your Todoist task list.")
        input("Then come back here and press Enter to continue... ")

        if "auth/login" in page.url:
            print(f"WARNING: still on {page.url} - login does not look complete.")
            input("Finish logging in, then press Enter again to retry the check... ")

        try:
            page.wait_for_selector('[data-testid="task-list"]', timeout=10000)
            print("Task list detected - login looks successful.")
        except Exception:
            print(
                "WARNING: could not find the task list element - the saved session "
                "may not actually be authenticated. Saving storage state anyway, but "
                "verify it works before relying on it: 'Open Todoist App With Saved "
                "Session' will fail loudly with clear guidance if it doesn't."
            )

        OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
        context.storage_state(path=str(OUT_PATH))
        print(f"Saved storage state to {OUT_PATH.resolve()}")
        print(
            "Next: base64-encode it and store it as the TODOIST_STORAGE_STATE_B64 "
            "GitHub Secret - see README.md 'How credentials are handled'."
        )

        browser.close()


if __name__ == "__main__":
    sys.exit(main())
