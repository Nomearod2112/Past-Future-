shader_type canvas_item;

uniform float ripple_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 ripple_origin = vec2(0.5, 0.5);
uniform sampler2D texture_before;
uniform sampler2D texture_after;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
	float dist = distance(UV, ripple_origin);
	float wave_pos = ripple_progress * 1.5;
	float wave_width = 0.08;

	float wave_dist = abs(dist - wave_pos);
	float in_wave = smoothstep(wave_width, 0.0, wave_dist);

	// Chromatic aberration at wave front
	vec2 offset_dir = normalize(UV - ripple_origin) * in_wave * 0.012;
	float blend = step(dist, wave_pos);

	vec4 color_r = mix(
		texture(texture_before, UV + offset_dir),
		texture(texture_after, UV + offset_dir),
		blend
	);
	vec4 color_g = mix(
		texture(texture_before, UV),
		texture(texture_after, UV),
		blend
	);
	vec4 color_b = mix(
		texture(texture_before, UV - offset_dir),
		texture(texture_after, UV - offset_dir),
		blend
	);

	vec4 gold = vec4(0.94, 0.78, 0.37, 1.0);
	vec4 final_color = vec4(color_r.r, color_g.g, color_b.b, 1.0);
	final_color = mix(final_color, gold, in_wave * 0.3);

	COLOR = final_color;
}
