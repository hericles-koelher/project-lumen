extends RefCounted
## Tracks focus movement between board cells and the action-button row.

## Row-major index of the remembered board selection.
var selected_cell := 0
## Index of the focused action button, or -1 when the board has focus.
var selected_button := -1
## Number of columns in the navigation grid.
var _width: int
## Number of rows in the navigation grid.
var _height: int
## Number of action buttons reachable below the board.
var _button_count: int


## Creates a navigation model for the supplied board dimensions and button count.
func _init(width: int, height: int, button_count: int) -> void:
	assert(width > 0 and height > 0 and button_count > 0)
	_width = width
	_height = height
	_button_count = button_count


## Returns whether focus currently belongs to a board cell.
func is_on_board() -> bool:
	return selected_button == -1


## Selects a board cell while clamping the index to the board bounds.
func select_cell(index: int) -> void:
	selected_cell = clampi(index, 0, _width * _height - 1)
	selected_button = -1


## Selects an action button while clamping the index to the button row.
func select_button(index: int) -> void:
	selected_button = clampi(index, 0, _button_count - 1)


## Moves focus one step while respecting board and button-row boundaries.
func move(direction: Vector2i, button_below: int = 0) -> void:
	if not is_on_board():
		if direction == Vector2i.UP:
			selected_button = -1
		elif direction.x != 0:
			selected_button = clampi(selected_button + direction.x, 0, _button_count - 1)
		return
	var x := selected_cell % _width
	var y := floori(selected_cell / float(_width))
	if direction == Vector2i.DOWN and y == _height - 1:
		select_button(button_below)
		return
	x = clampi(x + direction.x, 0, _width - 1)
	y = clampi(y + direction.y, 0, _height - 1)
	selected_cell = y * _width + x
