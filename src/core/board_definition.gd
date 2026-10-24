class_name LumenBoardDefinition
extends RefCounted

const UNNUMBERED := -1

var width: int:
	get: return _width
var height: int:
	get: return _height

var _width: int
var _height: int
var _walls: Dictionary = {}
var _rows: PackedStringArray


func _init(rows: PackedStringArray) -> void:
	_rows = rows.duplicate()
	assert(not rows.is_empty(), "A board needs at least one row.")
	_width = rows[0].length()
	_height = rows.size()
	assert(_width > 0, "A board needs at least one column.")
	for y in range(_height):
		assert(rows[y].length() == _width, "Board rows must have equal widths.")
		for x in range(_width):
			var symbol := rows[y][x]
			assert(symbol == "." or symbol == "#" or symbol in "01234", "Invalid cell symbol.")
			if symbol != ".":
				_walls[index_of(Vector2i(x, y))] = UNNUMBERED if symbol == "#" else symbol.to_int()


func cell_count() -> int:
	return _width * _height


func contains(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < _width and cell.y < _height


func index_of(cell: Vector2i) -> int:
	return cell.y * _width + cell.x


func position_of(index: int) -> Vector2i:
	return Vector2i(index % _width, index / _width)


func is_wall(index: int) -> bool:
	return _walls.has(index)


func is_playable(index: int) -> bool:
	return index >= 0 and index < cell_count() and not is_wall(index)


func clue_at(index: int) -> int:
	return _walls.get(index, UNNUMBERED)


func wall_indices() -> Array:
	return _walls.keys()


func to_rows() -> PackedStringArray:
	return _rows.duplicate()
