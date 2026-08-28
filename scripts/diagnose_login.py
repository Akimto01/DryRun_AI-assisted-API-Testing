"""
Throwaway diagnostic script - NOT part of the test framework.

Opens the Todoist login page, fills in TODOIST_EMAIL / TODOIST_PASSWORD,
and - without ever clicking submit - captures:
  - a full-page screenshot
  - a cropped screenshot around the submit button
  - the outerHTML of the submit button and of the element referenced by
    aria-describedby="agreement-footnote" (plus a few ancestor levels of
    each) so we can see what's actually gating the button.

Used to diagnose why Log In To Todoist's Click ${LOGIN_SUBMIT_BUTTON}
times out (button stays aria-disabled="true"). Does not touch any
.robot/.resource file.
"""
import os
import sys
from pathlib import Path

from playwright.sync_api import sync_playwright

APP_BASE_URL = os.environ.get("APP_BASE_URL", "https://app.todoist.com")
EMAIL = os.environ["TODOIST_EMAIL"]
PASSWORD = os.environ["TODOIST_PASSWORD"]

OUT_DIR = Path(os.environ.get("DIAGNOSTIC_OUT_DIR", "results/diagnostics"))
OUT_DIR.mkdir(parents=True, exist_ok=True)


def outer_html_with_ancestors(page, selector, levels=4):
    return page.eval_on_selector(
        selector,
        """(el, levels) => {
            function nthParent(node, n) {
                let cur = node;
                for (let i = 0; i < n && cur.parentElement; i++) {
                    cur = cur.parentElement;
                }
                return cur;
            }
            return nthParent(el, levels).outerHTML;
        }""",
        levels,
    )


def main():
    report_lines = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()

        page.goto(APP_BASE_URL, wait_until="networkidle")
        report_lines.append(f"Landed on URL: {page.url}")

        email_input = page.locator('input[type="email"]')
        password_input = page.locator('input[type="password"]')
        submit_button = page.locator('button[type="submit"]')

        email_input.wait_for(state="visible", timeout=15000)
        email_input.fill(EMAIL)
        password_input.fill(PASSWORD)

        page.screenshot(path=str(OUT_DIR / "01_full_page_after_fill.png"), full_page=True)
        report_lines.append("Saved 01_full_page_after_fill.png (full page, after filling email+password)")

        try:
            submit_button.scroll_into_view_if_needed(timeout=5000)
            submit_button.screenshot(path=str(OUT_DIR / "02_submit_button_area.png"))
            report_lines.append("Saved 02_submit_button_area.png (cropped around submit button)")
        except Exception as exc:
            report_lines.append(f"Could not screenshot submit button area: {exc}")

        # Submit button: attributes + a few ancestor levels of markup.
        try:
            button_outer_html = submit_button.evaluate("el => el.outerHTML")
            report_lines.append("\n--- Submit button outerHTML ---\n" + button_outer_html)
        except Exception as exc:
            report_lines.append(f"Could not read submit button outerHTML: {exc}")

        try:
            button_ancestors_html = outer_html_with_ancestors(page, 'button[type="submit"]', levels=4)
            report_lines.append("\n--- Submit button + 4 ancestor levels outerHTML ---\n" + button_ancestors_html)
        except Exception as exc:
            report_lines.append(f"Could not read submit button ancestors: {exc}")

        # The element referenced by aria-describedby="agreement-footnote".
        try:
            agreement_outer_html = page.eval_on_selector(
                "#agreement-footnote", "el => el.outerHTML"
            )
            report_lines.append(
                '\n--- #agreement-footnote outerHTML ---\n' + agreement_outer_html
            )
        except Exception as exc:
            report_lines.append(f"Could not read #agreement-footnote outerHTML: {exc}")

        try:
            agreement_ancestors_html = outer_html_with_ancestors(page, "#agreement-footnote", levels=4)
            report_lines.append(
                '\n--- #agreement-footnote + 4 ancestor levels outerHTML ---\n' + agreement_ancestors_html
            )
        except Exception as exc:
            report_lines.append(f"Could not read #agreement-footnote ancestors: {exc}")

        # Any checkbox-like inputs anywhere on the page (candidate consent controls).
        try:
            checkboxes_info = page.eval_on_selector_all(
                'input[type="checkbox"]',
                """els => els.map(el => ({
                    outerHTML: el.outerHTML,
                    checked: el.checked,
                }))""",
            )
            report_lines.append(f"\n--- input[type=checkbox] elements found: {len(checkboxes_info)} ---")
            for i, info in enumerate(checkboxes_info):
                report_lines.append(f"[{i}] checked={info['checked']} html={info['outerHTML']}")
        except Exception as exc:
            report_lines.append(f"Could not enumerate checkboxes: {exc}")

        # Accessibility tree snapshot rooted at the whole page (best-effort;
        # some Playwright versions/browsers may not support this fully).
        try:
            snapshot = page.accessibility.snapshot()
            report_lines.append("\n--- Full-page accessibility snapshot (Python repr, truncated) ---")
            report_lines.append(repr(snapshot)[:8000])
        except Exception as exc:
            report_lines.append(f"Could not capture accessibility snapshot: {exc}")

        browser.close()

    report_path = OUT_DIR / "login_diagnostic_report.txt"
    report_path.write_text("\n".join(str(line) for line in report_lines), encoding="utf-8")
    print(f"Wrote {report_path}")
    print("\n".join(str(line) for line in report_lines))


if __name__ == "__main__":
    sys.exit(main())
