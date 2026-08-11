"""Build and export the country-road detail set."""

import math
from pathlib import Path

import bpy


PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = PROJECT_ROOT / "assets/models/environment/country_road_details.glb"


def material(name, color):
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
            principled.inputs["Roughness"].default_value = 0.92
    return mat


def add_box(collection, name, location, scale, mat, rotation=(0, 0, 0), bevel=0.0):
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
    for owner in list(obj.users_collection):
        owner.objects.unlink(obj)
    collection.objects.link(obj)


def combined_gravel(collection, mat):
    points = (
        (-1.82, -13.2, 0.06, 0.09), (1.76, -12.6, 0.06, 0.07),
        (-1.88, -9.0, 0.06, 0.08), (1.84, -7.1, 0.06, 0.10),
        (-1.78, -4.8, 0.06, 0.06), (1.88, -2.0, 0.06, 0.08),
        (-1.86, 0.4, 0.06, 0.09), (1.82, 2.5, 0.06, 0.06),
        (-1.80, 5.9, 0.06, 0.08), (1.87, 7.7, 0.06, 0.09),
        (-1.84, 10.2, 0.06, 0.07), (1.79, 12.8, 0.06, 0.08),
    )
    vertices, faces = [], []
    for x, y, z, size in points:
        base = len(vertices)
        vertices.extend(((x-size, y-size, z), (x+size, y-size, z), (x, y+size, z), (x, y, z+size)))
        faces.extend(((base, base+1, base+2), (base, base+3, base+1), (base+1, base+3, base+2), (base+2, base+3, base)))
    mesh = bpy.data.meshes.new("RoadsideGravelMesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(mat)
    collection.objects.link(bpy.data.objects.new("RoadsideGravel", mesh))


def combined_grass(collection, mat):
    tufts = ((-4.08, -12.0), (4.15, -10.2), (-4.2, -6.4), (4.05, -1.2), (-4.12, 2.8), (4.18, 6.8), (-4.05, 10.7))
    vertices, faces = [], []
    for index, (x, y) in enumerate(tufts):
        height = 0.38 + (index % 3) * 0.07
        width = 0.20
        base = len(vertices)
        vertices.extend(((x-width, y, 0.02), (x+width, y, 0.02), (x, y, height),
                         (x, y-width, 0.02), (x, y+width, 0.02), (x, y, height*0.92)))
        faces.extend(((base, base+1, base+2), (base+3, base+4, base+5)))
    mesh = bpy.data.meshes.new("RoadsideGrassMesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(mat)
    collection.objects.link(bpy.data.objects.new("RoadsideGrassTufts", mesh))


def build_details():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    collection = bpy.data.collections.new("NYN_CountryRoadDetails")
    bpy.context.scene.collection.children.link(collection)
    concrete = material("NYND_AgedConcrete", (0.39, 0.40, 0.34))
    concrete_dark = material("NYND_ConcreteEdge", (0.24, 0.27, 0.24))
    dirt = material("NYND_DarkDirt", (0.31, 0.23, 0.12))
    gravel = material("NYND_Gravel", (0.48, 0.44, 0.34))
    grass = material("NYND_Grass", (0.22, 0.43, 0.10))
    wood = material("NYND_BoundaryWood", (0.29, 0.13, 0.04))

    add_box(collection, "WheelTrackLeft", (-0.58, -2.0, 0.038), (0.24, 15.7, 0.012), dirt)
    add_box(collection, "WheelTrackRight", (0.58, -2.0, 0.038), (0.24, 15.7, 0.012), dirt)
    for index, (x, y, sx, sy, angle) in enumerate((
        (-0.20, -10.4, 0.52, 0.72, 8),
        (0.35, 3.6, 0.43, 0.58, -12),
        (-0.42, 10.8, 0.36, 0.66, 5),
    )):
        add_box(collection, f"RoadPatch_{index}", (x, y, 0.052), (sx, sy, 0.012), dirt, (0, 0, math.radians(angle)), 0.08)

    for side, inner_x, outer_x in (("L", -2.48, -3.72), ("R", 2.48, 3.72)):
        add_box(collection, f"ChannelInner_{side}", (inner_x, -3.0, 0.11), (0.10, 10.55, 0.11), concrete, bevel=0.025)
        add_box(collection, f"ChannelOuter_{side}", (outer_x, -3.0, 0.11), (0.10, 10.55, 0.11), concrete_dark, bevel=0.025)
        for index, y in enumerate((-11.8, -4.2, 4.4)):
            add_box(collection, f"CrossingSlab_{side}_{index}", ((inner_x + outer_x) * 0.5, y, 0.22), (0.72, 0.48, 0.09), concrete, bevel=0.035)

    for index, (x, y) in enumerate(((-4.0, -11.0), (-4.05, 1.5), (-4.0, 9.8), (4.0, -7.5), (4.05, 5.3), (4.0, 11.5))):
        add_box(collection, f"BoundaryStake_{index}", (x, y, 0.42), (0.055, 0.055, 0.42), wood, (0, math.radians((index % 3 - 1) * 5), math.radians((-1) ** index * 3)), 0.018)
    combined_gravel(collection, gravel)
    combined_grass(collection, grass)
    return collection


def export_collection(collection):
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    objects = [obj for obj in collection.all_objects if obj.type in {"MESH", "EMPTY"}]
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = next(obj for obj in objects if obj.type == "MESH")
    bpy.ops.export_scene.gltf(filepath=str(OUTPUT_PATH), export_format="GLB", use_selection=True, export_apply=True)


if __name__ == "__main__":
    export_collection(build_details())
