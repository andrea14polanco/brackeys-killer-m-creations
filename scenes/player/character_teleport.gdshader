shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
// Purple outline like the character art
uniform vec4 edge_color : source_color = vec4(0.6, 0.15, 0.85, 1.0);
// Warm secondary glow (matches green vest highlight)
uniform vec4 secondary_color : source_color = vec4(0.3, 0.65, 0.35, 1.0);
uniform float edge_width : hint_range(0.0, 0.3) = 0.07;
uniform float scan_speed = 2.5;
uniform float scan_frequency = 8.0;
uniform sampler2D noise_texture : hint_default_white;

void fragment() {
    vec4 original = texture(TEXTURE, UV);
    if (original.a < 0.01) discard;

    float noise = texture(noise_texture, UV * 1.8 + TIME * 0.04).r;

    // Dissolve bottom-up (feet first, like stepping into portal)
    float dissolve = noise * 0.4 + (1.0 - UV.y) * 0.6;
    float threshold = progress * 1.2;

    float edge = smoothstep(threshold - edge_width, threshold, dissolve)
               - smoothstep(threshold, threshold + edge_width, dissolve);

    if (dissolve < threshold - edge_width) discard;

    // Scan lines
    float scan = sin(UV.y * scan_frequency * 3.14159 + TIME * scan_speed) * 0.5 + 0.5;
    scan = pow(scan, 5.0) * (1.0 - progress) * 0.4;

    // Slight green tint on surviving pixels (vest color bleed)
    vec3 tinted = mix(original.rgb, secondary_color.rgb * original.rgb * 1.3, progress * 0.3);

    tinted = mix(tinted, edge_color.rgb, edge * 0.85);
    tinted += edge_color.rgb * edge * 1.5;       // emission
    tinted += secondary_color.rgb * scan;         // scan shimmer

    COLOR = vec4(tinted, original.a);
}