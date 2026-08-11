"""Generate the lightweight P0 environment kit as reproducible GLB files."""

from __future__ import annotations

import math
import random
from pathlib import Path

import bpy


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIRECTORY = REPOSITORY_ROOT / "assets" / "models" / "environment"


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


def join_objects(objects: list[bpy.types.Object], name: str) -> bpy.types.Object:
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    joined = bpy.context.object
    joined.name = name
    return joined


def export_object(obj: bpy.types.Object, file_name: str) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    output_path = OUTPUT_DIRECTORY / file_name
    bpy.ops.export_scene.gltf(
        filepath=str(output_path),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
    )


def build_summer_tree() -> None:
    clear_scene()
    trunk_material = create_material("Trunk", (0.20, 0.095, 0.035, 1.0))
    leaf_dark = create_material("LeafDark", (0.015, 0.075, 0.022, 1.0))
    leaf_light = create_material("LeafLight", (0.028, 0.13, 0.038, 1.0))
    objects: list[bpy.types.Object] = []

    bpy.ops.mesh.primitive_cone_add(vertices=7, radius1=0.34, radius2=0.23, depth=3.0, location=(0, 0, 1.5))
    trunk = bpy.context.object
    trunk.data.materials.append(trunk_material)
    objects.append(trunk)

    crown_specs = [
        ((-0.72, 0.0, 3.25), (1.25, 1.0, 0.82), leaf_dark),
        ((0.68, 0.08, 3.35), (1.15, 0.96, 0.78), leaf_dark),
        ((0.0, -0.18, 3.75), (1.4, 1.1, 0.9), leaf_light),
    ]
    for location, scale, material in crown_specs:
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0, location=location)
        crown = bpy.context.object
        crown.scale = scale
        apply_scale(crown)
        crown.data.materials.append(material)
        objects.append(crown)

    tree = join_objects(objects, "SummerTree")
    export_object(tree, "summer_tree.glb")


def build_rice_clump() -> None:
    clear_scene()
    rice_dark = create_material("RiceDark", (0.11, 0.22, 0.025, 1.0))
    rice_light = create_material("RiceLight", (0.2, 0.36, 0.05, 1.0))
    rng = random.Random(20260811)
    blades: list[bpy.types.Object] = []

    for index in range(12):
        angle = math.tau * index / 12.0 + rng.uniform(-0.2, 0.2)
        radius = rng.uniform(0.02, 0.13)
        height = rng.uniform(0.62, 0.92)
        bpy.ops.mesh.primitive_cone_add(
            vertices=4,
            radius1=0.035,
            radius2=0.008,
            depth=height,
            location=(math.cos(angle) * radius, math.sin(angle) * radius, height * 0.5),
            rotation=(rng.uniform(-0.16, 0.16), rng.uniform(-0.16, 0.16), angle),
        )
        blade = bpy.context.object
        blade.data.materials.append(rice_light if index % 3 == 0 else rice_dark)
        blades.append(blade)

    rice_clump = join_objects(blades, "RiceClump")
    export_object(rice_clump, "rice_clump.glb")


def build_river_rock_set() -> None:
    clear_scene()
    rock_dark = create_material("RockDark", (0.07, 0.09, 0.1, 1.0), roughness=0.82)
    rock_light = create_material("RockLight", (0.12, 0.15, 0.16, 1.0), roughness=0.8)
    objects: list[bpy.types.Object] = []
    rock_specs = [
        ((-2.1, 0.1, 0.0), (0.65, 0.48, 0.35), rock_dark),
        ((0.0, 0.45, 0.03), (0.48, 0.38, 0.28), rock_light),
        ((2.25, -0.25, 0.02), (0.78, 0.52, 0.4), rock_dark),
    ]
    for index, (location, scale, material) in enumerate(rock_specs):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0, location=location)
        rock = bpy.context.object
        rock.name = f"RiverRock{index + 1}"
        rock.scale = scale
        rock.rotation_euler[2] = index * 0.47
        apply_scale(rock)
        rock.data.materials.append(material)
        objects.append(rock)

    rock_set = join_objects(objects, "RiverRockSet")
    export_object(rock_set, "river_rock_set.glb")


def main() -> None:
    OUTPUT_DIRECTORY.mkdir(parents=True, exist_ok=True)
    build_summer_tree()
    build_rice_clump()
    build_river_rock_set()
    clear_scene()
    print(f"Generated P0 environment kit in {OUTPUT_DIRECTORY}")


if __name__ == "__main__":
    main()
