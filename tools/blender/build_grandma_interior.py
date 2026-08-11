"""Build and export the low-poly grandma-house interior.

Run with Blender 5.x:
blender --background --factory-startup --python tools/blender/build_grandma_interior.py
"""

from pathlib import Path

import bpy


COLLECTION_NAME = "NYN_GrandmaInterior"
PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = PROJECT_ROOT / "assets/models/environment/grandma_interior.glb"


def create_material(name: str, color: tuple[float, float, float]):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1.0)
    material.use_nodes = True
    principled = next(
        (node for node in material.node_tree.nodes if node.type == "BSDF_PRINCIPLED"),
        None,
    )
    if principled:
        base_color = principled.inputs.get("Base Color")
        roughness = principled.inputs.get("Roughness")
        if base_color:
            base_color.default_value = (*color, 1.0)
        if roughness:
            roughness.default_value = 0.8
    return material


def move_to_collection(obj, collection):
    for owner in list(obj.users_collection):
        owner.objects.unlink(obj)
    collection.objects.link(obj)


def add_cube(collection, name, location, scale, material, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=location)
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


def add_cylinder(collection, name, location, radius, depth, material):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=12,
        radius=radius,
        depth=depth,
        location=location,
    )
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(material)
    move_to_collection(obj, collection)
    return obj


def build_interior():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

    collection = bpy.data.collections.new(COLLECTION_NAME)
    bpy.context.scene.collection.children.link(collection)

    dark = create_material("NYN_DarkWood", (0.16, 0.07, 0.025))
    warm = create_material("NYN_WarmWood", (0.40, 0.17, 0.055))
    tatami_a = create_material("NYN_TatamiA", (0.43, 0.48, 0.20))
    tatami_b = create_material("NYN_TatamiB", (0.56, 0.54, 0.25))
    paper = create_material("NYN_ShojiPaper", (0.92, 0.82, 0.60))
    ceramic = create_material("NYN_Ceramic", (0.32, 0.50, 0.43))
    cloth = create_material("NYN_Cloth", (0.38, 0.11, 0.07))

    add_cube(collection, "FloorBase", (0, 0, -0.10), (3.85, 3.85, 0.10), dark)
    for row, y in enumerate((-1.72, 1.72)):
        for index, x in enumerate((-2.60, -0.87, 0.87, 2.60)):
            mat = tatami_a if (index + row) % 2 == 0 else tatami_b
            stem = f"{row}_{index}"
            add_cube(collection, f"Tatami_{stem}", (x, y, 0.04), (0.82, 1.65, 0.06), mat)
            add_cube(collection, f"TatamiEdgeL_{stem}", (x - 0.82, y, 0.105), (0.025, 1.65, 0.015), dark)
            add_cube(collection, f"TatamiEdgeR_{stem}", (x + 0.82, y, 0.105), (0.025, 1.65, 0.015), dark)

    add_cube(collection, "LowTableTop", (0, 0.10, 0.52), (1.35, 0.82, 0.10), warm)
    for x in (-1.10, 1.10):
        for y in (-0.50, 0.70):
            add_cube(collection, f"TableLeg_{x}_{y}", (x, y, 0.27), (0.10, 0.10, 0.25), dark)

    for panel in range(4):
        center_x = -2.70 + panel * 1.80
        add_cube(collection, f"ShojiPaper_{panel}", (center_x, -3.70, 1.40), (0.82, 0.035, 1.25), paper)
        for edge_x in (-0.86, 0.86):
            add_cube(collection, f"ShojiV_{panel}_{edge_x}", (center_x + edge_x, -3.72, 1.40), (0.035, 0.055, 1.32), dark)
        for bar in range(4):
            z = 0.18 + bar * 0.82
            add_cube(collection, f"ShojiH_{panel}_{bar}", (center_x, -3.725, z), (0.86, 0.055, 0.035), dark)
        add_cube(collection, f"ShojiMid_{panel}", (center_x, -3.725, 1.40), (0.035, 0.055, 1.25), dark)

    add_cube(collection, "ShelfBody", (3.25, 1.85, 0.90), (0.48, 1.25, 0.08), dark)
    add_cube(collection, "ShelfLeft", (2.82, 1.85, 0.90), (0.08, 1.25, 0.90), warm)
    add_cube(collection, "ShelfRight", (3.68, 1.85, 0.90), (0.08, 1.25, 0.90), warm)
    for z in (0.10, 0.65, 1.20, 1.75):
        add_cube(collection, f"Shelf_{z}", (3.25, 1.85, z), (0.48, 1.25, 0.06), warm)

    add_cube(collection, "ZabutonFront", (0, 1.48, 0.18), (0.72, 0.56, 0.11), cloth, 0.10)
    add_cube(collection, "ZabutonLeft", (-1.75, 0.10, 0.18), (0.56, 0.72, 0.11), cloth, 0.10)
    add_cube(collection, "TeaTray", (0, 0.10, 0.68), (0.50, 0.34, 0.035), dark, 0.03)
    add_cylinder(collection, "TeaPot", (0, 0.10, 0.82), 0.18, 0.24, ceramic)
    add_cylinder(collection, "TeaCupA", (-0.30, 0.05, 0.78), 0.10, 0.16, ceramic)
    add_cylinder(collection, "TeaCupB", (0.30, 0.05, 0.78), 0.10, 0.16, ceramic)
    add_cube(collection, "SmallChest", (-3.15, 2.55, 0.45), (0.50, 0.62, 0.45), warm)
    add_cylinder(collection, "ShelfVase", (3.18, 1.85, 1.46), 0.17, 0.40, ceramic)
    return collection


def export_collection(collection):
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    export_objects = [obj for obj in collection.all_objects if obj.type in {"MESH", "EMPTY"}]
    for obj in export_objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = next(obj for obj in export_objects if obj.type == "MESH")
    bpy.ops.export_scene.gltf(
        filepath=str(OUTPUT_PATH),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
    )
    print(f"Exported {len(export_objects)} objects to {OUTPUT_PATH}")


if __name__ == "__main__":
    export_collection(build_interior())
