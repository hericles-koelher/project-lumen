extends Control
## Draws a brief, decorative sparkle burst around a victory message.

## Total time in seconds before the effect removes itself.
const LIFETIME := 1.6
## Number of sparkles distributed around the center of the control.
const SPARKLE_COUNT := 18
## Warm palette used to tint the supplied sparkle art.
const SPARKLE_COLORS := [Color.WHITE, Color("fff2d1"), Color("ffe6ae")]

## Transparent sparkle texture supplied by the parent presentation script.
var sparkle_texture: Texture2D
## Time elapsed since this effect entered the scene tree.
var _elapsed := 0.0


## Configures this control as a full-rect, non-interactive overlay effect.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE


## Advances the effect and frees it when its short animation is complete.
func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= LIFETIME:
		queue_free()
		return
	queue_redraw()


## Draws warm sparkles in an ellipse around the center of the victory panel.
func _draw() -> void:
	if sparkle_texture == null:
		return
	var center := size * 0.5
	var horizontal_radius := minf(390.0, size.x * 0.39)
	var vertical_radius := minf(190.0, size.y * 0.28)
	for index in range(SPARKLE_COUNT):
		_draw_sparkle(index, center, horizontal_radius, vertical_radius)


## Draws one drifting, fading instance of the supplied sparkle artwork.
func _draw_sparkle(index: int, center: Vector2, horizontal_radius: float, vertical_radius: float) -> void:
	var angle := TAU * float(index) / float(SPARKLE_COUNT)
	var direction := Vector2(cos(angle), sin(angle))
	var ring_scale := 0.82 + float((index * 7) % 5) * 0.075
	var base_position := center + Vector2(cos(angle) * horizontal_radius, sin(angle) * vertical_radius) * ring_scale
	var delay := float(index % 4) * 0.045
	var progress := clampf((_elapsed - delay) / (LIFETIME - delay), 0.0, 1.0)
	var fade_in := clampf(progress * 9.0, 0.0, 1.0)
	var fade_out := 1.0 - smoothstep(0.42, 1.0, progress)
	var alpha := fade_in * fade_out
	if alpha <= 0.0:
		return
	var drift := direction * (18.0 * progress) + Vector2(0.0, -10.0 * progress)
	var position := base_position + drift
	var size_factor := 0.72 + 0.22 * sin(progress * PI)
	var sparkle_size := (42.0 + float((index * 11) % 28)) * size_factor
	var color: Color = SPARKLE_COLORS[index % SPARKLE_COLORS.size()]
	color.a = alpha
	var texture_size := Vector2(sparkle_texture.get_size())
	var texture_scale := sparkle_size / maxf(texture_size.x, texture_size.y)
	draw_set_transform(position, angle * 0.18, Vector2.ONE * texture_scale)
	draw_texture(sparkle_texture, -texture_size * 0.5, color)
	draw_set_transform(Vector2.ZERO)
