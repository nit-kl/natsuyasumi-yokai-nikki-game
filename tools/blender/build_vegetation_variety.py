"""Build and export the reusable vegetation-variety set."""

from pathlib import Path
import math

import bpy
from mathutils import Vector


PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = PROJECT_ROOT / "assets/models/environment"


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
            principled.inputs["Roughness"].default_value = 0.9
    return mat


def move_to(obj, collection):
    for owner in list(obj.users_collection):
        owner.objects.unlink(obj)
    collection.objects.link(obj)


def cylinder(collection, name, location, radius, depth, mat, vertices=10):
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
    return obj


def beam(collection, name, start, end, radius, mat):
    a, b = Vector(start), Vector(end)
    direction = b - a
    obj = cylinder(collection, name, (a + b) * 0.5, radius, direction.length, mat, 8)
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direction.to_track_quat("Z", "Y")


def ico(collection, name, location, scale, mat):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    move_to(obj, collection)


def build_tree(materials):
    bark, leaf_dark, leaf_mid, leaf_light = materials
    collection = bpy.data.collections.new("NYN_SummerTreeVariant")
    bpy.context.scene.collection.children.link(collection)
    cylinder(collection, "TreeTrunk", (0, 0, 1.75), 0.25, 3.50, bark)
    for index, end in enumerate(((-0.72, 0.08, 3.42), (0.60, -0.18, 3.70), (0.22, 0.52, 3.55))):
        beam(collection, f"TreeBranch_{index}", (0, 0, 2.45), end, 0.10, bark)
    for name, location, scale, mat in (
        ("CanopyLeft", (-0.82, 0.05, 3.72), (1.05, 0.78, 0.82), leaf_dark),
        ("CanopyCenter", (0.05, 0.04, 4.12), (1.18, 0.92, 0.88), leaf_mid),
        ("CanopyRight", (0.88, -0.18, 3.82), (0.92, 0.72, 0.76), leaf_light),
        ("CanopyBack", (0.10, 0.68, 3.66), (0.86, 0.66, 0.72), leaf_dark),
    ):
        ico(collection, name, location, scale, mat)
    return collection


