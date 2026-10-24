extends RefCounted

const Bindings = preload("res://src/input/input_bindings.gd")
const DPAD := [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN]
const AXIS_SWITCH_MARGIN := 0.10

var _devices: Dictionary = {}
var _active_device := -1
var _last_stick_direction := Vector2i.ZERO


func reset() -> void:
	_devices.clear()
	_active_device = -1
	_last_stick_direction = Vector2i.ZERO


func remove_device(device: int) -> void:
	_devices.erase(device)
	if _active_device == device:
		_active_device = -1
		_last_stick_direction = Vector2i.ZERO


func handle_direction_event(event: InputEvent) -> bool:
	var is_dpad: bool = event is InputEventJoypadButton and event.button_index in DPAD
	var is_stick: bool = event is InputEventJoypadMotion and event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]
	if not is_dpad and not is_stick:
		return false
	if not _devices.has(event.device):
		_devices[event.device] = {"stick": Vector2.ZERO, "buttons": {}}
	var device: Dictionary = _devices[event.device]
	if is_dpad:
		device.buttons[event.button_index] = event.pressed
	else:
		var stick: Vector2 = device.stick
		if event.axis == JOY_AXIS_LEFT_X:
			stick.x = event.axis_value
		else:
			stick.y = event.axis_value
		device.stick = stick
	if event.device == _active_device or _device_has_direction(device):
		if _active_device != event.device:
			_last_stick_direction = Vector2i.ZERO
		_active_device = event.device
	return true


func direction() -> Vector2i:
	if not _devices.has(_active_device):
		return Vector2i.ZERO
	var device: Dictionary = _devices[_active_device]
	var dpad := _dpad_direction(device.buttons)
	if dpad != Vector2i.ZERO:
		return dpad
	_last_stick_direction = stick_direction(device.stick, _last_stick_direction)
	return _last_stick_direction


static func stick_direction(stick: Vector2, previous: Vector2i = Vector2i.ZERO) -> Vector2i:
	if stick.length() <= Bindings.STICK_DEADZONE:
		return Vector2i.ZERO
	# Keep the axis stable near a diagonal so tiny hardware jitter cannot trigger rapid steps.
	if previous.x != 0 and absf(stick.y) <= absf(stick.x) + AXIS_SWITCH_MARGIN:
		return Vector2i(int(signf(stick.x)), 0)
	if previous.y != 0 and absf(stick.x) <= absf(stick.y) + AXIS_SWITCH_MARGIN:
		return Vector2i(0, int(signf(stick.y)))
	if absf(stick.x) > absf(stick.y):
		return Vector2i(int(signf(stick.x)), 0)
	return Vector2i(0, int(signf(stick.y)))


static func _dpad_direction(buttons: Dictionary) -> Vector2i:
	var x := int(buttons.get(JOY_BUTTON_DPAD_RIGHT, false)) - int(buttons.get(JOY_BUTTON_DPAD_LEFT, false))
	var y := int(buttons.get(JOY_BUTTON_DPAD_DOWN, false)) - int(buttons.get(JOY_BUTTON_DPAD_UP, false))
	return Vector2i(0, y) if y != 0 else Vector2i(x, 0)


static func _device_has_direction(device: Dictionary) -> bool:
	return _dpad_direction(device.buttons) != Vector2i.ZERO or device.stick.length() > Bindings.STICK_DEADZONE
