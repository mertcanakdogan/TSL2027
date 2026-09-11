"""Validate teams, synthetic players, and competition rules as one data pack."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"

EXPECTED_POSITION_COUNTS = {"GK": 2, "DF": 6, "MF": 6, "FW": 4}
REQUIRED_ATTRIBUTES = {
    "GK": {"reflexes", "handling", "aerial_control", "one_on_one", "positioning", "distribution", "decisions"},
    "DF": {"positioning", "marking", "tackling", "interceptions", "aerial", "pace", "strength", "passing"},
    "MF": {"passing", "vision", "decisions", "ball_control", "press_resistance", "stamina", "work_rate", "tackling", "long_shots"},
    "FW": {"finishing", "composure", "off_ball_movement", "dribbling", "acceleration", "strength", "aerial", "decisions"},
}


def _required_int(payload: dict, path: str, errors: list[str]) -> int | None:
    current: object = payload
    for part in path.split("."):
        if not isinstance(current, dict) or part not in current:
            errors.append(f"missing rule: {path}")
            return None
        current = current[part]
    if type(current) is not int:
        errors.append(f"rule must be an integer: {path}")
        return None
    return current


def validate_payloads(team_payload: dict, player_payload: dict, rules_payload: dict) -> list[str]:
    errors: list[str] = []
    for name, payload in (("teams", team_payload), ("players", player_payload), ("rules", rules_payload)):
        if not isinstance(payload, dict):
            errors.append(f"{name} payload must be an object")
            continue
        for field in ("schema_version", "season", "source_type", "source_note"):
            if not isinstance(payload.get(field), str) or not payload[field]:
                errors.append(f"{name} payload missing metadata: {field}")

    teams = team_payload.get("teams") if isinstance(team_payload, dict) else None
    players = player_payload.get("players") if isinstance(player_payload, dict) else None
    if not isinstance(teams, list):
        errors.append("teams must be a list")
        teams = []
    if not isinstance(players, list):
        errors.append("players must be a list")
        players = []

    team_ids: list[str] = []
    for index, team in enumerate(teams):
        if not isinstance(team, dict):
            errors.append(f"team {index} must be an object")
            continue
        team_id = team.get("id")
        if not isinstance(team_id, str) or not team_id:
            errors.append(f"team {index} has invalid id")
            continue
        if team_id in team_ids:
            errors.append(f"duplicate team id: {team_id}")
        team_ids.append(team_id)
        if not isinstance(team.get("name"), str) or not team["name"]:
            errors.append(f"team {team_id} has invalid name")
        if type(team.get("strength")) is not int or not 1 <= team["strength"] <= 99:
            errors.append(f"team {team_id} strength must be an integer in 1..99")

    if len(teams) != 18:
        errors.append(f"expected 18 teams, got {len(teams)}")

    player_ids: set[str] = set()
    position_counts: dict[str, dict[str, int]] = {team_id: {} for team_id in team_ids}
    for index, player in enumerate(players):
        if not isinstance(player, dict):
            errors.append(f"player {index} must be an object")
            continue
        player_id = player.get("id")
        if not isinstance(player_id, str) or not player_id:
            errors.append(f"player {index} has invalid id")
        elif player_id in player_ids:
            errors.append(f"duplicate player id: {player_id}")
        else:
            player_ids.add(player_id)

        team_id = player.get("team_id")
        if not isinstance(team_id, str) or team_id not in team_ids:
            errors.append(f"player {player_id or index} references unknown team: {team_id}")

        position = player.get("position")
        if position not in REQUIRED_ATTRIBUTES:
            errors.append(f"player {player_id or index} has unknown position: {position}")
            required_attributes: set[str] = set()
        else:
            if isinstance(team_id, str) and team_id in team_ids:
                team_counts = position_counts.setdefault(team_id, {})
                team_counts[position] = team_counts.get(position, 0) + 1
            required_attributes = REQUIRED_ATTRIBUTES[position]

        attributes = player.get("attributes")
        if not isinstance(attributes, dict):
            errors.append(f"player {player_id or index} attributes must be an object")
            attributes = {}
        if set(attributes) != required_attributes:
            errors.append(f"player {player_id or index} attributes do not match position {position}")
        for attribute, value in attributes.items():
            if type(value) is not int or not 1 <= value <= 99:
                errors.append(f"player {player_id or index} attribute {attribute} must be an integer in 1..99")

        if type(player.get("age")) is not int or not 15 <= player["age"] <= 45:
            errors.append(f"player {player_id or index} age must be an integer in 15..45")

    if len(players) != len(teams) * sum(EXPECTED_POSITION_COUNTS.values()):
        errors.append(f"expected {len(teams) * 18} players, got {len(players)}")

    for team_id in team_ids:
        if position_counts.get(team_id, {}) != EXPECTED_POSITION_COUNTS:
            errors.append(
                f"team {team_id} position counts must be {EXPECTED_POSITION_COUNTS}, got {position_counts.get(team_id, {})}"
            )

    expected_rules = {
        "competition.team_count": len(teams),
        "competition.rounds": 2,
        "competition.weeks": 34,
        "competition.matchday_squad_size": 21,
        "competition.max_substitutions": 5,
        "squad.max_a_team_players": 28,
        "squad.max_foreign_players": 14,
        "squad.min_national_team_eligible_players": 14,
        "squad.min_young_national_team_eligible_players": 4,
        "squad.max_goalkeepers": 3,
        "squad.min_eligible_goalkeepers": 2,
        "economy.initial_balance_base": 12_000_000,
        "economy.initial_balance_per_strength": 250_000,
        "economy.weekly_revenue_base": 250_000,
        "economy.weekly_revenue_per_strength": 15_000,
        "economy.weekly_wage_budget_base": 800_000,
        "economy.weekly_wage_budget_per_strength": 10_000,
        "economy.transfer_window_end_week": 8,
        "economy.max_roster_size": 28,
    }
    for path, expected in expected_rules.items():
        actual = _required_int(rules_payload, path, errors)
        if actual is not None and actual != expected:
            errors.append(f"rule {path} must be {expected}, got {actual}")

    return errors


def _read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-dir", type=Path, default=DATA_DIR)
    args = parser.parse_args()
    try:
        teams = _read_json(args.data_dir / "teams.json")
        players = _read_json(args.data_dir / "players.json")
        rules = _read_json(args.data_dir / "game_rules.json")
    except (OSError, json.JSONDecodeError) as error:
        print(f"ERROR: unable to read data pack: {error}")
        return 1

    errors = validate_payloads(teams, players, rules)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1

    print(f"OK: {len(teams['teams'])} teams and {len(players['players'])} players validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
