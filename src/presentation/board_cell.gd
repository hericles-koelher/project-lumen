extends Control
## Draws one board cell and emits mouse actions for playable cells.

## Emitted when the primary clicked event occurs.
signal primary_clicked(index: int)
## Emitted when the secondary clicked event occurs.
signal secondary_clicked(index: int)
## Emitted when the pointer enters this cell, allowing the board to choose pointer selection.
signal pointer_entered(index: int)
## Emitted when the pointer leaves this cell so navigation focus can resume its highlight.
signal pointer_exited(index: int)

## Shared palette and style helpers used to draw the cell.
const Visuals = preload("res://src/presentation/lumen_theme.gd")
## Bulb illustration drawn inside a cell.
const BULB = preload("res://assets/icons/bulb.svg")
## X annotation illustration drawn inside a cell.
const MARK = preload("res://assets/icons/annotation_x.svg")
## Shared highlight illustration for pointer hover and keyboard selection.
const HOVER = preload("res://assets/icons/cell_hover.svg")

## Row-major index represented by this cell view.
var cell_index := 0
## Width and height assigned to this square cell view.
var cell_extent := 76.0
## Whether this cell is a wall.
var wall := false
## Numbered-wall clue, or -1 for a playable or unnumbered cell.
var clue := -1
## Whether a bulb is placed in this playable cell.
var bulb := false
## Whether this playable cell shows an X annotation.
var marked := false
## Whether a bulb illuminates this cell.
var illuminated := false
## Whether a bulb in this cell conflicts with another bulb.
var conflict := false
## Whether this numbered wall currently has too many adjacent bulbs.
var exceeded := false
## Whether this cell currently accepts mouse actions.
var interaction_enabled := true
## Whether keyboard navigation currently selects this cell.
var keyboard_selected := false
## Whether pointer hover is the active source for the shared cell marker.
var pointer_selection_active := false
## Whether the pointer is currently over this cell.
var _hovered := false
## Font variation used for clue numbers and warning badges.
var _clue_font := FontVariation.new()


## Initializes this node after it enters the scene tree.
func _ready() -> void:
	_clue_font.base_font = Visuals.FONT
	# OpenType axis tags use their four-byte integer representation.
	_clue_font.variation_opentype = {0x77676874: 650.0}
	custom_minimum_size = Vector2(cell_extent, cell_extent)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


## Makes this cell the pointer selection when the pointer enters it.
func _on_mouse_entered() -> void:
	_hovered = true
	if not wall and interaction_enabled:
		pointer_entered.emit(cell_index)
	queue_redraw()


## Clears pointer hover and notifies the board that pointer selection has ended.
func _on_mouse_exited() -> void:
	_hovered = false
	pointer_exited.emit(cell_index)
	queue_redraw()


## Updates this cell view after its displayed state or interaction changes.
func refresh() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if interaction_enabled and not wall else Control.CURSOR_ARROW
	queue_redraw()


## Emits the appropriate mouse action when a playable cell is clicked.
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


## Draws the cell surface, its contents, and the current interaction indicators.
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
	if (keyboard_selected or (_hovered and pointer_selection_active)) and interaction_enabled:
		draw_texture_rect(HOVER, rect, false)
	if conflict or exceeded:
		var badge_radius := minf(8.0, size.x * 0.12)
		var badge_center := Vector2(size.x - badge_radius - 4, badge_radius + 4)
		draw_style_box(Visuals.box(Color.TRANSPARENT, corner_radius, Visuals.WARNING, 3), rect.grow(-1))
		draw_circle(badge_center, badge_radius, Visuals.WARNING)
		var badge_font_size := roundi(badge_radius * 1.8)
		draw_string(_clue_font, badge_center + Vector2(-badge_radius * 0.3, badge_radius * 0.6), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, badge_font_size, Color.WHITE)


## Draws text centered within this cell.
func _draw_centered(text: String, font_size: int, color: Color) -> void:
	var extent: Vector2 = _clue_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var baseline: float = (size.y + _clue_font.get_ascent(font_size) - _clue_font.get_descent(font_size)) * 0.5
	draw_string(_clue_font, Vector2((size.x - extent.x) * 0.5, baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
