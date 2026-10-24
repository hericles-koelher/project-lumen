class_name LumenGameState
extends RefCounted

const Board = preload("res://src/core/board_definition.gd")
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

var board: Board
var bulbs := PackedByteArray()
var annotations := PackedByteArray()


func _init(definition: Board) -> void:
	board = definition
	bulbs.resize(board.cell_count())
	annotations.resize(board.cell_count())
	reset()


func reset() -> void:
	bulbs.fill(0)
	annotations.fill(0)


func toggle_bulb(index: int) -> bool:
	if not board.is_playable(index):
		return false
	bulbs[index] = 0 if bulbs[index] else 1
	annotations[index] = 0
	return true


func toggle_annotation(index: int) -> bool:
	if not board.is_playable(index) or bulbs[index]:
		return false
	annotations[index] = 0 if annotations[index] else 1
	return true


func adjacent_bulb_count(index: int) -> int:
	var count := 0
	for direction in DIRECTIONS:
		var neighbor: Vector2i = board.position_of(index) + direction
		if board.contains(neighbor) and bulbs[board.index_of(neighbor)]:
			count += 1
	return count


func evaluate() -> Dictionary:
	var illuminated := PackedByteArray()
	var conflicts := PackedByteArray()
	illuminated.resize(board.cell_count())
	conflicts.resize(board.cell_count())
	illuminated.fill(0)
	conflicts.fill(0)
	for index in range(board.cell_count()):
		if not bulbs[index]:
			continue
		illuminated[index] = 1
		for direction in DIRECTIONS:
			var cell: Vector2i = board.position_of(index) + direction
			while board.contains(cell):
				var target := board.index_of(cell)
				if board.is_wall(target):
					break
				illuminated[target] = 1
				if bulbs[target]:
					conflicts[index] = 1
					conflicts[target] = 1
				cell += direction

	var clue_counts: Dictionary = {}
	var exceeded_clues := 0
	var all_clues_satisfied := true
	for index in board.wall_indices():
		var clue := board.clue_at(index)
		if clue == Board.UNNUMBERED:
			continue
		var count := adjacent_bulb_count(index)
		clue_counts[index] = count
		if count != clue:
			all_clues_satisfied = false
		if count > clue:
			exceeded_clues += 1

	var lit_count := 0
	var playable_count := 0
	var conflicting_bulbs := 0
	for index in range(board.cell_count()):
		if board.is_playable(index):
			playable_count += 1
			lit_count += illuminated[index]
		conflicting_bulbs += conflicts[index]
	return {
		"illuminated": illuminated,
		"conflicts": conflicts,
		"clue_counts": clue_counts,
		"lit_count": lit_count,
		"playable_count": playable_count,
		"conflicting_bulbs": conflicting_bulbs,
		"exceeded_clues": exceeded_clues,
		"solved": lit_count == playable_count and conflicting_bulbs == 0 and all_clues_satisfied,
	}
