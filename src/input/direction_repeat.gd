extends RefCounted

const INITIAL_DELAY := 0.30
const REPEAT_INTERVAL := 0.12

var _direction := Vector2i.ZERO
var _remaining := 0.0


func reset() -> void:
	_direction = Vector2i.ZERO
	_remaining = 0.0


func advance(direction: Vector2i, delta: float) -> Vector2i:
	if direction == Vector2i.ZERO:
		reset()
		return Vector2i.ZERO
	if direction != _direction:
		_direction = direction
		_remaining = INITIAL_DELAY
		return direction
	_remaining -= maxf(delta, 0.0)
	if _remaining <= 0.0:
		# Emit at most one step per frame, without a catch-up burst after a stall.
		_remaining = REPEAT_INTERVAL
		return direction
	return Vector2i.ZERO
