extends SceneTree
## Checks standardized gamepad bindings, device state, and direction repeat behavior.

## Standardized keyboard and gamepad action mapping under test.
const Bindings = preload("res://src/input/input_bindings.gd")
## Per-device gamepad direction tracker under test.
const Pad = preload("res://src/input/gamepad_state.gd")
## Held-direction repeat model under test.
const Repeat = preload("res://src/input/direction_repeat.gd")

## Number of assertions evaluated by this standalone check runner.
var _checks := 0
## Number of failed assertions in this standalone check runner.
var _failures := 0


## Runs gamepad mapping and state checks, then exits with a failure status when needed.
func _init() -> void:
	Bindings.install()
	_test_actions()
	_test_dpad_and_devices()
	_test_stick()
	_test_repeat()
	print("Gamepad checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


## Records a failed check when the supplied condition is false.
func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


## Creates a synthetic gamepad button event for a device.
func _button(button: JoyButton, pressed: bool = true, device: int = 2) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = pressed
	return event


## Creates a synthetic gamepad axis event for a device.
func _motion(axis: JoyAxis, value: float, device: int = 2) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = value
	return event


## Checks standardized input action mappings.
func _test_actions() -> void:
	for device in [0, 2, 7]:
		_expect(Bindings.pressed(_button(JOY_BUTTON_A, true, device), "lumen_bulb"), "A must map to bulbs on every device index.")
		_expect(Bindings.pressed(_button(JOY_BUTTON_A, true, device), "lumen_activate"), "A must also confirm interface buttons.")
		_expect(Bindings.pressed(_button(JOY_BUTTON_X, true, device), "lumen_annotation"), "X must map to annotations.")
		_expect(Bindings.pressed(_button(JOY_BUTTON_B, true, device), "lumen_back"), "B must map to Back.")
	_expect(not Bindings.pressed(_button(JOY_BUTTON_A, false), "lumen_bulb"), "A release must not activate the bulb action.")
	_expect(not Bindings.pressed(_button(JOY_BUTTON_X), "lumen_bulb"), "X must not toggle a bulb.")
	_expect(Bindings.direction_for(_button(JOY_BUTTON_DPAD_LEFT)) == Vector2i.LEFT, "The D-pad must map to existing navigation actions.")
	_expect(Bindings.direction_for(_motion(JOY_AXIS_LEFT_Y, 1.0)) == Vector2i.DOWN, "The left-stick axis must map to its existing direction action.")
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	_expect(Bindings.pressed(escape, "lumen_back"), "Escape and B must share the Back action.")


## Checks D-pad navigation and active-device handling.
func _test_dpad_and_devices() -> void:
	var pad := Pad.new()
	_expect(pad.direction() == Vector2i.ZERO, "No controller input must produce no movement.")
	pad.handle_direction_event(_button(JOY_BUTTON_DPAD_RIGHT))
	_expect(pad.direction() == Vector2i.RIGHT, "A D-pad press must remain held until release.")
	pad.handle_direction_event(_button(JOY_BUTTON_DPAD_RIGHT, false))
	_expect(pad.direction() == Vector2i.ZERO, "D-pad release must stop movement.")
	_expect(not pad.handle_direction_event(_button(JOY_BUTTON_A)), "Face buttons must not alter directional state.")
	pad.handle_direction_event(_button(JOY_BUTTON_DPAD_LEFT, true, 1))
	pad.handle_direction_event(_motion(JOY_AXIS_LEFT_X, 0.05, 2))
	_expect(pad.direction() == Vector2i.LEFT, "Neutral drift from another device must not steal control.")
	pad.handle_direction_event(_button(JOY_BUTTON_DPAD_UP, true, 2))
	_expect(pad.direction() == Vector2i.UP, "A deliberate input from another device may take control.")
	pad.remove_device(2)
	_expect(pad.direction() == Vector2i.ZERO, "Disconnecting the active device must clear held movement.")
	pad.handle_direction_event(_motion(JOY_AXIS_LEFT_Y, 0.0, 2))
	_expect(pad.direction() == Vector2i.ZERO, "A reconnected neutral device must not restore stale state.")
	pad.handle_direction_event(_button(JOY_BUTTON_DPAD_DOWN, true, 2))
	pad.reset()
	_expect(pad.direction() == Vector2i.ZERO, "Resetting for focus loss or a screen change must stop movement.")


## Checks stick deadzone and cardinal direction resolution.
func _test_stick() -> void:
	_expect(Pad.stick_direction(Vector2(0.29, 0.0)) == Vector2i.ZERO, "Small horizontal drift must fall inside the deadzone.")
	_expect(Pad.stick_direction(Vector2(0.21, 0.21)) == Vector2i.ZERO, "The deadzone must be circular.")
	_expect(Pad.stick_direction(Vector2(0.8, 0.2)) == Vector2i.RIGHT, "A stronger X axis must move horizontally.")
	_expect(Pad.stick_direction(Vector2(-0.8, 0.2)) == Vector2i.LEFT, "Negative X must move left.")
	_expect(Pad.stick_direction(Vector2(0.2, -0.9)) == Vector2i.UP, "Negative Y must move up.")
	_expect(Pad.stick_direction(Vector2(0.7, 0.72), Vector2i.RIGHT) == Vector2i.RIGHT, "Small diagonal jitter must not rapidly switch axes.")
	_expect(Pad.stick_direction(Vector2(0.6, 0.9), Vector2i.RIGHT) == Vector2i.DOWN, "A clearly stronger other axis must change direction.")
	var pad := Pad.new()
	_expect(not pad.handle_direction_event(_motion(JOY_AXIS_RIGHT_X, 1.0)), "The right stick must not navigate.")
	pad.handle_direction_event(_motion(JOY_AXIS_LEFT_X, 0.8))
	pad.handle_direction_event(_motion(JOY_AXIS_LEFT_Y, 1.0))
	_expect(pad.direction() == Vector2i.DOWN, "Both axis updates must resolve to one cardinal direction.")
	pad.handle_direction_event(_button(JOY_BUTTON_DPAD_LEFT))
	_expect(pad.direction() == Vector2i.LEFT, "The D-pad must take priority over stick tilt on the same device.")
	pad.handle_direction_event(_button(JOY_BUTTON_DPAD_LEFT, false))
	pad.handle_direction_event(_motion(JOY_AXIS_LEFT_X, 0.0))
	pad.handle_direction_event(_motion(JOY_AXIS_LEFT_Y, 0.0))
	_expect(pad.direction() == Vector2i.ZERO, "Returning the stick to neutral must stop movement.")


## Checks initial movement and timed repeat behavior.
func _test_repeat() -> void:
	var repeat := Repeat.new()
	_expect(repeat.advance(Vector2i.RIGHT, 0.0) == Vector2i.RIGHT, "A new direction must move once immediately.")
	_expect(repeat.advance(Vector2i.RIGHT, 0.29) == Vector2i.ZERO, "Holding must wait for the initial delay.")
	_expect(repeat.advance(Vector2i.RIGHT, 0.011) == Vector2i.RIGHT, "Holding must repeat after 0.30 seconds.")
	_expect(repeat.advance(Vector2i.RIGHT, 0.11) == Vector2i.ZERO, "Further steps must wait for the repeat interval.")
	_expect(repeat.advance(Vector2i.RIGHT, 0.011) == Vector2i.RIGHT, "Further movement must repeat after 0.12 seconds.")
	_expect(repeat.advance(Vector2i.ZERO, 0.0) == Vector2i.ZERO, "Neutral must stop repeating.")
	_expect(repeat.advance(Vector2i.LEFT, 0.0) == Vector2i.LEFT, "A fresh press after neutral must act immediately.")
	_expect(repeat.advance(Vector2i.LEFT, 2.0) == Vector2i.LEFT, "A long frame may emit only one movement step.")
	_expect(repeat.advance(Vector2i.LEFT, 0.01) == Vector2i.ZERO, "A long frame must not leave a burst of pending repeats.")
	repeat.reset()
	_expect(repeat.advance(Vector2i.DOWN, 0.0) == Vector2i.DOWN, "Resetting must allow the next new direction immediately.")
