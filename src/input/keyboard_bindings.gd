extends RefCounted

const BINDINGS := {
	"lumen_left": [KEY_LEFT, KEY_A],
	"lumen_right": [KEY_RIGHT, KEY_D],
	"lumen_up": [KEY_UP, KEY_W],
	"lumen_down": [KEY_DOWN, KEY_S],
	"lumen_bulb": [KEY_SPACE],
	"lumen_annotation": [KEY_X],
	"lumen_activate": [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE],
}


static func install() -> void:
	for action in BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)


static func direction_for(event: InputEventKey) -> Vector2i:
	if pressed(event, "lumen_left", true):
		return Vector2i.LEFT
	if pressed(event, "lumen_right", true):
		return Vector2i.RIGHT
	if pressed(event, "lumen_up", true):
		return Vector2i.UP
	if pressed(event, "lumen_down", true):
		return Vector2i.DOWN
	return Vector2i.ZERO


static func pressed(event: InputEventKey, action: StringName, allow_repeat: bool = false) -> bool:
	return event.is_action_pressed(action, allow_repeat, true)
