"""Validate the first visual-reboot GLB assets without loading Blender."""

from __future__ import annotations

import json
import struct
from pathlib import Path


def load_glb(path: Path) -> dict:
    with path.open("rb") as file:
        magic, version, total_length = struct.unpack("<4sII", file.read(12))
        assert magic == b"glTF" and version == 2
        assert total_length == path.stat().st_size
        chunk_length, chunk_type = struct.unpack("<I4s", file.read(8))
        assert chunk_type == b"JSON"
        return json.loads(file.read(chunk_length).decode("utf-8"))


def validate(path: Path, required_nodes: set[str], material_limit: int, size_limit: int) -> None:
    assert path.exists(), f"Missing {path}"
    assert path.stat().st_size < size_limit, f"{path} exceeds {size_limit} bytes"
    document = load_glb(path)
    names = {node.get("name") for node in document.get("nodes", [])}
    assert required_nodes <= names, f"{path} missing {sorted(required_nodes - names)}"
    assert len(document.get("materials", [])) <= material_limit
    assert document.get("meshes"), f"{path} has no meshes"


def main() -> None:
    validate(
        Path("assets/models/characters/protagonist.glb"),
        {"CharacterRig", "HatBrim", "HatCrown", "Satchel", "LeftArm", "RightLeg"},
        7,
        120_000,
    )
    validate(
        Path("assets/models/environment/grandma_house_exterior.glb"),
        {"RoofLeft", "RoofRight", "FrontGable", "EngawaDeck", "NorenLeft", "PorchLanternBody"},
        9,
        350_000,
    )
    validate(
        Path("assets/models/characters/grandma.glb"),
        {"GrandmaRig", "Head", "HairBun", "Apron", "WaistSash", "LeftArm", "RightArm", "LeftHand", "RightHand"},
        7,
        120_000,
    )
    validate(
        Path("assets/models/environment/grandma_yard_props.glb"),
        {"MailboxBody", "LaundryTowel", "BicycleWheelRear", "EntryStone1", "GardenSoil1", "HydrangeaBloom1"},
        13,
        300_000,
    )
    print("Visual reboot GLB validation passed.")


if __name__ == "__main__":
    main()
