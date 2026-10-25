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


## Creates a focus model for a rectangular board and an action-button row.
## Every board position is navigable, including positions occupied by walls.
func _init(width: int, height: int, button_count: int) -> void:
	assert(width > 0 and height > 0 and button_count > 0)
	_width = width
	_height = height
	_button_count = button_count


## Returns whether focus currently belongs to a board cell.
func is_on_board() -> bool:
	return selected_button == -1


## Selects any board cell within bounds, clamping requests to the nearest edge.
func select_cell(index: int) -> void:
	selected_cell = clampi(index, 0, _width * _height - 1)
	selected_button = -1


## Selects an action button while clamping the index to the button row.
func select_button(index: int) -> void:
	selected_button = clampi(index, 0, _button_count - 1)


## Updates the action-button count while keeping the selected index valid.
func set_button_count(count: int) -> void:
	assert(count > 0)
	_button_count = count
	if selected_button >= 0:
		selected_button = clampi(selected_button, 0, _button_count - 1)


## Moves focus by one in-bounds board cell or button without wrapping around.
func move(direction: Vector2i, button_below: int = 0) -> void:
	if direction == Vector2i.ZERO or absi(direction.x) + absi(direction.y) != 1:
		return
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
	var candidate := Vector2i(x, y) + direction
	if candidate.x >= 0 and candidate.y >= 0 and candidate.x < _width and candidate.y < _height:
		selected_cell = candidate.y * _width + candidate.x
