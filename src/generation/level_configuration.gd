class_name LumenLevelConfiguration
extends RefCounted

const MAX_DIMENSION := 64
const MAX_CELL_COUNT := 4096

var level_id: String
var difficulty: String
var width: int
var height: int
var target_wall_count: int
var level_seed: int
var numbered_wall_ratio := 0.7
var generator_version := 1


func _init(identifier: String, difficulty_name: String, board_width: int, board_height: int, walls: int, seed_value: int) -> void:
	level_id = identifier
	difficulty = difficulty_name
	width = board_width
	height = board_height
	target_wall_count = walls
	level_seed = seed_value


func numbered_wall_count() -> int:
	return floori(target_wall_count * numbered_wall_ratio)


func validation_error() -> String:
	if level_id.is_empty() or difficulty.is_empty():
		return "Level identity and difficulty must be provided."
	if width < 1 or height < 1 or width > MAX_DIMENSION or height > MAX_DIMENSION:
		return "Board dimensions must be between 1 and %d." % MAX_DIMENSION
	if width * height > MAX_CELL_COUNT:
		return "Board area exceeds the supported generation limit."
	if target_wall_count < 2 or target_wall_count >= width * height:
		return "At least two walls and one playable cell are required."
	if not is_finite(numbered_wall_ratio) or numbered_wall_ratio <= 0.0 or numbered_wall_ratio >= 1.0:
		return "Numbered-wall ratio must be finite and strictly between zero and one."
	if numbered_wall_count() < 1 or numbered_wall_count() >= target_wall_count:
		return "The resolved wall counts must include numbered and unnumbered walls."
	return ""


func to_dictionary() -> Dictionary:
	return {
		"level_id": level_id,
		"difficulty": difficulty,
		"width": width,
		"height": height,
		"target_wall_count": target_wall_count,
		"seed": level_seed,
		"numbered_wall_ratio": numbered_wall_ratio,
		"numbered_wall_count": numbered_wall_count(),
		"generator_version": generator_version,
	}
