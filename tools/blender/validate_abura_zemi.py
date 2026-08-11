"""Validate the generated cicada GLB without loading Blender."""

from __future__ import annotations

import json
import struct
import sys
from pathlib import Path


def load_glb_json(path: Path) -> dict:
    with path.open("rb") as file:
        magic, version, total_length = struct.unpack("<4sII", file.read(12))
        assert magic == b"glTF" and version == 2
        assert total_length == path.stat().st_size
        chunk_length, chunk_type = struct.unpack("<I4s", file.read(8))
        assert chunk_type == b"JSON"
        return json.loads(file.read(chunk_length).decode("utf-8"))


def main() -> None:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("assets/models/insects/abura_zemi.glb")
    assert path.exists(), f"Missing model: {path}"
    assert path.stat().st_size < 200_000, "Cicada GLB exceeds 200 KB"
    document = load_glb_json(path)
    node_names = {node.get("name") for node in document.get("nodes", [])}
    required = {"AburaZemi", "Thorax", "Abdomen", "Head", "LeftWing", "RightWing"}
    assert required <= node_names, f"Missing nodes: {sorted(required - node_names)}"
    assert 1 <= len(document.get("meshes", [])) <= 32
    assert len(document.get("materials", [])) == 5
    print(f"Abura-zemi GLB validation passed ({path.stat().st_size} bytes).")


if __name__ == "__main__":
    main()
