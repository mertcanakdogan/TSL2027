"""Tests for the Phase 1 synthetic data contract."""

from __future__ import annotations

import copy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
TOOLS_DIR = ROOT / "tools"
sys.path.insert(0, str(TOOLS_DIR))

from validate_data_pack import validate_payloads  # noqa: E402


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


class DataPackTests(unittest.TestCase):
    def setUp(self) -> None:
        self.teams = read_json(DATA_DIR / "teams.json")
        self.players = read_json(DATA_DIR / "players.json")
        self.rules = read_json(DATA_DIR / "game_rules.json")

    def test_checked_in_data_pack_is_valid(self) -> None:
        self.assertEqual(validate_payloads(self.teams, self.players, self.rules), [])

    def test_generation_is_deterministic(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output_dir = Path(directory)
            command = [
                sys.executable,
                str(TOOLS_DIR / "generate_synthetic_data.py"),
                "--output-dir",
                str(output_dir),
            ]
            first = subprocess.run(command, check=True, capture_output=True, text=True)
            first_players = (output_dir / "players.json").read_bytes()
            first_rules = (output_dir / "game_rules.json").read_bytes()
            second = subprocess.run(command, check=True, capture_output=True, text=True)

            self.assertEqual(first.returncode, 0)
            self.assertEqual(second.returncode, 0)
            self.assertEqual(first_players, (output_dir / "players.json").read_bytes())
            self.assertEqual(first_rules, (output_dir / "game_rules.json").read_bytes())
            self.assertEqual(first_players, (DATA_DIR / "players.json").read_bytes())
            self.assertEqual(first_rules, (DATA_DIR / "game_rules.json").read_bytes())

    def test_every_team_has_required_position_counts(self) -> None:
        players_by_team: dict[str, list[dict]] = {}
        for player in self.players["players"]:
            players_by_team.setdefault(player["team_id"], []).append(player)

        expected = {"GK": 2, "DF": 6, "MF": 6, "FW": 4}
        for team in self.teams["teams"]:
            players = players_by_team[team["id"]]
            counts: dict[str, int] = {}
            for player in players:
                counts[player["position"]] = counts.get(player["position"], 0) + 1
            self.assertEqual(len(players), 18)
            self.assertEqual(counts, expected)

    def test_player_attributes_are_position_specific_and_bounded(self) -> None:
        required = {
            "GK": {"reflexes", "handling", "aerial_control", "one_on_one", "positioning", "distribution", "decisions"},
            "DF": {"positioning", "marking", "tackling", "interceptions", "aerial", "pace", "strength", "passing"},
            "MF": {"passing", "vision", "decisions", "ball_control", "press_resistance", "stamina", "work_rate", "tackling", "long_shots"},
            "FW": {"finishing", "composure", "off_ball_movement", "dribbling", "acceleration", "strength", "aerial", "decisions"},
        }
        for player in self.players["players"]:
            attributes = player["attributes"]
            self.assertEqual(set(attributes), required[player["position"]])
            self.assertTrue(all(type(value) is int and 1 <= value <= 99 for value in attributes.values()))

    def test_rules_are_explicit(self) -> None:
        competition = self.rules["competition"]
        squad = self.rules["squad"]
        economy = self.rules["economy"]
        self.assertEqual(competition["team_count"], 18)
        self.assertEqual(competition["weeks"], 34)
        self.assertEqual(competition["matchday_squad_size"], 21)
        self.assertEqual(competition["max_substitutions"], 5)
        self.assertEqual(squad["max_a_team_players"], 28)
        self.assertEqual(economy["initial_balance_base"], 12_000_000)
        self.assertEqual(economy["transfer_window_end_week"], 8)
        self.assertEqual(economy["max_roster_size"], 28)

    def test_data_pack_metadata_is_explicit(self) -> None:
        for payload in (self.teams, self.players, self.rules):
            for field in ("schema_version", "season", "source_type", "source_note"):
                self.assertIsInstance(payload[field], str)
                self.assertTrue(payload[field])

    def test_validator_rejects_unknown_team_reference(self) -> None:
        payload = copy.deepcopy(self.players)
        payload["players"][0]["team_id"] = "unknown_team"
        errors = validate_payloads(self.teams, payload, self.rules)
        self.assertTrue(any("unknown team" in error for error in errors))

    def test_validator_rejects_duplicate_player_id(self) -> None:
        payload = copy.deepcopy(self.players)
        payload["players"][1]["id"] = payload["players"][0]["id"]
        errors = validate_payloads(self.teams, payload, self.rules)
        self.assertTrue(any("duplicate player id" in error for error in errors))

    def test_validator_rejects_out_of_range_attribute(self) -> None:
        payload = copy.deepcopy(self.players)
        payload["players"][0]["attributes"]["reflexes"] = 100
        errors = validate_payloads(self.teams, payload, self.rules)
        self.assertTrue(any("attribute" in error and "1..99" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
