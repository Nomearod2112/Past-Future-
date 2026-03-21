shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float echo_intensity : hint_range(0.0, 1.0) = 0.4;
uniform vec4 echo_color : source_color = vec4(0.831, 0.627, 0.337, 0.4);

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	// Ghost overlay with warm amber tint
	float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 ghost = mix(color.rgb, echo_color.rgb, echo_intensity);
	ghost = mix(ghost, vec3(luma) * echo_color.rgb, 0.3);
	COLOR = vec4(ghost, color.a * echo_color.a);
}
