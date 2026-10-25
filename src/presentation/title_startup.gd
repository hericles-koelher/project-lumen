extends Control
class_name TitleStartup
## Adds the approved one-time startup light to its parent Wordmark TextureRect.

## Existing transparent halo texture reused around the wordmark's hanging lamp.
const LAMP_HALO: Texture2D = preload("res://assets/fx/candidates/lamp_glow_candidate_01.png")

## Duration of each initial title flicker.
const BLINK_DURATION := 0.080
## Lead-in before the first initial flicker.
const LEAD_IN_DURATION := 0.040
## Rest between the final flicker and full title brightness.
const SETTLE_DURATION := 0.060
## Duration of the lamp halo reveal.
const HALO_FADE_DURATION := 0.250
## Title light level during the initial dark phase.
const DIM_LEVEL := 0.22
## Lowest brightness multiplier supported by the preview.
const MIN_BRIGHTNESS := 0.08
## Base halo opacity before applying its tuning multiplier.
const HALO_BASE_OPACITY := 0.20
## Halo center as a fraction of the fitted wordmark image bounds.
const HALO_CENTER := Vector2(0.785, 0.43)
## Halo width as a fraction of the fitted wordmark image width.
const HALO_WIDTH_RATIO := 0.32

var _tuning: Resource
var _wordmark: TextureRect
var _elapsed := 0.0
var _start_delay_remaining := 0.0
var _settled_at := 0.0
var _duration := 0.0
var _brightness := 1.0
var _halo_opacity := 0.0
var _halo_scale := 0.90
var _is_settled := true
var _timeline: Array[Vector2] = []

## Elapsed animation time, exposed read-only for presentation validation.
var elapsed_seconds: float:
	get:
		return _elapsed

## Current title brightness multiplier, exposed read-only for presentation validation.
var current_brightness: float:
	get:
		return _brightness

## Current lamp halo opacity, exposed read-only for presentation validation.
var current_halo_opacity: float:
	get:
		return _halo_opacity

## Whether the animation has reached its final steady appearance.
var is_settled: bool:
	get:
		return _is_settled


## Anchors the overlay to the wordmark without taking input or layout space.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wordmark = get_parent() as TextureRect
	queue_redraw()


## Applies tuning and schedules startup or immediately shows its settled appearance.
func configure(tuning: Resource, play_startup: bool, start_delay_seconds: float = 0.0) -> void:
	if is_instance_valid(_wordmark):
		_wordmark.modulate = Color.WHITE
	_tuning = tuning
	if not is_instance_valid(_wordmark):
		_wordmark = get_parent() as TextureRect
	if _wordmark == null:
		_is_settled = true
		set_process(false)
		return

	_build_timeline()
	_elapsed = 0.0
	_start_delay_remaining = maxf(0.0, start_delay_seconds)
	if play_startup:
		_is_settled = false
		_update_visual_state()
	else:
		_elapsed = _duration
		_start_delay_remaining = 0.0
		_is_settled = true
		_update_visual_state()
	set_process(true)
	queue_redraw()


## Advances active startup time and refreshes intensity from the live Resource.
func _process(delta: float) -> void:
	if not _is_settled:
		if _start_delay_remaining > 0.0:
			_start_delay_remaining = maxf(0.0, _start_delay_remaining - delta)
		else:
			_elapsed = minf(_elapsed + minf(delta, 0.1), _duration)
	_update_visual_state()
	queue_redraw()
	if _elapsed >= _duration:
		_is_settled = true


## Redraws the lamp halo after the overlay changes dimensions.
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


## Draws the reusable halo within the fitted wordmark image rectangle.
func _draw() -> void:
	if _wordmark == null or not is_instance_valid(_wordmark) or _wordmark.texture == null:
		return
	var image_rect := _fitted_wordmark_rect()
	if image_rect.size.x <= 0.0 or image_rect.size.y <= 0.0 or _halo_opacity <= 0.0:
		return
	var halo_size := Vector2(image_rect.size.x * HALO_WIDTH_RATIO, 0.0)
	halo_size.y = halo_size.x * float(LAMP_HALO.get_height()) / float(LAMP_HALO.get_width())
	var halo_center := image_rect.position + Vector2(image_rect.size.x * HALO_CENTER.x, image_rect.size.y * HALO_CENTER.y)
	var halo_rect := Rect2(halo_center - halo_size * 0.5, halo_size)
	var scaled_size := halo_rect.size * _halo_scale
	halo_rect.position += (halo_rect.size - scaled_size) * 0.5
	halo_rect.size = scaled_size
	draw_texture_rect(LAMP_HALO, halo_rect, false, Color(1.0, 1.0, 1.0, _halo_opacity))


