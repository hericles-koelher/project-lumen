class_name LumenBoardDefinition
extends RefCounted
## Defines the immutable dimensions, walls, and clues of an Akari board.

## Integer marker returned for walls without a numbered clue.
const UNNUMBERED := -1

## Number of columns in the board.
var width: int:
	get: return _width
## Number of rows in the board.
var height: int:
	get: return _height

## Board width in cells, derived from the encoded rows.
var _width: int
## Board height in cells, derived from the encoded rows.
var _height: int
## Wall indices mapped to their clue value or the unnumbered sentinel.
var _walls: Dictionary = {}
## Private copy of the encoded board rows used for export.
var _rows: PackedStringArray


## Validates and stores a rectangular board encoded with playable cells and wall clues.
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


## Returns the total number of cells on the board.
func cell_count() -> int:
	return _width * _height


## Returns whether the board contains the given grid coordinate.
func contains(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < _width and cell.y < _height


## Converts a grid coordinate to its row-major cell index.
func index_of(cell: Vector2i) -> int:
	return cell.y * _width + cell.x


## Converts a row-major cell index to its grid coordinate.
func position_of(index: int) -> Vector2i:
	return Vector2i(index % _width, index / _width)


## Returns whether the indexed cell is a wall.
func is_wall(index: int) -> bool:
	return _walls.has(index)


## Returns whether the index is in range and refers to a playable cell.
func is_playable(index: int) -> bool:
	return index >= 0 and index < cell_count() and not is_wall(index)


## Returns the numbered-wall clue or the unnumbered-wall sentinel.
func clue_at(index: int) -> int:
	return _walls.get(index, UNNUMBERED)


## Returns the indices of all numbered and unnumbered walls.
func wall_indices() -> Array:
	return _walls.keys()


## Returns a copy of the board rows in their encoded form.
func to_rows() -> PackedStringArray:
	return _rows.duplicate()
