extends SceneTree
## Checks board rules, player actions, and state reset behavior.

## Board-definition type used by the rule checks.
const Board = preload("res://src/core/board_definition.gd")
## Game-state type whose Akari rules are under test.
const State = preload("res://src/core/game_state.gd")
## Factory for the manually authored test fixture.
const FixedLevel = preload("res://src/levels/easy_fixed.gd")

## Number of failed assertions in this standalone check runner.
var _failures := 0
## Number of assertions evaluated by this standalone check runner.
var _checks := 0


## Runs each core rule check and exits with a failure status when needed.
func _init() -> void:
	_test_light_and_walls()
	_test_conflicts_and_removal()
	_test_clues_at_boundaries()
	_test_annotations_and_reset()
	_test_annotation_replaces_conflicting_bulb()
	_test_fixed_level()
	print("Core checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


## Records a failed check when the supplied condition is false.
func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(description)


## Checks illumination propagation and wall blocking.
func _test_light_and_walls() -> void:
	var state := State.new(Board.new(PackedStringArray(["..#.."])))
	state.toggle_bulb(0)
	var result := state.evaluate()
	_expect(result.lit_count == 2, "A wall must stop horizontal illumination.")
	_expect(not result.illuminated[3], "Light must not pass through a wall.")
	_expect(not state.toggle_bulb(2), "Walls must reject bulbs.")
	state.toggle_bulb(4)
	result = state.evaluate()
	_expect(result.solved, "Bulbs separated by a wall must not conflict.")
	var vertical := State.new(Board.new(PackedStringArray([".", ".", "#", "."])))
	vertical.toggle_bulb(0)
	_expect(vertical.evaluate().lit_count == 2, "A wall must stop vertical illumination.")


## Checks bulb conflicts and the effect of removing a bulb.
func _test_conflicts_and_removal() -> void:
	var state := State.new(Board.new(PackedStringArray(["..."])))
	state.toggle_bulb(0)
	state.toggle_bulb(2)
	var result := state.evaluate()
	_expect(result.conflicting_bulbs == 2, "Both bulbs in a shared sight line must be marked.")
	_expect(not result.solved, "A fully lit board with conflicting bulbs is not solved.")
	state.toggle_bulb(2)
	result = state.evaluate()
	_expect(result.conflicting_bulbs == 0 and result.solved, "Removing a bulb must clear conflicts and reevaluate victory.")


## Checks clue counting at board edges and corners.
func _test_clues_at_boundaries() -> void:
	var corner := State.new(Board.new(PackedStringArray(["2.", ".."])))
	corner.toggle_bulb(1)
	_expect(not corner.evaluate().solved, "An unmet clue must prevent victory.")
	corner.toggle_bulb(2)
	_expect(corner.evaluate().solved, "A corner clue must count only its two existing orthogonal neighbors.")
	var zero := State.new(Board.new(PackedStringArray(["0."])))
	zero.toggle_bulb(1)
	_expect(zero.evaluate().exceeded_clues == 1, "A bulb beside a zero clue must be reported immediately.")
	_expect(not zero.evaluate().solved, "An exceeded clue must prevent victory even when every open cell is lit.")


## Checks annotation toggling and clean state reset.
func _test_annotations_and_reset() -> void:
	var state := State.new(Board.new(PackedStringArray(["..#"])))
	state.toggle_annotation(0)
	_expect(state.annotations[0] == 1 and state.evaluate().lit_count == 0, "An annotation must not emit light.")
	_expect(not state.toggle_annotation(2), "Walls must reject annotations.")
	state.toggle_bulb(0)
	_expect(state.annotations[0] == 0 and state.bulbs[0] == 1, "Placing a bulb must replace an annotation.")
	_expect(state.toggle_annotation(0), "An annotation action on a bulb must change the cell.")
	_expect(state.bulbs[0] == 0 and state.annotations[0] == 1, "The annotation action must replace a bulb with X atomically.")
	_expect(state.evaluate().lit_count == 0, "Replacing the last bulb must remove its illumination.")
	state.toggle_annotation(0)
	_expect(state.annotations[0] == 0, "Repeating the annotation action must remove X.")
	state.toggle_bulb(0)
	state.toggle_annotation(1)
	_expect(state.evaluate().solved, "Annotations must not prevent a valid solution.")
	state.reset()
	_expect(state.bulbs.count(1) == 0 and state.annotations.count(1) == 0, "Restart must clear bulbs and annotations.")
	_expect(not state.evaluate().solved, "Restart must clear the solved state.")


## Checks that an annotation replaces a bulb and updates derived state.
func _test_annotation_replaces_conflicting_bulb() -> void:
	var state := State.new(Board.new(PackedStringArray(["0.."])))
	state.toggle_bulb(1)
	state.toggle_bulb(2)
	var result := state.evaluate()
	_expect(result.conflicting_bulbs == 2 and result.exceeded_clues == 1, "The fixture must start with a bulb conflict and an exceeded clue.")
	state.toggle_annotation(1)
	result = state.evaluate()
	_expect(result.conflicting_bulbs == 0 and result.exceeded_clues == 0, "Replacing a bulb with X must update conflicts and adjacent clues.")
	_expect(result.solved, "An annotation replacement that completes the puzzle must trigger victory.")


## Checks the manually authored board fixture.
func _test_fixed_level() -> void:
	var state := State.new(FixedLevel.create_board())
	_expect(state.board.width == 5 and state.board.height == 5, "The Easy fixture must be 5 by 5.")
	_expect(state.board.wall_indices().size() == 5, "The Easy fixture must contain five walls.")
	for index in [0, 7, 11, 14, 22]:
		state.toggle_bulb(index)
	var result := state.evaluate()
	_expect(result.lit_count == 20, "The known fixture solution must illuminate all twenty playable cells.")
	_expect(result.solved, "The fixed board must accept a solution satisfying the rules.")
