extends RefCounted

var selected_cell := 0
var selected_button := -1
var _width: int
var _height: int
var _button_count: int


func _init(width: int, height: int, button_count: int) -> void:
	assert(width > 0 and height > 0 and button_count > 0)
	_width = width
	_height = height
	_button_count = button_count


func is_on_board() -> bool:
	return selected_button == -1


func select_cell(index: int) -> void:
	selected_cell = clampi(index, 0, _width * _height - 1)
	selected_button = -1


func select_button(index: int) -> void:
	selected_button = clampi(index, 0, _button_count - 1)


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