def build_bamboo(bamboo, node_mat, leaf_mat):
    collection = bpy.data.collections.new("NYN_BambooCluster")
    bpy.context.scene.collection.children.link(collection)
    stems = ((-0.42, -0.20, 3.75), (-0.12, 0.18, 4.15), (0.22, -0.10, 3.45),
             (0.48, 0.22, 3.95), (0.08, -0.42, 3.65), (-0.52, 0.34, 3.38))
    for index, (x, y, height) in enumerate(stems):
        cylinder(collection, f"BambooStem_{index}", (x, y, height * 0.5), 0.055 + (index % 2) * 0.008, height, bamboo, 8)
        for node_index, factor in enumerate((0.28, 0.52, 0.76)):
            cylinder(collection, f"BambooNode_{index}_{node_index}", (x, y, height * factor), 0.071, 0.045, node_mat, 8)
    vertices, faces = [], []
    for x, y, height in stems:
        for dx, dy, dz in ((0.42, 0.05, -0.10), (-0.34, 0.16, -0.28), (0.12, -0.40, -0.45)):
            center = Vector((x + dx * 0.45, y + dy * 0.45, height + dz))
            direction = Vector((dx, dy, 0)).normalized()
            side = Vector((-direction.y, direction.x, 0)) * 0.10
            base = len(vertices)
            vertices.extend((center - direction * 0.18 - side, center - direction * 0.18 + side, center + direction * 0.30))
            faces.append((base, base + 1, base + 2))
    mesh = bpy.data.meshes.new("BambooLeavesMesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(leaf_mat)
    collection.objects.link(bpy.data.objects.new("BambooLeaves", mesh))
    return collection


def build_shrubs(stem, dark, light):
    collection = bpy.data.collections.new("NYN_ShrubPair")
    bpy.context.scene.collection.children.link(collection)
    for index, (location, scale, mat) in enumerate((
        ((-0.45, 0.02, 0.48), (0.68, 0.58, 0.48), dark),
        ((0.12, -0.08, 0.58), (0.62, 0.50, 0.56), light),
        ((0.70, 0.10, 0.36), (0.72, 0.42, 0.34), dark),
        ((1.18, -0.02, 0.30), (0.48, 0.36, 0.28), light),
    )):
        ico(collection, f"ShrubMass_{index}", location, scale, mat)
    for index, x in enumerate((-0.60, 0.0, 0.72, 1.10)):
        cylinder(collection, f"ShrubStem_{index}", (x, 0, 0.21), 0.035, 0.42, stem, 6)
    return collection


def build_grass(grass, seed):
    collection = bpy.data.collections.new("NYN_WildGrassCluster")
    bpy.context.scene.collection.children.link(collection)
    specs = []
    for i in range(9):
        specs.append((-0.72 + (i % 3) * 0.16, -0.18 + (i // 3) * 0.16, 0.48 + (i % 3) * 0.09, -0.05 + (i % 2) * 0.10))
    for i in range(8):
        angle = -0.9 + i * 0.25
        specs.append((0.05 + math.sin(angle) * 0.18, 0.02 + math.cos(angle) * 0.12, 0.42 + (i % 2) * 0.10, math.sin(angle) * 0.22))
    for i in range(7):
        specs.append((0.58 + (i % 3) * 0.16, -0.16 + (i // 3) * 0.16, 0.60 + (i % 3) * 0.10, -0.08 + (i % 3) * 0.08))
    vertices, faces = [], []
    for x, y, height, lean in specs:
        base = len(vertices)
        width = 0.035
        vertices.extend(((x-width, y, 0), (x+width, y, 0), (x+lean, y, height),
                         (x, y-width, 0), (x, y+width, 0), (x+lean, y, height * 0.94)))
        faces.extend(((base, base+1, base+2), (base+3, base+4, base+5)))
    mesh = bpy.data.meshes.new("WildGrassMesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(grass)
    collection.objects.link(bpy.data.objects.new("WildGrassBlades", mesh))
    vertices, faces = [], []
    for i in range(7):
        x = 0.58 + (i % 3) * 0.16 + (-0.08 + (i % 3) * 0.08)
        y = -0.16 + (i // 3) * 0.16
        z = 0.60 + (i % 3) * 0.10
        size, base = 0.055, len(vertices)
        vertices.extend(((x-size,y,z),(x+size,y,z),(x,y-size,z),(x,y+size,z),(x,y,z+size*1.5)))
        faces.extend(((base,base+2,base+4),(base+2,base+1,base+4),(base+1,base+3,base+4),(base+3,base,base+4)))
    mesh = bpy.data.meshes.new("SeedHeadsMesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(seed)
    collection.objects.link(bpy.data.objects.new("WildGrassSeedHeads", mesh))
    return collection


def export(collection, file_name):
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    objects = [obj for obj in collection.all_objects if obj.type in {"MESH", "EMPTY"}]
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = next(obj for obj in objects if obj.type == "MESH")
    bpy.ops.export_scene.gltf(filepath=str(OUTPUT_DIR / file_name), export_format="GLB", use_selection=True, export_apply=True)


if __name__ == "__main__":
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bark = material("NYNV_Bark", (0.24, 0.10, 0.035))
    leaf_dark = material("NYNV_LeafDark", (0.08, 0.31, 0.08))
    leaf_mid = material("NYNV_LeafMid", (0.14, 0.46, 0.10))
    leaf_light = material("NYNV_LeafLight", (0.30, 0.58, 0.12))
    bamboo = material("NYNV_Bamboo", (0.26, 0.48, 0.12))
    bamboo_node = material("NYNV_BambooNode", (0.16, 0.34, 0.07))
    bamboo_leaf = material("NYNV_BambooLeaf", (0.09, 0.36, 0.08))
    shrub_stem = material("NYNS_ShrubStem", (0.20, 0.09, 0.025))
    shrub_dark = material("NYNS_ShrubDark", (0.08, 0.30, 0.07))
    shrub_light = material("NYNS_ShrubLight", (0.25, 0.48, 0.10))
    wild_grass = material("NYNS_WildGrass", (0.30, 0.52, 0.12))
    seed = material("NYNS_SeedHead", (0.48, 0.40, 0.16))
    export(build_tree((bark, leaf_dark, leaf_mid, leaf_light)), "summer_tree_variant.glb")
    export(build_bamboo(bamboo, bamboo_node, bamboo_leaf), "bamboo_cluster.glb")
    export(build_shrubs(shrub_stem, shrub_dark, shrub_light), "shrub_pair.glb")
    export(build_grass(wild_grass, seed), "wild_grass_cluster.glb")
