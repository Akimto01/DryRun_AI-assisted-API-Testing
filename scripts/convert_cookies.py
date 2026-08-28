"""Convert a Cookie-Editor JSON export into a Playwright storageState.json file.

Reads cookies_export.json (array of Cookie-Editor cookie objects) and writes
storageState.json ({"cookies": [...], "origins": []}) in the repo root.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "cookies_export.json"
DST = ROOT / "storageState.json"

# Typographic quotes that Word/Notepad sometimes substitute for straight ones,
# which breaks JSON parsing.
SMART_QUOTES = {
    "“": '"',
    "”": '"',
    "‘": "'",
    "’": "'",
}

SAME_SITE_MAP = {
    "no_restriction": "None",
    "lax": "Lax",
    "strict": "Strict",
}


def load_cookies(path: Path):
    text = path.read_text(encoding="utf-8-sig")
    try:
        return json.loads(text), False
    except json.JSONDecodeError:
        fixed = text
        for smart, straight in SMART_QUOTES.items():
            fixed = fixed.replace(smart, straight)
        data = json.loads(fixed)
        path.write_text(fixed, encoding="utf-8")
        return data, True


def map_same_site(value):
    if not value:
        return "Lax"
    return SAME_SITE_MAP.get(str(value).lower(), "Lax")


def convert_cookie(cookie):
    if cookie.get("session") or cookie.get("expirationDate") is None:
        expires = -1
    else:
        expires = cookie["expirationDate"]

    return {
        "name": cookie["name"],
        "value": cookie["value"],
        "domain": cookie["domain"],
        "path": cookie.get("path", "/"),
        "httpOnly": bool(cookie.get("httpOnly", False)),
        "secure": bool(cookie.get("secure", False)),
        "sameSite": map_same_site(cookie.get("sameSite")),
        "expires": expires,
    }


def main():
    raw_cookies, was_fixed = load_cookies(SRC)
    if was_fixed:
        print("cookies_export.json had smart/typographic quotes; fixed in place.")

    converted = [convert_cookie(c) for c in raw_cookies]

    state = {"cookies": converted, "origins": []}
    DST.write_text(json.dumps(state, indent=2), encoding="utf-8")

    print(f"Processed {len(converted)} cookies.")


if __name__ == "__main__":
    main()
