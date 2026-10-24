extends RefCounted
## Applies consistent, frame-bounded repeat timing to held navigation directions.

## Wait time before a held direction begins repeating.
const INITIAL_DELAY := 0.30
## Time between subsequent repeated navigation steps.
const REPEAT_INTERVAL := 0.12

## Direction currently held for repeat timing.
var _direction := Vector2i.ZERO
## Time remaining before the next repeated step.
var _remaining := 0.0


## Clears the held direction and its repeat timer.
func reset() -> void:
	_direction = Vector2i.ZERO
	_remaining = 0.0


## Returns a direction when the initial move or a timed repeat is due.
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
