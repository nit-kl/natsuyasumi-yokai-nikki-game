"""Generate the stylized diorama-view summer child as a reproducible GLB."""

from __future__ import annotations

from pathlib import Path

import bpy


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = REPOSITORY_ROOT / "assets" / "models" / "characters" / "protagonist.glb"


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


def add_pivoted_limb(name, pivot, length, radius, material):
    bpy.ops.mesh.primitive_cone_add(vertices=7, radius1=radius * 0.82, radius2=radius, depth=length)
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

    skin = create_material("SunWarmSkin", (0.58, 0.31, 0.18, 1.0))
    shirt = create_material("UnbleachedSummerShirt", (0.82, 0.78, 0.59, 1.0))
    indigo = create_material("FadedIndigo", (0.035, 0.12, 0.23, 1.0))
    hair = create_material("SoftBlackHair", (0.025, 0.018, 0.012, 1.0))
    shoes = create_material("RubberShoes", (0.12, 0.09, 0.055, 1.0))
    satchel = create_material("VermilionSatchel", (0.62, 0.105, 0.045, 1.0))
    straw = create_material("StrawHat", (0.83, 0.61, 0.22, 1.0), 1.0)

    rig = bpy.data.objects.new("CharacterRig", None)
    bpy.context.collection.objects.link(rig)
    objects: list[bpy.types.Object] = [rig]

    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.29, radius2=0.235, depth=0.43, location=(0, 0, 0.94))
    torso = bpy.context.object
    torso.name = "Torso"
    torso.data.materials.append(shirt)
    objects.append(torso)

    bpy.ops.mesh.primitive_cube_add(location=(0, 0.025, 0.69), scale=(0.265, 0.19, 0.14))
    hip = bpy.context.object
    hip.name = "Shorts"
    hip.data.materials.append(indigo)
    objects.append(hip)

    objects.append(add_ico("Head", (0, -0.015, 1.265), (0.29, 0.27, 0.285), skin, 2))
    objects.append(add_ico("Hair", (0, 0.015, 1.355), (0.3, 0.275, 0.205), hair, 2))
    objects.append(add_ico("Satchel", (0.16, 0.215, 0.91), (0.205, 0.09, 0.245), satchel, 1))

    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.405, depth=0.045, location=(0, 0, 1.49))
    brim = bpy.context.object
    brim.name = "HatBrim"
    brim.data.materials.append(straw)
    objects.append(brim)

    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.255, radius2=0.205, depth=0.2, location=(0, 0, 1.59))
    crown = bpy.context.object
    crown.name = "HatCrown"
    crown.data.materials.append(straw)
    objects.append(crown)

    bpy.ops.mesh.primitive_torus_add(
        major_radius=0.245,
        minor_radius=0.018,
        major_segments=12,
        minor_segments=4,
        location=(0, 0, 1.515),
    )
    hat_band = bpy.context.object
    hat_band.name = "HatBand"
    hat_band.data.materials.append(indigo)
    objects.append(hat_band)

    left_arm = add_pivoted_limb("LeftArm", (-0.285, 0, 1.08), 0.46, 0.09, skin)
    right_arm = add_pivoted_limb("RightArm", (0.285, 0, 1.08), 0.46, 0.09, skin)
    left_leg = add_pivoted_limb("LeftLeg", (-0.13, 0, 0.65), 0.47, 0.115, indigo)
    right_leg = add_pivoted_limb("RightLeg", (0.13, 0, 0.65), 0.47, 0.115, indigo)
    objects.extend([left_arm, right_arm, left_leg, right_leg])

    left_shoe = add_ico("LeftShoe", (-0.13, -0.045, 0.055), (0.14, 0.205, 0.075), shoes, 1)
    right_shoe = add_ico("RightShoe", (0.13, -0.045, 0.055), (0.14, 0.205, 0.075), shoes, 1)
    objects.extend([left_shoe, right_shoe])

    for obj in objects[1:]:
        parent_to(obj, rig)

    mesh_objects = [obj for obj in objects if obj.type == "MESH"]
    for obj in mesh_objects:
        obj.data.calc_loop_triangles()
    triangle_count = sum(len(obj.data.loop_triangles) for obj in mesh_objects)
    assert triangle_count < 1800
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
    print(f"Generated diorama protagonist at {OUTPUT_PATH} ({triangle_count} triangles)")


if __name__ == "__main__":
    main()
