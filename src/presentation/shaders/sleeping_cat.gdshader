// Applies the approved torso lift and anatomical ear-only rotation to a dense cat mesh.
shader_type canvas_item;
render_mode unshaded;

// Source-pixel dimensions keep the ear mask independent from on-screen scaling.
uniform vec2 source_extent = vec2(1585.0, 992.0);
// Normalized torso displacement and signed ear gesture angle supplied by the controller.
uniform float breath_lift = 0.0;
uniform float ear_angle = 0.0;

// Preserve UV sampling and alpha while moving only weighted vertices.
void vertex() {
	vec2 uv = UV;
	vec2 position = VERTEX;

	float body = (1.0 - smoothstep(0.42, 0.68, uv.x))
		* smoothstep(0.0, 0.08, uv.x);
	float height = 1.0 - smoothstep(0.58, 0.82, uv.y);
	position.y -= breath_lift * source_extent.y * body * height;

	vec2 pixel_position = uv * source_extent;
	vec2 root_upper = vec2(1125.0, 397.0);
	vec2 tip = vec2(1395.0, 314.0);
	vec2 root_lower = vec2(1290.0, 491.0);

	vec2 upper_edge = tip - root_upper;
	vec2 outer_edge = root_lower - tip;
	vec2 base_edge = root_upper - root_lower;

	vec2 delta = pixel_position - root_upper;
	float upper_distance = (upper_edge.x * delta.y - upper_edge.y * delta.x)
		/ length(upper_edge);
	delta = pixel_position - tip;
	float outer_distance = (outer_edge.x * delta.y - outer_edge.y * delta.x)
		/ length(outer_edge);
	delta = pixel_position - root_lower;
	float base_distance = (base_edge.x * delta.y - base_edge.y * delta.x)
		/ length(base_edge);

	float ear = smoothstep(-10.0, -4.0, upper_distance)
		* smoothstep(-10.0, -4.0, outer_distance)
		* smoothstep(0.0, 42.0, base_distance);

	vec2 pivot = vec2(0.77, 0.495);
	vec2 local = (uv - pivot) * source_extent;
	float angle = ear_angle * ear;
	float cosine = cos(angle);
	float sine = sin(angle);
	vec2 rotated = vec2(
		cosine * local.x - sine * local.y,
		sine * local.x + cosine * local.y
	);
	position += rotated - local;

	VERTEX = position;
}
