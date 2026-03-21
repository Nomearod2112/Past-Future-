shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float grain_intensity : hint_range(0.0, 0.1) = 0.03;
uniform float warmth : hint_range(0.0, 0.3) = 0.12;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	// Warm shift
	color.r += warmth;
	color.b -= warmth * 0.5;
	// Film grain
	float noise = fract(sin(dot(SCREEN_UV * TIME, vec2(12.9898, 78.233))) * 43758.5453);
	color.rgb += (noise - 0.5) * grain_intensity;
	// Vignette
	float vig = distance(SCREEN_UV, vec2(0.5));
	color.rgb *= 1.0 - vig * vignette_strength;
	COLOR = color;
}
