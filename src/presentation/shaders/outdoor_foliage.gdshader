// Bends a branch around its anchored lower stem while preserving the approved texture.
shader_type canvas_item;
render_mode unshaded;

// Controller amplitudes are normalized to these source-pixel dimensions.
uniform vec2 source_extent = vec2(1254.0, 1254.0);
uniform float wind = 0.0;
uniform float flutter = 0.0;
uniform float wind_phase = 0.0;

// Add a slow branch bend and smaller secondary leaf flutter.
void vertex() {
	vec2 uv = UV;
	float weight = pow(clamp((0.94 - uv.y) / 0.86, 0.0, 1.0), 1.5);
	float ripple = sin(uv.x * 14.0 + uv.y * 9.0 + wind_phase);

	vec2 offset = vec2(
		wind * weight + flutter * ripple * weight,
		wind * 0.22 * weight - flutter * ripple * 0.35 * weight
	) * source_extent;
	VERTEX += offset;
}
