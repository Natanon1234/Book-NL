#!/usr/bin/env python3
"""Check whitespace and newline conventions in changed LaTeX source files.

Only changed .tex files are checked so legacy formatting elsewhere in the
repository does not block unrelated contributions.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def git_output(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return result.stdout


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--base",
        default="origin/main",
        help="Git ref to compare against (default: origin/main)",
    )
    args = parser.parse_args()

    comparison = f"{args.base}...HEAD"
    changed = [
        path
        for path in git_output(
            "diff",
            "--name-only",
            "--diff-filter=ACMR",
            comparison,
            "--",
            "*.tex",
        ).splitlines()
        if path.endswith(".tex")
    ]

    if not changed:
        print("Formatting check: no changed .tex files; nothing to validate.")
        return 0

    failures: list[str] = []
    for filename in changed:
        path = Path(filename)
        if not path.is_file():
            continue

        content = path.read_bytes()
        if b"\r" in content:
            failures.append(f"{filename}: use LF line endings, not CRLF.")
        if content and not content.endswith(b"\n"):
            failures.append(f"{filename}: missing final newline.")

        diff = git_output(
            "diff",
            "--no-ext-diff",
            "--unified=0",
            comparison,
            "--",
            filename,
        )
        for line_number, line in enumerate(diff.splitlines(), start=1):
            if not line.startswith("+") or line.startswith("+++"):
                continue
            added = line[1:]
            if added.endswith((" ", "\t")):
                failures.append(
                    f"{filename}: added line has trailing whitespace "
                    f"(diff line {line_number})."
                )
            if "\t" in added:
                failures.append(
                    f"{filename}: added line contains a tab character "
                    f"(diff line {line_number}); use spaces."
                )

    if failures:
        print("LaTeX formatting check failed:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print(f"Formatting check passed for {len(changed)} changed .tex file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
