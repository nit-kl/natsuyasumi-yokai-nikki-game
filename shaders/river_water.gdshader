shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.07, 0.42, 0.54, 1.0);
uniform vec4 deep_color : source_color = vec4(0.015, 0.16, 0.25, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.3, 0.58, 0.62, 1.0);
uniform float flow_speed : hint_range(0.0, 2.0) = 0.32;
uniform float wave_height : hint_range(0.0, 0.1) = 0.018;

varying float vertex_wave;


void vertex() {
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float first_wave = sin(world_position.x * 1.35 + TIME * flow_speed * 5.0);
	float second_wave = sin(world_position.z * 2.1 - TIME * flow_speed * 3.2);
	vertex_wave = (first_wave + second_wave) * 0.5;
	VERTEX.y += vertex_wave * wave_height;
}


void fragment() {
	float flow_a = sin((UV.x * 18.0 + UV.y * 3.0) + TIME * flow_speed * 4.0);
	float flow_b = sin((UV.x * 7.0 - UV.y * 11.0) - TIME * flow_speed * 2.5);
	float flow = clamp((flow_a + flow_b) * 0.25 + 0.5, 0.0, 1.0);
	float glint = smoothstep(0.78, 0.98, flow);
	ALBEDO = mix(deep_color.rgb, shallow_color.rgb, 0.58 + vertex_wave * 0.08);
	ALBEDO = mix(ALBEDO, highlight_color.rgb, glint * 0.09);
	ROUGHNESS = mix(0.64, 0.48, glint);
	METALLIC = 0.0;
	SPECULAR = 0.18;
	ALPHA = 0.92;
}
