"""Build and export the vertical-slice riverbank prop set."""

import math
from pathlib import Path

import bpy
from mathutils import Vector


PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = PROJECT_ROOT / "assets/models/environment/riverbank_props.glb"


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
            principled.inputs["Roughness"].default_value = 0.84
        if principled.inputs.get("Metallic"):
            principled.inputs["Metallic"].default_value = metallic
    return mat


def move_to(obj, collection):
    for owner in list(obj.users_collection):
        owner.objects.unlink(obj)
    collection.objects.link(obj)


def box(collection, name, location, scale, mat, rotation=(0, 0, 0), bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("SoftEdges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
    move_to(obj, collection)


def cylinder(collection, name, location, radius, depth, mat, vertices=10, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radius,
        depth=depth,
        location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    move_to(obj, collection)
    return obj


def beam(collection, name, start, end, radius, mat, vertices=8):
    a, b = Vector(start), Vector(end)
    direction = b - a
    obj = cylinder(collection, name, (a + b) * 0.5, radius, direction.length, mat, vertices)
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direction.to_track_quat("Z", "Y")


def build_props():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    collection = bpy.data.collections.new("NYN_RiverbankProps")
    bpy.context.scene.collection.children.link(collection)

    wood = material("NYNR_WeatheredWood", (0.24, 0.12, 0.045))
    board = material("NYNR_FadedBoard", (0.45, 0.32, 0.15))
    paint = material("NYNR_FadedPaint", (0.60, 0.16, 0.08))
    metal = material("NYNR_CanMetal", (0.38, 0.43, 0.40), 0.55)
    can_blue = material("NYNR_CanBlue", (0.12, 0.34, 0.48), 0.25)
    can_red = material("NYNR_CanRed", (0.55, 0.10, 0.055), 0.25)
    stone_a = material("NYNR_StoneA", (0.28, 0.30, 0.27))
    stone_b = material("NYNR_StoneB", (0.38, 0.37, 0.30))
    net_wood = material("NYNR_NetHandle", (0.38, 0.18, 0.055))
    net_ring = material("NYNR_NetRing", (0.17, 0.22, 0.20), 0.35)

    for x in (3.75, 4.65):
        cylinder(collection, f"SignPost_{x}", (x, 12.8, 0.72), 0.065, 1.44, wood, 8)
    box(collection, "OldWarningSign", (4.2, 12.8, 1.26), (0.72, 0.07, 0.48), board, (0, math.radians(-3), math.radians(2)), 0.035)
    box(collection, "SignPaintSlashA", (4.05, 12.72, 1.29), (0.035, 0.012, 0.30), paint, (0, math.radians(-3), math.radians(-34)))
    box(collection, "SignPaintSlashB", (4.35, 12.72, 1.29), (0.035, 0.012, 0.30), paint, (0, math.radians(-3), math.radians(34)))
    box(collection, "SignPaintLine", (4.2, 12.71, 0.98), (0.34, 0.012, 0.035), paint)

    cylinder(collection, "CanUpright", (1.35, 13.15, 0.16), 0.11, 0.30, can_blue, 12, (0, 0, math.radians(4)))
    cylinder(collection, "CanSide", (1.68, 13.35, 0.12), 0.105, 0.30, can_red, 12, (math.radians(82), 0, math.radians(18)))
    cylinder(collection, "CanCrushed", (1.10, 13.48, 0.08), 0.12, 0.14, metal, 10, (math.radians(70), 0, math.radians(-25)))
    cylinder(collection, "CanTopA", (1.35, 13.15, 0.315), 0.075, 0.012, metal, 12)
    cylinder(collection, "CanTopB", (1.68, 13.50, 0.14), 0.075, 0.012, metal, 12)

    stones = (
        ("CairnBaseA", (-4.15, 13.35, 0.18), (0.42, 0.31, 0.18), stone_a),
        ("CairnBaseB", (-3.68, 13.45, 0.16), (0.34, 0.28, 0.16), stone_b),
        ("CairnMiddle", (-3.92, 13.40, 0.43), (0.31, 0.25, 0.16), stone_b),
        ("CairnTop", (-3.92, 13.40, 0.66), (0.20, 0.16, 0.12), stone_a),
    )
    for name, location, scale, mat in stones:
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0, location=location)
        obj = bpy.context.object
        obj.name = name
        obj.scale = scale
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        obj.data.materials.append(mat)
        move_to(obj, collection)

    beam(collection, "InsectNetHandle", (-2.55, 13.12, 0.10), (-1.76, 13.00, 1.46), 0.035, net_wood, 10)
    ring_center = (-1.60, 12.98, 1.70)
    bpy.ops.mesh.primitive_torus_add(
        major_radius=0.36,
        minor_radius=0.025,
        major_segments=16,
        minor_segments=4,
        location=ring_center,
        rotation=(math.radians(90), math.radians(-10), 0),
    )
    ring = bpy.context.object
    ring.name = "InsectNetRing"
    ring.data.materials.append(net_ring)
    move_to(ring, collection)
    for index, end in enumerate(((-1.86, 12.97, 1.46), (-1.34, 12.97, 1.46), (-1.60, 12.97, 1.34))):
        beam(collection, f"NetMeshLine_{index}", ring_center, end, 0.009, net_ring, 6)
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
    export_collection(build_props())
