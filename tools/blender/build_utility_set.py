"""Build the reusable utility pole and the vertical-slice wire run."""

import math
from pathlib import Path

import bpy


PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = PROJECT_ROOT / "assets/models/environment"


def material(name, color, roughness=0.82):
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
            principled.inputs["Roughness"].default_value = roughness
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


def cylinder(collection, name, location, radius, depth, mat, vertices=12):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radius,
        depth=depth,
        location=location,
    )
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    move_to(obj, collection)


def export_collection(collection, file_name):
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    objects = [obj for obj in collection.all_objects if obj.type in {"MESH", "EMPTY"}]
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = next(obj for obj in objects if obj.type == "MESH")
    bpy.ops.export_scene.gltf(
        filepath=str(OUTPUT_DIR / file_name),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
    )


def build_pole():
    collection = bpy.data.collections.new("NYN_UtilityPole")
    bpy.context.scene.collection.children.link(collection)
    pole = material("NYNP_WeatheredWood", (0.22, 0.10, 0.035))
    dark = material("NYNP_DarkMetal", (0.055, 0.065, 0.06))
    ceramic = material("NYNP_Ceramic", (0.66, 0.72, 0.62))
    transformer = material("NYNP_Transformer", (0.22, 0.29, 0.25))
    warning = material("NYNP_WarningPlate", (0.72, 0.55, 0.10))

    cylinder(collection, "PoleTrunk", (0, 0, 2.5), 0.15, 5.0, pole)
    cylinder(collection, "PoleTopCap", (0, 0, 5.02), 0.17, 0.10, dark)
    box(collection, "Crossarm", (0, 0, 4.52), (0.82, 0.09, 0.09), pole, bevel=0.025)
    box(collection, "CrossarmBraceL", (-0.43, 0, 4.24), (0.035, 0.045, 0.38), dark, (0, math.radians(-42), 0))
    box(collection, "CrossarmBraceR", (0.43, 0, 4.24), (0.035, 0.045, 0.38), dark, (0, math.radians(42), 0))
    for index, x in enumerate((-0.62, 0, 0.62)):
        cylinder(collection, f"InsulatorBase_{index}", (x, 0, 4.67), 0.075, 0.16, dark, 10)
        cylinder(collection, f"Insulator_{index}", (x, 0, 4.82), 0.09, 0.18, ceramic, 10)
    cylinder(collection, "Transformer", (0.42, -0.03, 3.70), 0.30, 0.72, transformer)
    cylinder(collection, "TransformerTop", (0.42, -0.03, 4.08), 0.23, 0.08, dark)
    box(collection, "TransformerBracket", (0.18, 0, 3.72), (0.32, 0.07, 0.06), dark)
    box(collection, "WarningPlate", (0, -0.155, 2.55), (0.18, 0.018, 0.25), warning, bevel=0.02)
    for z in (1.15, 3.22):
        cylinder(collection, f"MetalBand_{z}", (0, 0, z), 0.16, 0.055, dark)
    return collection


def build_wires():
    collection = bpy.data.collections.new("NYN_UtilityWires")
    bpy.context.scene.collection.children.link(collection)
    wire = material("NYNW_Wire", (0.025, 0.032, 0.03), 0.9)
    poles = [(3.5, -12.0, 4.98), (-3.5, -1.0, 4.98), (3.5, 10.0, 4.98)]
    for line_index, x_offset in enumerate((-0.62, 0.0, 0.62)):
        points = []
        for span_index in range(2):
            start, end = poles[span_index : span_index + 2]
            for step in range(9):
                if span_index and step == 0:
                    continue
                t = step / 8.0
                points.append((
                    start[0] + (end[0] - start[0]) * t + x_offset,
                    start[1] + (end[1] - start[1]) * t,
                    4.98 - math.sin(math.pi * t) * 0.30,
                ))
        curve = bpy.data.curves.new(f"WireCurve_{line_index}", "CURVE")
        curve.dimensions = "3D"
        curve.resolution_u = 1
        curve.bevel_depth = 0.018
        curve.bevel_resolution = 0
        spline = curve.splines.new("POLY")
        spline.points.add(len(points) - 1)
        for point, coordinates in zip(spline.points, points):
            point.co = (*coordinates, 1.0)
        obj = bpy.data.objects.new(f"UtilityWire_{line_index}", curve)
        curve.materials.append(wire)
        collection.objects.link(obj)
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.convert(target="MESH")
        obj.select_set(False)
    return collection


if __name__ == "__main__":
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    export_collection(build_pole(), "utility_pole.glb")
    export_collection(build_wires(), "utility_wires.glb")
