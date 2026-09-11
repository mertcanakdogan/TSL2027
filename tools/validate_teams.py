"""Validate the synthetic team seed used by the first TSL2027 vertical slice."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEAM_FILE = ROOT / "data" / "teams.json"


def main() -> None:
    payload = json.loads(TEAM_FILE.read_text(encoding="utf-8"))
    teams = payload["teams"]

    assert len(teams) == 18, f"Expected 18 teams, got {len(teams)}"

    ids = [team["id"] for team in teams]
    assert len(ids) == len(set(ids)), "Team IDs must be unique"

    for team in teams:
        assert team["id"], "Every team needs an id"
        assert team["name"], "Every team needs a name"
        assert 1 <= int(team["strength"]) <= 99, team

    print(f"OK: {len(teams)} teams validated")


if __name__ == "__main__":
    main()
