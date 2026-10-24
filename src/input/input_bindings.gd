extends RefCounted
## Defines and installs the keyboard and standardized gamepad actions used by the game.

## Physical keyboard keys assigned to each named game action.
const BINDINGS := {
	"lumen_left": [KEY_LEFT, KEY_A],
	"lumen_right": [KEY_RIGHT, KEY_D],
	"lumen_up": [KEY_UP, KEY_W],
	"lumen_down": [KEY_DOWN, KEY_S],
	"lumen_bulb": [KEY_SPACE],
	"lumen_annotation": [KEY_X],
	"lumen_activate": [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE],
	"lumen_back": [KEY_ESCAPE],
}

## Standard gamepad buttons assigned to each named action.
const GAMEPAD_BUTTONS := {
	"lumen_left": JOY_BUTTON_DPAD_LEFT,
	"lumen_right": JOY_BUTTON_DPAD_RIGHT,
	"lumen_up": JOY_BUTTON_DPAD_UP,
	"lumen_down": JOY_BUTTON_DPAD_DOWN,
	"lumen_bulb": JOY_BUTTON_A,
	"lumen_annotation": JOY_BUTTON_X,
	"lumen_activate": JOY_BUTTON_A,
	"lumen_back": JOY_BUTTON_B,
}

## Left-stick axis directions assigned to navigation actions.
const GAMEPAD_AXES := {
	"lumen_left": [JOY_AXIS_LEFT_X, -1.0],
	"lumen_right": [JOY_AXIS_LEFT_X, 1.0],
	"lumen_up": [JOY_AXIS_LEFT_Y, -1.0],
	"lumen_down": [JOY_AXIS_LEFT_Y, 1.0],
}

## Minimum left-stick magnitude treated as intentional input.
const STICK_DEADZONE := 0.30


## Installs missing keyboard and gamepad events into Godot InputMap actions.
static func install() -> void:
	for action in BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)
	for action in GAMEPAD_BUTTONS:
		var event := InputEventJoypadButton.new()
		event.device = -1
		event.button_index = GAMEPAD_BUTTONS[action]
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)
	for action in GAMEPAD_AXES:
		InputMap.action_set_deadzone(action, STICK_DEADZONE)
		var event := InputEventJoypadMotion.new()
		event.device = -1
		event.axis = GAMEPAD_AXES[action][0]
		event.axis_value = GAMEPAD_AXES[action][1]
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)


## Returns the cardinal direction represented by a pressed navigation event.
static func direction_for(event: InputEvent) -> Vector2i:
	if pressed(event, "lumen_left", true):
		return Vector2i.LEFT
	if pressed(event, "lumen_right", true):
		return Vector2i.RIGHT
	if pressed(event, "lumen_up", true):
		return Vector2i.UP
	if pressed(event, "lumen_down", true):
		return Vector2i.DOWN
	return Vector2i.ZERO


## Returns whether an input event activates the named action.
static func pressed(event: InputEvent, action: StringName, allow_repeat: bool = false) -> bool:
	return event.is_action_pressed(action, allow_repeat, true)
