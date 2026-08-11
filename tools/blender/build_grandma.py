"""Generate the stylized diorama-view grandma character as a reproducible GLB."""

from __future__ import annotations

from pathlib import Path

import bpy


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = REPOSITORY_ROOT / "assets" / "models" / "characters" / "grandma.glb"


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for material in list(bpy.data.materials):
        bpy.data.materials.remove(material)


def create_material(name: str, color: tuple[float, float, float, float], roughness: float = 0.9):
    material = bpy.data.materials.new(name=name)
    material.diffuse_color = color
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = color
    principled.inputs["Roughness"].default_value = roughness
    return material


def apply_scale(obj: bpy.types.Object) -> None:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.select_set(False)


def add_ico(name, location, scale, material, subdivisions=1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1.0, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    apply_scale(obj)
    obj.data.materials.append(material)
    return obj


def add_pivoted_arm(name, pivot, material):
    length = 0.48
    bpy.ops.mesh.primitive_cone_add(vertices=7, radius1=0.105, radius2=0.125, depth=length)
    obj = bpy.context.object
    obj.name = name
    for vertex in obj.data.vertices:
        vertex.co.z -= length * 0.5
    obj.location = pivot
    obj.data.materials.append(material)
    return obj


def parent_to(obj: bpy.types.Object, parent: bpy.types.Object) -> None:
    world_matrix = obj.matrix_world.copy()
    obj.parent = parent
    obj.matrix_world = world_matrix


def main() -> None:
    clear_scene()
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    skin = create_material("GrandmaSunWarmSkin", (0.56, 0.32, 0.22, 1.0))
    clothing = create_material("IndigoGreenWorkClothes", (0.055, 0.22, 0.23, 1.0))
    apron = create_material("UnbleachedKappogi", (0.78, 0.76, 0.58, 1.0))
    sash = create_material("BurgundySash", (0.42, 0.055, 0.045, 1.0))
    hair = create_material("SilverGrayHair", (0.43, 0.44, 0.39, 1.0))
    eyes = create_material("KindEyes", (0.018, 0.01, 0.006, 1.0), 0.55)
    sandals = create_material("StrawSandals", (0.32, 0.18, 0.065, 1.0))

    rig = bpy.data.objects.new("GrandmaRig", None)
    bpy.context.collection.objects.link(rig)
    objects: list[bpy.types.Object] = [rig]

    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.45, radius2=0.29, depth=0.88, location=(0, 0, 0.58))
    body = bpy.context.object
    body.name = "Body"
    body.data.materials.append(clothing)
    objects.append(body)

    objects.append(add_ico("Apron", (0, -0.29, 0.64), (0.32, 0.075, 0.39), apron, 1))
    bpy.ops.mesh.primitive_torus_add(
        major_radius=0.335,
        minor_radius=0.035,
        major_segments=10,
        minor_segments=4,
        location=(0, 0, 0.78),
    )
    waist_sash = bpy.context.object
    waist_sash.name = "WaistSash"
    waist_sash.data.materials.append(sash)
    objects.append(waist_sash)

    objects.append(add_ico("Head", (0, -0.015, 1.25), (0.31, 0.285, 0.3), skin, 2))
    objects.append(add_ico("HairCap", (0, 0.015, 1.365), (0.32, 0.29, 0.205), hair, 2))
    objects.append(add_ico("HairBun", (0, 0.23, 1.47), (0.19, 0.16, 0.19), hair, 1))
    objects.append(add_ico("LeftEye", (-0.115, -0.27, 1.28), (0.038, 0.025, 0.034), eyes, 1))
    objects.append(add_ico("RightEye", (0.115, -0.27, 1.28), (0.038, 0.025, 0.034), eyes, 1))

    left_arm = add_pivoted_arm("LeftArm", (-0.34, 0, 0.93), clothing)
    right_arm = add_pivoted_arm("RightArm", (0.34, 0, 0.93), clothing)
    objects.extend([left_arm, right_arm])
    left_hand = add_ico("LeftHand", (-0.34, 0, 0.42), (0.11, 0.1, 0.11), skin, 1)
    right_hand = add_ico("RightHand", (0.34, 0, 0.42), (0.11, 0.1, 0.11), skin, 1)
    objects.extend([left_hand, right_hand])
    objects.append(add_ico("LeftSandal", (-0.18, -0.05, 0.055), (0.17, 0.23, 0.065), sandals, 1))
    objects.append(add_ico("RightSandal", (0.18, -0.05, 0.055), (0.17, 0.23, 0.065), sandals, 1))

    for obj in objects[1:]:
        parent_to(obj, rig)
    parent_to(left_hand, left_arm)
    parent_to(right_hand, right_arm)

    mesh_objects = [obj for obj in objects if obj.type == "MESH"]
    for obj in mesh_objects:
        obj.data.calc_loop_triangles()
    triangle_count = sum(len(obj.data.loop_triangles) for obj in mesh_objects)
    assert triangle_count < 1600
    assert len(bpy.data.materials) == 7

    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.export_scene.gltf(
        filepath=str(OUTPUT_PATH),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
    )
    clear_scene()
    print(f"Generated diorama grandma at {OUTPUT_PATH} ({triangle_count} triangles)")


if __name__ == "__main__":
    main()
