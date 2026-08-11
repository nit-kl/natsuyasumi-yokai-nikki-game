shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 wet_soil_color : source_color = vec4(0.12, 0.16, 0.07, 1.0);
uniform vec4 algae_color : source_color = vec4(0.22, 0.38, 0.08, 1.0);
uniform vec4 reflected_sky_color : source_color = vec4(0.2, 0.38, 0.36, 1.0);


void fragment() {
	float broad_variation = sin(UV.x * 13.0) * sin(UV.y * 9.0) * 0.5 + 0.5;
	float water_line = smoothstep(0.86, 0.98, sin(UV.y * 42.0) * 0.5 + 0.5);
	vec3 base_color = mix(wet_soil_color.rgb, algae_color.rgb, broad_variation * 0.55);
	ALBEDO = mix(base_color, reflected_sky_color.rgb, water_line * 0.22);
	ROUGHNESS = mix(0.66, 0.28, water_line);
	SPECULAR = 0.62;
}