## Restores the source wordmark when this temporary overlay is removed.
func _exit_tree() -> void:
	if is_instance_valid(_wordmark):
		_wordmark.modulate = Color.WHITE


## Builds the preview-matched flicker keys from the current count and gap.
func _build_timeline() -> void:
	_timeline.clear()
	var count := int(round(_read_tuning_value("title_initial_blink_count", 3.0)))
	count = clampi(count, 0, 8)
	var gap := clampf(_read_tuning_value("title_initial_blink_interval_ms", 150.0), 20.0, 2000.0) / 1000.0
	var fade_duration := maxf(0.0, _read_tuning_value("title_fade_in_duration_seconds", 0.4))
	var prelude := fade_duration
	prelude += maxf(0.0, _read_tuning_value("title_reveal_pause_seconds", 0.3))
	var time := prelude
	_timeline.append(Vector2(0.0, 1.0))
	if count > 0:
		_timeline.append(Vector2(fade_duration, 1.0))
		_timeline.append(Vector2(prelude, DIM_LEVEL))
		time += LEAD_IN_DURATION
	for index in range(count):
		var peak := 0.78 if index % 2 == 1 else 0.96
		_timeline.append(Vector2(time, DIM_LEVEL))
		_timeline.append(Vector2(time + 0.020, peak))
		_timeline.append(Vector2(time + 0.050, peak))
		_timeline.append(Vector2(time + BLINK_DURATION, DIM_LEVEL))
		time += BLINK_DURATION
		if index < count - 1:
			time += gap
	if count > 0:
		time += SETTLE_DURATION
	_settled_at = time
	_duration = _settled_at + HALO_FADE_DURATION
	_timeline.append(Vector2(_settled_at, 1.0))
	_timeline.append(Vector2(_settled_at, 1.0))
	_timeline.append(Vector2(_duration, 1.0))


## Applies live intensity values to title brightness and halo reveal state.
func _update_visual_state() -> void:
	var waiting_for_start := not _is_settled and _start_delay_remaining > 0.0
	var level := 1.0 if waiting_for_start else _brightness_level(_elapsed)
	var fade_duration := maxf(0.0, _read_tuning_value("title_fade_in_duration_seconds", 0.4))
	var fade_progress := 1.0
	if waiting_for_start:
		fade_progress = 0.0
	elif fade_duration > 0.0:
		fade_progress = clampf(_elapsed / fade_duration, 0.0, 1.0)
	var title_opacity := _smoothstep(fade_progress)
	var intensity := clampf(_read_tuning_value("title_startup_intensity_percent", 100.0) / 100.0, 0.0, 2.0)
	_brightness = clampf(1.0 - (1.0 - level) * intensity, MIN_BRIGHTNESS, 1.0)
	if is_instance_valid(_wordmark):
		_wordmark.modulate = Color(_brightness, _brightness, _brightness, title_opacity)
	var halo_fade_progress := clampf((_elapsed - _settled_at) / HALO_FADE_DURATION, 0.0, 1.0)
	var eased_fade := _smoothstep(halo_fade_progress)
	var halo_intensity := clampf(_read_tuning_value("title_lamp_halo_intensity_percent", 270.0) / 100.0, 0.0, 3.0)
	_halo_opacity = minf(1.0, HALO_BASE_OPACITY * halo_intensity * eased_fade)
	_halo_scale = 0.90 + 0.10 * eased_fade


## Samples the piecewise smoothstep brightness timeline at the given time.
func _brightness_level(time: float) -> float:
	for index in range(1, _timeline.size()):
		var from_key := _timeline[index - 1]
		var to_key := _timeline[index]
		if time <= to_key.x:
			if is_equal_approx(to_key.x, from_key.x):
				return to_key.y
			var fraction := clampf((time - from_key.x) / (to_key.x - from_key.x), 0.0, 1.0)
			return lerpf(from_key.y, to_key.y, _smoothstep(fraction))
	return 1.0


## Returns the centered keep-aspect image bounds inside the parent TextureRect.
func _fitted_wordmark_rect() -> Rect2:
	var texture_size := _wordmark.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Rect2()
	var fit_scale := minf(_wordmark.size.x / texture_size.x, _wordmark.size.y / texture_size.y)
	var image_size := texture_size * fit_scale
	return Rect2((size - image_size) * 0.5, image_size)


## Reads a numeric animation tuning field, falling back if it is unavailable.
func _read_tuning_value(property_name: String, fallback: float) -> float:
	if not is_instance_valid(_tuning):
		return fallback
	var value: Variant = _tuning.get(property_name)
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return float(value)
	return fallback


## Matches the cubic easing used by the approved HTML motion preview.
func _smoothstep(value: float) -> float:
	return value * value * (3.0 - 2.0 * value)
