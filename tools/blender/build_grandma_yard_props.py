"""Build and export the grandma-house yard prop set."""

import math
from pathlib import Path

import bpy
from mathutils import Vector


PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = PROJECT_ROOT / "assets/models/environment/grandma_yard_props.glb"


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
            principled.inputs["Roughness"].default_value = 0.78
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


def cylinder(collection, name, location, radius, depth, mat, vertices=12, rotation=(0, 0, 0)):
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
    start_vector = Vector(start)
    end_vector = Vector(end)
    direction = end_vector - start_vector
    obj = cylinder(
        collection,
        name,
        (start_vector + end_vector) * 0.5,
        radius,
        direction.length,
        mat,
        vertices,
    )
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direction.to_track_quat("Z", "Y")


def torus(collection, name, location, major_radius, minor_radius, mat, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(
        major_radius=major_radius,
        minor_radius=minor_radius,
        major_segments=16,
        minor_segments=4,
        location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    move_to(obj, collection)


def ico(collection, name, location, scale, mat, subdivisions=1):
    bpy.ops.mesh.primitive_ico_sphere_add(
        subdivisions=subdivisions,
        radius=1.0,
        location=location,
    )
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    move_to(obj, collection)
    return obj


def build_props():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    collection = bpy.data.collections.new("NYN_GrandmaYardProps")
    bpy.context.scene.collection.children.link(collection)

    wood = material("NYNY_Wood", (0.25, 0.10, 0.03))
    red = material("NYNY_MailboxRed", (0.58, 0.08, 0.035))
    metal = material("NYNY_Metal", (0.25, 0.31, 0.30), 0.35)
    blue = material("NYNY_BucketBlue", (0.12, 0.38, 0.48), 0.15)
    rubber = material("NYNY_Rubber", (0.045, 0.055, 0.04))
    cloth_white = material("NYNY_ClothWhite", (0.90, 0.82, 0.65))
    cloth_blue = material("NYNY_ClothBlue", (0.18, 0.36, 0.58))
    cloth_red = material("NYNY_ClothRed", (0.62, 0.16, 0.10))
    bike_green = material("NYNY_BicycleGreen", (0.12, 0.36, 0.20), 0.25)
    soil = material("NYNY_GardenSoil", (0.24, 0.105, 0.035))
    leaf_dark = material("NYNY_LeafDark", (0.08, 0.28, 0.08))
    leaf_light = material("NYNY_LeafLight", (0.26, 0.48, 0.10))
    hydrangea = material("NYNY_Hydrangea", (0.34, 0.27, 0.62))

    cylinder(collection, "MailboxPost", (3.0, 5.5, 0.62), 0.075, 1.24, wood, 10)
    box(collection, "MailboxBody", (3.0, 5.5, 1.35), (0.36, 0.28, 0.27), red, bevel=0.06)
    box(collection, "MailboxDoor", (3.0, 5.21, 1.34), (0.29, 0.025, 0.20), metal, bevel=0.025)
    box(collection, "MailboxSlot", (3.0, 5.18, 1.43), (0.18, 0.012, 0.018), rubber)
    box(collection, "MailboxFlag", (3.39, 5.5, 1.48), (0.025, 0.025, 0.27), red)
    box(collection, "MailboxFlagTop", (3.46, 5.5, 1.72), (0.09, 0.025, 0.07), red)

    cylinder(collection, "BucketBody", (-2.8, 4.85, 0.30), 0.27, 0.50, blue)
    cylinder(collection, "BucketRim", (-2.8, 4.85, 0.56), 0.30, 0.055, metal)
    torus(collection, "BucketHandle", (-2.8, 4.85, 0.62), 0.31, 0.018, metal, (math.radians(90), 0, 0))
    for side, x in (("L", -0.34), ("R", 0.34)):
        box(collection, f"BootFoot_{side}", (x, 5.02, 0.16), (0.16, 0.29, 0.13), rubber, bevel=0.05)
        box(collection, f"BootShaft_{side}", (x, 5.20, 0.43), (0.17, 0.16, 0.31), rubber, (math.radians(-6), 0, 0), 0.045)

    for y in (-1.65, 1.65):
        cylinder(collection, f"LaundryPole_{y}", (-5.15, y, 1.45), 0.055, 2.90, metal, 10)
        box(collection, f"LaundryFoot_{y}", (-5.15, y, 0.08), (0.28, 0.28, 0.08), metal, bevel=0.03)
    beam(collection, "LaundryLineA", (-5.15, -1.65, 2.45), (-5.15, 1.65, 2.45), 0.012, rubber, 6)
    beam(collection, "LaundryLineB", (-5.15, -1.65, 2.20), (-5.15, 1.65, 2.20), 0.012, rubber, 6)
    box(collection, "LaundryTowel", (-5.17, -0.85, 1.90), (0.025, 0.42, 0.45), cloth_white)
    box(collection, "LaundryShirt", (-5.17, 0.15, 1.96), (0.025, 0.36, 0.38), cloth_blue)
    box(collection, "LaundryCloth", (-5.17, 1.02, 2.02), (0.025, 0.30, 0.31), cloth_red)

    bike_x = 4.72
    for name, y in (("Rear", 0.95), ("Front", 2.35)):
        torus(collection, f"BicycleWheel{name}", (bike_x, y, 0.54), 0.48, 0.035, rubber, (0, math.radians(90), 0))
    beam(collection, "BikeLowerFrame", (bike_x, 0.95, 0.54), (bike_x, 1.68, 0.72), 0.035, bike_green)
    beam(collection, "BikeUpperFrame", (bike_x, 1.68, 0.72), (bike_x, 2.35, 0.54), 0.035, bike_green)
    beam(collection, "BikeSeatTube", (bike_x, 1.68, 0.72), (bike_x, 1.42, 1.15), 0.035, bike_green)
    beam(collection, "BikeFrontFork", (bike_x, 2.35, 0.54), (bike_x, 2.16, 1.20), 0.035, bike_green)
    beam(collection, "BikeTopFrame", (bike_x, 1.42, 1.15), (bike_x, 2.16, 1.20), 0.035, bike_green)
    box(collection, "BikeSeat", (bike_x, 1.38, 1.22), (0.08, 0.22, 0.045), rubber, bevel=0.025)
    beam(collection, "BikeHandlebar", (bike_x - 0.25, 2.18, 1.28), (bike_x + 0.25, 2.18, 1.28), 0.025, metal)
    cylinder(collection, "BikeBasket", (bike_x, 2.52, 1.18), 0.23, 0.30, metal, 10, (math.radians(90), 0, 0))

    for index, (x, y, angle) in enumerate((
        (-0.18, 5.72, -8),
        (0.16, 6.34, 12),
        (-0.12, 6.98, -14),
        (0.2, 7.64, 9),
    )):
        box(
            collection,
            f"EntryStone{index + 1}",
            (x, y, 0.075),
            (0.52, 0.34, 0.075),
            metal,
            (0, 0, math.radians(angle)),
            0.07,
        )

    bed_centers = ((-5.65, 3.35), (-5.65, 4.85), (-5.65, 6.35))
    for bed_index, (x, y) in enumerate(bed_centers):
        box(collection, f"GardenSoil{bed_index + 1}", (x, y, 0.09), (0.78, 0.58, 0.09), soil, bevel=0.035)
        for side, offset_x in (("L", -0.83), ("R", 0.83)):
            box(collection, f"GardenEdge{bed_index + 1}{side}", (x + offset_x, y, 0.14), (0.055, 0.63, 0.14), wood)
        for row in range(2):
            for column in range(3):
                plant_x = x - 0.43 + column * 0.43
                plant_y = y - 0.27 + row * 0.54
                plant_material = leaf_light if (bed_index + row + column) % 2 == 0 else leaf_dark
                ico(
                    collection,
                    f"GardenPlant{bed_index + 1}_{row}_{column}",
                    (plant_x, plant_y, 0.31 + bed_index * 0.025),
                    (0.18, 0.16, 0.23 + bed_index * 0.035),
                    plant_material,
                    1,
                )

    for index, (x, y, scale) in enumerate((
        (5.55, 4.05, 0.42),
        (5.92, 4.3, 0.36),
        (5.45, 4.58, 0.34),
        (6.05, 4.72, 0.4),
    )):
        ico(collection, f"HydrangeaLeaves{index + 1}", (x, y, 0.34), (scale, scale, scale * 0.72), leaf_dark, 1)
        ico(collection, f"HydrangeaBloom{index + 1}", (x, y, 0.65), (scale * 0.55, scale * 0.55, scale * 0.42), hydrangea, 1)

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


if __name__ == "__main__":
    export_collection(build_props())
