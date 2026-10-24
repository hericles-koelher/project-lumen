class_name LumenGameState
extends RefCounted
## Stores player placements and evaluates Akari rules for a board.

## Board-definition script used for the typed board reference.
const Board = preload("res://src/core/board_definition.gd")
## The four orthogonal directions used for clue and light calculations.
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

## Board definition whose layout this state evaluates.
var board: Board
## Per-cell flags indicating which playable cells contain bulbs.
var bulbs := PackedByteArray()
## Per-cell flags indicating which playable cells contain X annotations.
var annotations := PackedByteArray()


## Creates empty bulb and annotation arrays sized to the supplied board.
func _init(definition: Board) -> void:
	board = definition
	bulbs.resize(board.cell_count())
	annotations.resize(board.cell_count())
	reset()


## Clears all bulbs and annotations from the current game state.
func reset() -> void:
	bulbs.fill(0)
	annotations.fill(0)


## Toggles a bulb on a playable cell and clears any annotation there.
func toggle_bulb(index: int) -> bool:
	if not board.is_playable(index):
		return false
	bulbs[index] = 0 if bulbs[index] else 1
	annotations[index] = 0
	return true


## Toggles an X annotation, replacing a bulb when one occupies the cell.
func toggle_annotation(index: int) -> bool:
	if not board.is_playable(index):
		return false
	if bulbs[index]:
		bulbs[index] = 0
		annotations[index] = 1
	else:
		annotations[index] = 0 if annotations[index] else 1
	return true


## Counts bulbs in the four orthogonally adjacent cells.
func adjacent_bulb_count(index: int) -> int:
	var count := 0
	for direction in DIRECTIONS:
		var neighbor: Vector2i = board.position_of(index) + direction
		if board.contains(neighbor) and bulbs[board.index_of(neighbor)]:
			count += 1
	return count


## Calculates illumination, conflicts, clue counts, and whether the board is solved.
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
