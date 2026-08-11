"""Generate a lightweight stylized abura-zemi cicada as a reproducible GLB."""

from __future__ import annotations

from pathlib import Path

import bpy
from mathutils import Vector


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_PATH = REPOSITORY_ROOT / "assets" / "models" / "insects" / "abura_zemi.glb"


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for material in list(bpy.data.materials):
        bpy.data.materials.remove(material)


def create_material(
    name: str,
    color: tuple[float, float, float, float],
    roughness: float = 0.8,
) -> bpy.types.Material:
    material = bpy.data.materials.new(name=name)
    material.diffuse_color = color
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = color
    principled.inputs["Roughness"].default_value = roughness
    principled.inputs["Alpha"].default_value = color[3]
    if color[3] < 1.0:
        if hasattr(material, "surface_render_method"):
            material.surface_render_method = "DITHERED"
        elif hasattr(material, "blend_method"):
            material.blend_method = "BLEND"
        if hasattr(material, "use_transparency_overlap"):
            material.use_transparency_overlap = False
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


def add_cylinder_between(
    name: str,
    start: tuple[float, float, float],
    end: tuple[float, float, float],
    radius: float,
    material: bpy.types.Material,
) -> bpy.types.Object:
    start_vector = Vector(start)
    end_vector = Vector(end)
    delta = end_vector - start_vector
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=radius, depth=delta.length)
    obj = bpy.context.object
    obj.name = name
    obj.location = (start_vector + end_vector) * 0.5
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = delta.to_track_quat("Z", "Y")
    obj.data.materials.append(material)
    return obj


def create_wing(
    name: str,
    side: float,
    wing_material: bpy.types.Material,
    vein_material: bpy.types.Material,
) -> tuple[bpy.types.Object, list[bpy.types.Object]]:
    pivot = bpy.data.objects.new(name, None)
    pivot.location = (0.1 * side, -0.03, 0.19)
    bpy.context.collection.objects.link(pivot)

    vertices = [
        (0.0, 0.0, 0.0),
        (0.25 * side, 0.05, 0.005),
        (0.3 * side, 0.34, 0.0),
        (0.07 * side, 0.29, 0.01),
    ]
    mesh = bpy.data.meshes.new(f"{name}SurfaceMesh")
    mesh.from_pydata(vertices, [], [(0, 1, 2, 3)])
    mesh.materials.append(wing_material)
    surface = bpy.data.objects.new(f"{name}Surface", mesh)
    bpy.context.collection.objects.link(surface)
    surface.parent = pivot

    veins = [surface]
    for index, endpoint in enumerate((vertices[1], vertices[2], vertices[3])):
        vein = add_cylinder_between(
            f"{name}Vein{index + 1}",
            (0.0, 0.0, 0.012),
            (endpoint[0], endpoint[1], 0.012),
            0.006,
            vein_material,
        )
        vein.parent = pivot
        veins.append(vein)
    return pivot, veins


def parent_keep_transform(obj: bpy.types.Object, parent: bpy.types.Object) -> None:
    world_matrix = obj.matrix_world.copy()
    obj.parent = parent
    obj.matrix_world = world_matrix


def main() -> None:
    clear_scene()
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    shell = create_material("CicadaShell", (0.18, 0.105, 0.035, 1.0), 0.72)
    shell_dark = create_material("CicadaShellDark", (0.045, 0.025, 0.012, 1.0), 0.82)
    marking = create_material("CicadaMarking", (0.66, 0.39, 0.08, 1.0), 0.7)
    wing = create_material("CicadaWing", (0.72, 0.55, 0.26, 0.62), 0.48)
    eye = create_material("CicadaEye", (0.004, 0.003, 0.002, 1.0), 0.32)

    root = bpy.data.objects.new("AburaZemi", None)
    bpy.context.collection.objects.link(root)
    objects: list[bpy.types.Object] = [root]

    objects.append(add_ico("Abdomen", (0, 0.12, 0.13), (0.105, 0.285, 0.085), shell_dark, 2))
    objects.append(add_ico("Thorax", (0, -0.11, 0.15), (0.16, 0.18, 0.13), shell, 1))
    objects.append(add_ico("Head", (0, -0.28, 0.14), (0.15, 0.115, 0.105), shell_dark, 1))
    objects.append(add_ico("LeftEye", (-0.13, -0.315, 0.16), (0.04, 0.035, 0.045), eye, 1))
    objects.append(add_ico("RightEye", (0.13, -0.315, 0.16), (0.04, 0.035, 0.045), eye, 1))

    for index, y_position in enumerate((0.0, 0.115, 0.225)):
        bpy.ops.mesh.primitive_torus_add(
            major_radius=0.086 - index * 0.008,
            minor_radius=0.012,
            major_segments=8,
            minor_segments=4,
            location=(0, y_position, 0.13),
            rotation=(1.5708, 0, 0),
        )
        band = bpy.context.object
        band.name = f"AbdomenBand{index + 1}"
        band.data.materials.append(marking)
        objects.append(band)

    left_wing, left_parts = create_wing("LeftWing", -1.0, wing, marking)
    right_wing, right_parts = create_wing("RightWing", 1.0, wing, marking)
    objects.extend([left_wing, right_wing, *left_parts, *right_parts])

    leg_y_positions = (-0.17, -0.04, 0.1)
    for side_name, side in (("Left", -1.0), ("Right", 1.0)):
        for index, y_position in enumerate(leg_y_positions):
            leg = add_cylinder_between(
                f"{side_name}Leg{index + 1}",
                (0.1 * side, y_position, 0.1),
                ((0.23 + index * 0.025) * side, y_position + 0.055 * (index - 1), 0.015),
                0.012,
                shell_dark,
            )
            objects.append(leg)

    objects.append(add_cylinder_between("LeftAntenna", (-0.06, -0.35, 0.18), (-0.13, -0.47, 0.24), 0.008, shell_dark))
    objects.append(add_cylinder_between("RightAntenna", (0.06, -0.35, 0.18), (0.13, -0.47, 0.24), 0.008, shell_dark))

    for obj in objects[1:]:
        if obj.parent is None:
            parent_keep_transform(obj, root)
    left_wing.parent = root
    right_wing.parent = root

    mesh_objects = [obj for obj in objects if obj.type == "MESH"]
    for obj in mesh_objects:
        obj.data.calc_loop_triangles()
    triangle_count = sum(len(obj.data.loop_triangles) for obj in mesh_objects)
    assert triangle_count < 1800, f"Cicada is too dense: {triangle_count} triangles"
    assert len(bpy.data.materials) == 5

    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(
        filepath=str(OUTPUT_PATH),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
    )
    print(f"Generated abura-zemi at {OUTPUT_PATH} ({triangle_count} triangles)")
    clear_scene()


if __name__ == "__main__":
    main()
