"""Build and export the old concrete bridge used in the vertical slice."""

import math
from pathlib import Path

import bpy


PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = PROJECT_ROOT / "assets/models/environment/old_concrete_bridge.glb"


def material(name, color, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    principled = next(
        (node for node in mat.node_tree.nodes if node.type == "BSDF_PRINCIPLED"),
        None,
    )
    if principled:
        if principled.inputs.get("Base Color"):
            principled.inputs["Base Color"].default_value = (*color, 1.0)
        if principled.inputs.get("Roughness"):
            principled.inputs["Roughness"].default_value = 0.9
        if principled.inputs.get("Metallic"):
            principled.inputs["Metallic"].default_value = metallic
    return mat


def add_box(collection, name, location, scale, mat, rotation=(0, 0, 0), bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("WornEdges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
    for owner in list(obj.users_collection):
        owner.objects.unlink(obj)
    collection.objects.link(obj)


def build_bridge():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    collection = bpy.data.collections.new("NYN_OldBridge")
    bpy.context.scene.collection.children.link(collection)

    concrete = material("NYNB_AgedConcrete", (0.38, 0.39, 0.34))
    light = material("NYNB_SunBleachedConcrete", (0.52, 0.50, 0.41))
    dark = material("NYNB_RepairPatch", (0.20, 0.23, 0.21))
    moss = material("NYNB_Moss", (0.20, 0.30, 0.10))
    rust = material("NYNB_RustMetal", (0.36, 0.13, 0.045), 0.25)

    add_box(collection, "BridgeDeck", (0, 0, 0.02), (1.50, 3.50, 0.13), concrete, bevel=0.035)
    add_box(collection, "DeckUnderside", (0, 0, -0.18), (1.38, 3.15, 0.10), dark)
    for y in (-3.18, 3.18):
        add_box(collection, f"Abutment_{y}", (0, y, -0.12), (1.75, 0.32, 0.36), dark, bevel=0.04)
    for index, y in enumerate((-2.80, 0.0, 2.80)):
        add_box(collection, f"ExpansionJoint_{index}", (0, y, 0.16), (1.42, 0.025, 0.012), dark)
    add_box(collection, "RepairPatchA", (-0.55, -1.05, 0.16), (0.42, 0.34, 0.014), dark, (0, 0, math.radians(7)), 0.05)
    add_box(collection, "RepairPatchB", (0.62, 1.42, 0.16), (0.31, 0.48, 0.014), light, (0, 0, math.radians(-9)), 0.04)

    for side, x in (("L", -1.38), ("R", 1.38)):
        for index, y in enumerate((-2.75, -1.38, 0.0, 1.38, 2.75)):
            add_box(collection, f"RailPost_{side}_{index}", (x, y, 0.66), (0.105, 0.13, 0.58), concrete, bevel=0.035)
        add_box(collection, f"RailTop_{side}", (x, 0, 1.16), (0.13, 3.10, 0.105), light, bevel=0.04)
        add_box(collection, f"RailMid_{side}", (x, 0, 0.68), (0.09, 3.02, 0.075), concrete, bevel=0.025)
        inward = 0.14 if x < 0 else -0.14
        add_box(collection, f"MossEdge_{side}", (x + inward, 0.28, 0.185), (0.055, 2.75, 0.018), moss)
    add_box(collection, "BridgeNamePlate", (-1.505, -0.75, 0.88), (0.018, 0.34, 0.19), light, bevel=0.025)
    for y in (-2.95, 2.95):
        add_box(collection, f"RustTie_{y}", (1.50, y, 0.52), (0.025, 0.22, 0.28), rust)
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


if __name__ == "__main__":
    export_collection(build_bridge())
