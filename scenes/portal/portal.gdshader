shader_type canvas_item;

// Academia-themed colors based on character design
uniform vec4 inner_color : source_color = vec4(0.15, 0.08, 0.35, 1.0);  // deep purple
uniform vec4 mid_color : source_color = vec4(0.05, 0.35, 0.4, 1.0);     // teal (like collider)
uniform vec4 edge_color : source_color = vec4(0.55, 0.2, 0.75, 1.0);    // soft purple glow
uniform float swirl_speed = 1.2;
uniform float ring_count = 5.0;
uniform float pulse_speed = 1.8;
uniform float open_progress : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D noise_texture : hint_default_white;
// Capsule shape controls
uniform float capsule_radius : hint_range(0.0, 0.5) = 0.35; // half-width
uniform float capsule_height : hint_range(0.0, 1.0) = 0.25; // half of straight section

float capsule_sdf(vec2 uv, float radius, float half_height) {
    // uv is centered (-1 to 1 range)
    vec2 p = uv;
    p.y = abs(p.y) - half_height;
    p.y = max(p.y, 0.0);
    return length(p) - radius;
}

vec2 rotate2D(vec2 uv, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
}

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;
    // Adjust aspect — if your sprite is not square, tweak this
    uv.y *= 1.6; // match capsule tall shape

    float dist_sdf = capsule_sdf(uv, capsule_radius * open_progress, capsule_height * open_progress);

    // Clip outside capsule
    if (dist_sdf > 0.03) discard;

    float dist_from_center = length(uv);
    float t = clamp(dist_from_center / (capsule_radius + capsule_height * 0.5), 0.0, 1.0);

    // Swirl — stronger near center
    float angle = atan(uv.y, uv.x);
    float swirl = angle + dist_from_center * 4.0 - TIME * swirl_speed;
    vec2 swirled = rotate2D(uv * 0.5 + 0.5, swirl * 0.35);

    // Noise
    float noise  = texture(noise_texture, swirled + TIME * 0.03).r;
    float noise2 = texture(noise_texture, swirled * 1.6 - TIME * 0.05).r;
    float n = mix(noise, noise2, 0.5);

    // Rings
    float rings = sin((t * ring_count - TIME * pulse_speed) * 3.14159 * 2.0) * 0.5 + 0.5;
    rings = pow(rings, 3.0);

    // Edge glow near SDF boundary
    float edge_glow = 1.0 - smoothstep(-0.08, 0.0, dist_sdf);
    float inner_glow = 1.0 - smoothstep(0.0, 0.5, t);

    vec3 base = mix(inner_color.rgb, mid_color.rgb, t);
    base = mix(base, edge_color.rgb, edge_glow);

    float brightness = inner_glow * 1.4 + rings * 0.6 + n * 0.25 + edge_glow * 2.0;
    float pulse = sin(TIME * pulse_speed) * 0.07 + 0.93;

    vec3 final_color = base * brightness * pulse;
    float alpha = smoothstep(0.03, -0.01, dist_sdf) * open_progress;

    COLOR = vec4(final_color, alpha);
}