extends RefCounted
## Provides a manually authored board fixture for domain checks.

## Board-definition type returned by the fixture factory.
const Board = preload("res://src/core/board_definition.gd")


## Creates the fixed test board from its compact row representation.
static func create_board() -> Board:
	# A manually authored fixture; procedural generation is a separate task.
	return Board.new(PackedStringArray([
		".....",
		".2.1.",
		"..2..",
		".1.#.",
		".....",
	]))
