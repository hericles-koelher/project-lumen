extends RefCounted
## Prevents a repeated action on the same cell for a short time interval.

## Default time during which the same action and cell pair is suppressed.
const DEFAULT_INTERVAL_MS := 150

## Non-negative interval used to suppress repeated actions.
var _interval_ms: int
## Last accepted monotonic timestamp, grouped by action and cell index.
var _accepted_at: Dictionary = {}


## Creates a guard with the requested suppression interval in milliseconds.
func _init(interval_ms: int = DEFAULT_INTERVAL_MS) -> void:
	_interval_ms = maxi(interval_ms, 0)


## Clears the timestamps so every action and cell pair can be accepted again.
func reset() -> void:
	_accepted_at.clear()


## Returns whether this action on this cell is allowed at the supplied time.
## Rejected attempts do not change the timestamp of the previous accepted action.
func allow(action: StringName, cell_index: int, now_ms: int) -> bool:
	if not _accepted_at.has(action):
		_accepted_at[action] = {}

	var cell_times: Dictionary = _accepted_at[action]
	if cell_times.has(cell_index):
		var elapsed_ms := now_ms - int(cell_times[cell_index])
		if elapsed_ms < _interval_ms:
			return false

	cell_times[cell_index] = now_ms
	return true
