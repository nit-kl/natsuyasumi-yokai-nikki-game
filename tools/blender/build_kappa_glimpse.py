"""Generate the lightweight river-glimpse kappa as a reproducible GLB."""

from __future__ import annotations

from pathlib import Path

import bpy


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = REPOSITORY_ROOT / "assets" / "models" / "yokai" / "kappa_glimpse.glb"


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


def add_ico(
    name: str,
    location: tuple[float, float, float],
    scale: tuple[float, float, float],
    material: bpy.types.Material,
    subdivisions: int = 1,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1.0, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    apply_scale(obj)
    obj.data.materials.append(material)
    return obj


def main() -> None:
    clear_scene()
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    skin_dark = create_material("KappaSkinDark", (0.012, 0.07, 0.025, 1.0))
    skin_light = create_material("KappaSkinLight", (0.03, 0.14, 0.045, 1.0))
    shell_material = create_material("KappaShell", (0.015, 0.045, 0.025, 1.0))
    plate_material = create_material("KappaPlate", (0.24, 0.3, 0.09, 1.0), roughness=0.72)
    eye_material = create_material("KappaEye", (0.002, 0.003, 0.002, 1.0), roughness=0.45)
    objects: list[bpy.types.Object] = []

    bpy.ops.mesh.primitive_cone_add(
        vertices=8,
        radius1=0.42,
        radius2=0.31,
        depth=1.08,
        location=(0, 0, 0.63),
    )
    torso = bpy.context.object
    torso.name = "Torso"
    torso.data.materials.append(skin_dark)
    objects.append(torso)

    objects.append(add_ico("Head", (0, -0.03, 1.35), (0.46, 0.42, 0.42), skin_light, 2))
    objects.append(add_ico("Muzzle", (0, -0.37, 1.27), (0.25, 0.16, 0.15), skin_light, 1))
    objects.append(add_ico("Belly", (0, -0.32, 0.68), (0.27, 0.1, 0.38), skin_light, 1))
    objects.append(add_ico("Shell", (0, 0.29, 0.72), (0.37, 0.14, 0.48), shell_material, 2))
    objects.append(add_ico("LeftArm", (-0.43, -0.01, 0.73), (0.14, 0.14, 0.43), skin_dark, 1))
    objects.append(add_ico("RightArm", (0.43, -0.01, 0.73), (0.14, 0.14, 0.43), skin_dark, 1))
    objects.append(add_ico("LeftEye", (-0.16, -0.385, 1.46), (0.052, 0.035, 0.058), eye_material, 1))
    objects.append(add_ico("RightEye", (0.16, -0.385, 1.46), (0.052, 0.035, 0.058), eye_material, 1))

    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.34, depth=0.075, location=(0, -0.02, 1.77))
    plate = bpy.context.object
    plate.name = "HeadPlate"
    plate.data.materials.append(plate_material)
    objects.append(plate)

    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = torso
    bpy.ops.object.join()
    kappa = bpy.context.object
    kappa.name = "KappaGlimpse"

    bpy.ops.object.select_all(action="DESELECT")
    kappa.select_set(True)
    bpy.context.view_layer.objects.active = kappa
    bpy.ops.export_scene.gltf(
        filepath=str(OUTPUT_PATH),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
    )
    clear_scene()
    print(f"Generated kappa glimpse model at {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
