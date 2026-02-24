shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 tint : source_color = vec3(0.0, 0.0, 0.0);

void fragment() {
	vec2 uv = UV - 0.5;
	float dist = length(uv) * 2.0;
	// Smooth vignette falloff: starts at edges, darkens inward with intensity
	float vignette = smoothstep(0.3, 1.2, dist) * intensity;
	vec3 color = mix(vec3(0.0), tint, 0.6);
	COLOR = vec4(color, vignette);
}
