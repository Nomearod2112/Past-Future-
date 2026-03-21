shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float coolness : hint_range(0.0, 0.2) = 0.08;
uniform float desaturation : hint_range(0.0, 0.5) = 0.15;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	// Cool shift
	color.b += coolness;
	color.r -= coolness * 0.3;
	// Slight desaturation
	float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	color.rgb = mix(color.rgb, vec3(luma), desaturation);
	COLOR = color;
}
