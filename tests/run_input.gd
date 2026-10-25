extends SceneTree
## Checks keyboard bindings, board navigation, and input-independent cell actions.

## Input binding type used to inspect named keyboard actions.
const Keyboard = preload("res://src/input/input_bindings.gd")
## Board and button focus model exercised by these checks.
const Navigation = preload("res://src/input/board_navigation.gd")
## Factory for the manually authored board fixture.
const FixedLevel = preload("res://src/levels/easy_fixed.gd")
## Board-definition type used to create a fixture with walls in navigation paths.
const Board = preload("res://src/core/board_definition.gd")
## Game-state type used to confirm that actions remain device-independent.
const State = preload("res://src/core/game_state.gd")

## Number of assertions evaluated by this standalone check runner.
var _checks := 0
## Number of failed assertions in this standalone check runner.
var _failures := 0


## Runs keyboard and navigation checks and exits with a failure status when needed.
func _init() -> void:
	_test_bindings()
	for size in [5, 7, 9]:
		_test_navigation(size)
	_test_wall_navigation()
	_test_wall_actions()
	print("Input checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


## Records a failed check when the supplied condition is false.
func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


## Creates a keyboard event for a key and optional repeat state.
func _event(key: Key, repeated: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = true
	event.echo = repeated
	return event


## Checks keyboard and gamepad action mappings.
func _test_bindings() -> void:
	Keyboard.install()
	var directions := {
		KEY_LEFT: Vector2i.LEFT, KEY_A: Vector2i.LEFT,
		KEY_RIGHT: Vector2i.RIGHT, KEY_D: Vector2i.RIGHT,
		KEY_UP: Vector2i.UP, KEY_W: Vector2i.UP,
		KEY_DOWN: Vector2i.DOWN, KEY_S: Vector2i.DOWN,
	}
	for key in directions:
		_expect(Keyboard.direction_for(_event(key)) == directions[key], "Arrows and WASD must map to the expected direction.")
	_expect(Keyboard.direction_for(_event(KEY_S, true)) == Vector2i.DOWN, "Held navigation keys may repeat.")
	_expect(Keyboard.pressed(_event(KEY_SPACE), "lumen_bulb"), "Space must map to the bulb action.")
	_expect(Keyboard.pressed(_event(KEY_X), "lumen_annotation"), "X must map to the annotation action.")
	_expect(not Keyboard.pressed(_event(KEY_SPACE, true), "lumen_bulb"), "Held Space must not repeatedly toggle bulbs.")
	_expect(not Keyboard.pressed(_event(KEY_X, true), "lumen_annotation"), "Held X must not repeatedly toggle annotations.")
	for key in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		_expect(Keyboard.pressed(_event(key), "lumen_activate"), "Enter, keypad Enter, and Space must activate buttons.")
	_expect(not Keyboard.pressed(_event(KEY_ENTER), "lumen_bulb"), "Enter must not toggle a board bulb.")
	var modified := _event(KEY_W)
	modified.ctrl_pressed = true
	_expect(Keyboard.direction_for(modified) == Vector2i.ZERO, "Modified shortcuts must not move the board selection.")
	var before := InputMap.action_get_events("lumen_left").size()
	Keyboard.install()
	_expect(InputMap.action_get_events("lumen_left").size() == before, "Installing bindings twice must not duplicate events.")


## Checks focus movement for a board of the requested size.
func _test_navigation(size: int) -> void:
	var navigation := Navigation.new(size, size, 3)
	_expect(navigation.selected_cell == 0 and navigation.is_on_board(), "A level must start at its top-left cell.")
	navigation.move(Vector2i.UP)
	navigation.move(Vector2i.LEFT)
	_expect(navigation.selected_cell == 0, "Top and left edges must not wrap.")
	navigation.select_cell(size - 1)
	navigation.move(Vector2i.RIGHT)
	_expect(navigation.selected_cell == size - 1, "The right edge must not wrap.")
	var last_row_cell := size * (size - 1) + 2
	navigation.select_cell(last_row_cell)
	navigation.move(Vector2i.DOWN, 1)
	_expect(navigation.selected_button == 1 and navigation.selected_cell == last_row_cell, "Down must reach the button below while remembering the cell.")
	navigation.move(Vector2i.RIGHT)
	navigation.move(Vector2i.RIGHT)
	_expect(navigation.selected_button == 2, "Button navigation must stop at the rightmost button.")
	navigation.move(Vector2i.LEFT)
	navigation.move(Vector2i.LEFT)
	navigation.move(Vector2i.LEFT)
	_expect(navigation.selected_button == 0, "Button navigation must stop at the leftmost button.")
	navigation.move(Vector2i.DOWN)
	_expect(navigation.selected_button == 0, "Down in the bottom button row must stay in place.")
	navigation.move(Vector2i.UP)
	_expect(navigation.is_on_board() and navigation.selected_cell == last_row_cell, "Up must return to the remembered cell.")
	navigation.select_cell(0)
	navigation.move(Vector2i.RIGHT)
	_expect(navigation.selected_cell == 1, "Movement must advance exactly one cell.")


## Checks that navigation treats every cell, including consecutive walls, as a focus target.
func _test_wall_navigation() -> void:
	var board := Board.new(PackedStringArray(["###.", "#...", "#...", "...."]))
	var navigation := Navigation.new(4, 4, 3)
	_expect(board.is_wall(0) and navigation.selected_cell == 0, "Selection must start at a top-left wall.")
	navigation.move(Vector2i.RIGHT)
	_expect(navigation.selected_cell == 1 and board.is_wall(navigation.selected_cell), "Horizontal movement must advance one cell onto a wall.")
	navigation.move(Vector2i.RIGHT)
	_expect(navigation.selected_cell == 2 and board.is_wall(navigation.selected_cell), "Horizontal movement must advance one cell across consecutive walls.")
	navigation.select_cell(0)
	navigation.move(Vector2i.DOWN)
	_expect(navigation.selected_cell == 4 and board.is_wall(navigation.selected_cell), "Vertical movement must advance one cell onto a wall.")
	navigation.move(Vector2i.DOWN)
	_expect(navigation.selected_cell == 8 and board.is_wall(navigation.selected_cell), "Vertical movement must cross consecutive walls one cell at a time.")
	navigation.move(Vector2i.DOWN)
	_expect(navigation.selected_cell == 12 and not board.is_wall(navigation.selected_cell), "Vertical movement must continue one cell beyond the wall run.")
	navigation.select_cell(2)
	_expect(navigation.selected_cell == 2 and board.is_wall(2), "Direct selection must accept a wall cell.")
	navigation.select_cell(-1)
	_expect(navigation.selected_cell == 0, "Direct selection must clamp below the board to cell zero.")
	navigation.select_cell(99)
	_expect(navigation.selected_cell == 15, "Direct selection must clamp above the board to its last cell.")
	navigation.select_button(2)
	navigation.set_button_count(2)
	_expect(navigation.selected_button == 1, "Shrinking the action row must clamp its focused button.")
	navigation.set_button_count(3)
	navigation.move(Vector2i.RIGHT)
	_expect(navigation.selected_button == 2, "Growing the action row must make its new button reachable.")


## Checks that wall cells reject bulb and annotation actions without changing state.
func _test_wall_actions() -> void:
	var state := State.new(FixedLevel.create_board())
	var navigation := Navigation.new(5, 5, 3)
	navigation.select_cell(6)
	_expect(state.board.is_wall(navigation.selected_cell), "The selected fixture position must be a wall.")
	var bulbs_before := state.bulbs.duplicate()
	var annotations_before := state.annotations.duplicate()
	_expect(not state.toggle_bulb(navigation.selected_cell), "The shared bulb action must ignore the selected wall.")
	_expect(not state.toggle_annotation(navigation.selected_cell), "The shared annotation action must ignore the selected wall.")
	_expect(state.bulbs == bulbs_before and state.annotations == annotations_before, "Rejected wall actions must leave bulbs and annotations unchanged.")
	navigation.select_cell(5)
	navigation.move(Vector2i.RIGHT)
	_expect(navigation.selected_cell == 6, "Directional navigation must land on a wall one cell away.")
	navigation.move(Vector2i.RIGHT)
	_expect(navigation.selected_cell == 7, "Directional navigation must move one cell past a wall.")
