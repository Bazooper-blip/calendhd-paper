#!/usr/bin/env python3
"""Bump the pinned larapaper version across the add-on.

Usage: bump-larapaper.py <new-upstream-version>

Edits, relative to the repo root:
  - calendhd-paper/build.yaml   both arch image tags
  - calendhd-paper/Dockerfile   the BUILD_FROM ARG default (kept in sync so
                                manual `docker build` matches the pin)
  - calendhd-paper/config.yaml  add-on version: minor bump, patch reset
                                (patch releases are reserved for add-on-only
                                fixes done by hand)
  - calendhd-paper/CHANGELOG.md new entry linking the upstream release notes

Prints the new add-on version to stdout. Exits 0 without changes if the pin
already matches.
"""

import pathlib
import re
import sys

ADDON = pathlib.Path(__file__).resolve().parents[2] / "calendhd-paper"


def main() -> None:
    new = sys.argv[1].lstrip("v")
    if not re.fullmatch(r"[0-9][\w.\-]*", new):
        sys.exit(f"refusing suspicious version string: {new!r}")

    build = ADDON / "build.yaml"
    dockerfile = ADDON / "Dockerfile"
    config = ADDON / "config.yaml"
    changelog = ADDON / "CHANGELOG.md"

    current = re.search(r"larapaper:([0-9][\w.\-]*)", build.read_text()).group(1)
    if current == new:
        print(current)
        return

    for path in (build, dockerfile):
        path.write_text(path.read_text().replace(f"larapaper:{current}", f"larapaper:{new}"))

    config_text = config.read_text()
    version_line = re.search(r'version: "(\d+)\.(\d+)\.(\d+)"', config_text)
    major, minor, _ = map(int, version_line.groups())
    addon_new = f"{major}.{minor + 1}.0"
    config.write_text(config_text.replace(version_line.group(0), f'version: "{addon_new}"', 1))

    entry = (
        f"## {addon_new}\n\n"
        f"- Update larapaper to {new} "
        f"([release notes](https://github.com/usetrmnl/larapaper/releases/tag/{new})).\n\n"
    )
    changelog.write_text(
        changelog.read_text().replace("# Changelog\n\n", "# Changelog\n\n" + entry, 1)
    )

    print(addon_new)


if __name__ == "__main__":
    main()
