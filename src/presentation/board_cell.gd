extends Control

signal primary_clicked(index: int)
signal secondary_clicked(index: int)

const Visuals = preload("res://src/presentation/lumen_theme.gd")
const BULB = preload("res://assets/icons/bulb.svg")
const MARK = preload("res://assets/icons/annotation_x.svg")
const HOVER = preload("res://assets/icons/cell_hover.svg")

var cell_index := 0
var cell_extent := 76.0
var wall := false
var clue := -1
var bulb := false
var marked := false
var illuminated := false
var conflict := false
var exceeded := false
var interaction_enabled := true
var _hovered := false
var _clue_font := FontVariation.new()


func _ready() -> void:
	_clue_font.base_font = Visuals.FONT
	# OpenType axis tags use their four-byte integer representation.
	_clue_font.variation_opentype = {0x77676874: 650.0}
	custom_minimum_size = Vector2(cell_extent, cell_extent)
	mouse_entered.connect(func() -> void: _hovered = true; queue_redraw())
	mouse_exited.connect(func() -> void: _hovered = false; queue_redraw())


func refresh() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if interaction_enabled and not wall else Control.CURSOR_ARROW
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if wall or not interaction_enabled or not event is InputEventMouseButton:
		return
	if not event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		primary_clicked.emit(cell_index)
		accept_event()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		secondary_clicked.emit(cell_index)
		accept_event()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var corner_radius := mini(11, roundi(size.x * 0.14))
	var base := Visuals.WALL if wall else (Visuals.SUNLIGHT if illuminated else Visuals.CREAM)
	draw_style_box(Visuals.box(base, corner_radius), rect)
	if wall and clue >= 0:
		_draw_centered(str(clue), mini(30, roundi(size.x * 0.43)), Visuals.WARNING if exceeded else Visuals.CREAM)
	elif not wall:
		var inset := size * 0.18
		if bulb:
			draw_texture_rect(BULB, Rect2(inset, size - inset * 2), false)
		elif marked:
			draw_texture_rect(MARK, Rect2(inset, size - inset * 2), false)
		if _hovered and interaction_enabled:
			draw_texture_rect(HOVER, rect, false)
	if conflict or exceeded:
		var badge_radius := minf(8.0, size.x * 0.12)
		var badge_center := Vector2(size.x - badge_radius - 4, badge_radius + 4)
		draw_style_box(Visuals.box(Color.TRANSPARENT, corner_radius, Visuals.WARNING, 3), rect.grow(-1))
		draw_circle(badge_center, badge_radius, Visuals.WARNING)
		var badge_font_size := roundi(badge_radius * 1.8)
		draw_string(_clue_font, badge_center + Vector2(-badge_radius * 0.3, badge_radius * 0.6), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, badge_font_size, Color.WHITE)


func _draw_centered(text: String, font_size: int, color: Color) -> void:
	var extent: Vector2 = _clue_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var baseline: float = (size.y + _clue_font.get_ascent(font_size) - _clue_font.get_descent(font_size)) * 0.5
	draw_string(_clue_font, Vector2((size.x - extent.x) * 0.5, baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
