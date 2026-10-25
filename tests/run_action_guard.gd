extends SceneTree
## Checks time-bounded suppression for repeated actions on the same cell.

## Guard type whose deterministic timing behavior is exercised by these checks.
const CellActionGuard = preload("res://src/input/cell_action_guard.gd")

## Number of assertions evaluated by this standalone check runner.
var _checks := 0
## Number of failed assertions in this standalone check runner.
var _failures := 0


## Runs the guard checks and exits with a failure status when needed.
func _init() -> void:
	_test_default_interval()
	_test_action_and_cell_scope()
	_test_reset()
	_test_configurable_interval()
	print("Action guard checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


## Records a failed check when the supplied condition is false.
func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


## Checks default suppression, rejection without extension, and the exact boundary.
func _test_default_interval() -> void:
	var guard := CellActionGuard.new()
	_expect(guard.allow(&"bulb", 4, 1000), "The first action on a cell must be allowed.")
	_expect(not guard.allow(&"bulb", 4, 1149), "The same action must be suppressed inside the default interval.")
	_expect(guard.allow(&"bulb", 4, 1150), "The action must be allowed exactly at the default interval boundary.")
	_expect(not guard.allow(&"bulb", 4, 1299), "A newly accepted action must start a fresh interval.")
	_expect(guard.allow(&"bulb", 4, 1300), "A suppressed attempt must not extend the interval.")


## Checks that another action or cell has an independent suppression interval.
func _test_action_and_cell_scope() -> void:
	var guard := CellActionGuard.new()
	_expect(guard.allow(&"bulb", 2, 10), "The first cell action must be allowed.")
	_expect(guard.allow(&"annotation", 2, 10), "A different action on the same cell must be allowed immediately.")
	_expect(guard.allow(&"bulb", 3, 10), "The same action on a different cell must be allowed immediately.")
	_expect(not guard.allow(&"bulb", 2, 11), "The original action and cell pair must remain suppressed.")


## Checks that resetting the guard removes every accepted timestamp.
func _test_reset() -> void:
	var guard := CellActionGuard.new()
	_expect(guard.allow(&"bulb", 1, 50), "The initial action must be allowed before reset.")
	guard.reset()
	_expect(guard.allow(&"bulb", 1, 51), "Reset must clear suppression for the previous action and cell.")


## Checks suppression and its boundary with a caller-selected interval.
func _test_configurable_interval() -> void:
	var guard := CellActionGuard.new(40)
	_expect(guard.allow(&"annotation", 8, 200), "A configurable guard must allow the first action.")
	_expect(not guard.allow(&"annotation", 8, 239), "A configurable guard must suppress before its interval.")
	_expect(guard.allow(&"annotation", 8, 240), "A configurable guard must allow exactly at its interval boundary.")
