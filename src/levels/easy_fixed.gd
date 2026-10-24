extends RefCounted

const Board = preload("res://src/core/board_definition.gd")


static func create_board() -> Board:
	# A manually authored fixture; procedural generation is a separate task.
	return Board.new(PackedStringArray([
		".....",
		".2.1.",
		"..2..",
		".1.#.",
		".....",
	]))
