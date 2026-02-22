shader_type canvas_item;

uniform vec4 deep_color : source_color = vec4(0.05, 0.15, 0.35, 0.85);
uniform vec4 surface_color : source_color = vec4(0.15, 0.45, 0.7, 0.7);
uniform float wave_speed : hint_range(0.5, 5.0) = 1.5;
uniform float wave_height : hint_range(0.0, 0.05) = 0.015;
uniform float wave2_height : hint_range(0.0, 0.03) = 0.008;
uniform float surface_band : hint_range(0.0, 0.1) = 0.025;

void fragment() {
	vec2 uv = UV;

	// Two layered sine waves on the top edge
	float wave1 = sin(uv.x * 12.0 + TIME * wave_speed) * wave_height;
	float wave2 = sin(uv.x * 20.0 - TIME * wave_speed * 0.7) * wave2_height;
	float wave_offset = wave1 + wave2;

	// Discard pixels above the wavy surface line
	if (uv.y < wave_offset + 0.01) {
		discard;
	}

	// Depth gradient: surface_color at top, deep_color at bottom
	float depth_t = smoothstep(0.01, 0.4, uv.y);
	vec4 base = mix(surface_color, deep_color, depth_t);

	// Bright highlight band near the surface
	float surface_dist = uv.y - (wave_offset + 0.01);
	float highlight = smoothstep(surface_band, 0.0, surface_dist) * 0.3;
	base.rgb += vec3(highlight);

	COLOR = base;
}
