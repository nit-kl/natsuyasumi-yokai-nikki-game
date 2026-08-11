"""Build the stylized diorama-view grandma-house exterior."""

from __future__ import annotations

import math
from pathlib import Path

import bpy


COLLECTION_NAME = "NYN_GrandmaExterior"
PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = PROJECT_ROOT / "assets/models/environment/grandma_house_exterior.glb"


def create_material(name, color, roughness=0.9):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1.0)
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = (*color, 1.0)
    principled.inputs["Roughness"].default_value = roughness
    return material


def move_to_collection(obj, collection):
    for owner in list(obj.users_collection):
        owner.objects.unlink(obj)
    collection.objects.link(obj)


def add_box(collection, name, location, scale, material, rotation=(0, 0, 0), bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    if bevel:
        modifier = obj.modifiers.new("SoftEdges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
    move_to_collection(obj, collection)
    return obj


def add_gable(collection, name, y, material):
    mesh = bpy.data.meshes.new(f"{name}Mesh")
    mesh.from_pydata(
        [(-3.76, y, 2.95), (3.76, y, 2.95), (0.0, y, 5.05)],
        [],
        [(0, 1, 2)],
    )
    mesh.materials.append(material)
    obj = bpy.data.objects.new(name, mesh)
    collection.objects.link(obj)
    return obj


def build_exterior():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for collection in list(bpy.data.collections):
        if collection.name != "Collection":
            bpy.data.collections.remove(collection)
    collection = bpy.data.collections.new(COLLECTION_NAME)
    bpy.context.scene.collection.children.link(collection)

    plaster = create_material("SunbakedPlaster", (0.78, 0.62, 0.37))
    wood = create_material("SmokedTimber", (0.14, 0.045, 0.018))
    warm_wood = create_material("EngawaWood", (0.43, 0.16, 0.035))
    roof = create_material("FadedIndigoTile", (0.035, 0.105, 0.16), 0.72)
    roof_edge = create_material("IndigoTileShadow", (0.018, 0.045, 0.07), 0.78)
    paper = create_material("SunlitShoji", (0.94, 0.72, 0.36), 0.82)
    stone = create_material("MossyFoundation", (0.24, 0.27, 0.21))
    noren = create_material("IndigoNoren", (0.035, 0.12, 0.25), 0.95)
    lantern = create_material("PorchLantern", (0.9, 0.3, 0.055), 0.65)

    add_box(collection, "Foundation", (0, 0, -0.1), (4.0, 4.0, 0.1), stone, bevel=0.04)
    add_box(collection, "MainBody", (0, 0, 1.48), (3.72, 3.72, 1.48), plaster)
    add_box(collection, "LowerWoodSkirt", (0, 0, 0.55), (3.79, 3.79, 0.52), warm_wood)

    for x in (-3.78, -2.28, 0.0, 2.28, 3.78):
        add_box(collection, f"FrontPost_{x}", (x, 3.83, 1.55), (0.09, 0.11, 1.55), wood)
    for x in (-3.78, 3.78):
        add_box(collection, f"CornerPost_{x}", (x, 0, 1.55), (0.11, 3.82, 0.11), wood)
    add_box(collection, "FrontTopBeam", (0, 3.84, 2.92), (3.88, 0.12, 0.13), wood)
    add_box(collection, "FrontMidBeam", (0, 3.83, 1.02), (3.86, 0.1, 0.08), wood)
    add_box(collection, "BackTopBeam", (0, -3.82, 2.92), (3.88, 0.1, 0.13), wood)

    for side, x in (("Left", -2.72), ("Right", 2.72)):
        add_box(collection, f"WindowGlow{side}", (x, 3.79, 1.72), (0.82, 0.035, 0.68), paper)
        for offset in (-0.82, 0.0, 0.82):
            add_box(collection, f"WindowV{side}_{offset}", (x + offset, 3.73, 1.72), (0.025, 0.04, 0.72), wood)
        for offset in (-0.66, 0.0, 0.66):
            add_box(collection, f"WindowH{side}_{offset}", (x, 3.73, 1.72 + offset), (0.86, 0.04, 0.025), wood)

    for side, x in (("Left", -0.74), ("Right", 0.74)):
        add_box(collection, f"EntryDoor{side}", (x, 3.76, 1.43), (0.68, 0.04, 1.25), warm_wood)
        add_box(collection, f"EntryPaper{side}", (x, 3.7, 1.58), (0.57, 0.025, 0.88), paper)
        for z in (0.82, 1.42, 2.02, 2.52):
            add_box(collection, f"EntryBar{side}_{z}", (x, 3.65, z), (0.61, 0.025, 0.025), wood)

    add_box(collection, "EngawaDeck", (0, 4.32, 0.33), (3.62, 0.62, 0.12), warm_wood, bevel=0.025)
    for x in (-3.35, -2.22, -1.1, 0.0, 1.1, 2.22, 3.35):
        add_box(collection, f"EngawaBoard_{x}", (x, 4.32, 0.46), (0.022, 0.58, 0.014), wood)
    add_box(collection, "EntranceStep", (0, 5.03, 0.16), (1.22, 0.42, 0.16), stone, bevel=0.06)

    for side, x in (("Left", -0.39), ("Right", 0.39)):
        add_box(collection, f"Noren{side}", (x, 4.01, 2.35), (0.34, 0.025, 0.55), noren, rotation=(0, 0, math.radians(2.0 * (-1 if x < 0 else 1))))

    add_box(collection, "PorchLanternBody", (1.55, 4.06, 2.22), (0.16, 0.15, 0.25), lantern, bevel=0.04)
    add_box(collection, "PorchLanternCap", (1.55, 4.06, 2.51), (0.21, 0.2, 0.045), wood)
    add_box(collection, "PorchLanternBracket", (1.55, 3.92, 2.63), (0.035, 0.18, 0.16), wood)

    add_gable(collection, "FrontGable", 3.73, plaster)
    add_gable(collection, "BackGable", -3.73, plaster)
    add_box(collection, "GableVerticalBeam", (0, 3.79, 3.95), (0.08, 0.07, 1.05), wood)
    add_box(collection, "GableBaseBeam", (0, 3.8, 2.99), (3.72, 0.07, 0.1), wood)

    angle = math.radians(32)
    add_box(collection, "RoofLeft", (-2.2, 0, 3.82), (2.72, 4.75, 0.16), roof, (0, -angle, 0), bevel=0.025)
    add_box(collection, "RoofRight", (2.2, 0, 3.82), (2.72, 4.75, 0.16), roof, (0, angle, 0), bevel=0.025)
    add_box(collection, "RoofRidge", (0, 0, 5.18), (0.22, 4.92, 0.2), roof_edge, bevel=0.08)

    slope = math.tan(angle)
    for index, x in enumerate((-4.25, -3.45, -2.65, -1.85, -1.05, -0.38, 0.38, 1.05, 1.85, 2.65, 3.45, 4.25)):
        z = 5.16 - abs(x) * slope + 0.09
        rotation = angle if x > 0 else -angle
        add_box(collection, f"RoofRib_{index}", (x, 0, z), (0.04, 4.79, 0.045), roof_edge, (0, rotation, 0))
    for index, y in enumerate((-4.55, -3.7, -2.85, -2.0, -1.15, -0.3, 0.55, 1.4, 2.25, 3.1, 3.95, 4.55)):
        add_box(collection, f"RoofRowLeft_{index}", (-2.2, y, 3.86), (2.58, 0.026, 0.035), roof_edge, (0, -angle, 0))
        add_box(collection, f"RoofRowRight_{index}", (2.2, y, 3.86), (2.58, 0.026, 0.035), roof_edge, (0, angle, 0))
    for y in (-4.72, 4.72):
        add_box(collection, f"RoofEave_{y}", (0, y, 3.74), (4.74, 0.11, 0.16), roof_edge, bevel=0.04)

    assert len(collection.all_objects) < 120
    return collection


def export_collection(collection):
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    objects = [obj for obj in collection.all_objects if obj.type in {"MESH", "EMPTY"}]
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = next(obj for obj in objects if obj.type == "MESH")
    bpy.ops.export_scene.gltf(
        filepath=str(OUTPUT_PATH),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
    )
    print(f"Exported stylized grandma house ({len(objects)} objects) to {OUTPUT_PATH}")


if __name__ == "__main__":
    export_collection(build_exterior())
