extends RefCounted
## Provides the ordered difficulty catalog and fixed reproducible level configurations.

## Level-configuration type returned by the catalog.
const Configuration = preload("res://src/generation/level_configuration.gd")
## Ordered difficulty presets; appending an entry registers it for menus, random draws, and progression.
const PRESETS := [
	{"id": "easy", "name": "Easy", "width": 5, "height": 5, "walls": 5, "seeds": [104729, 32452843, 49979687, 67867967, 86028121, 104395301, 122949829, 141650939, 160481219, 179424673]},
	{"id": "medium", "name": "Medium", "width": 7, "height": 7, "walls": 10, "seeds": [130363, 200000033, 200000039, 200000051, 200000063, 200000077, 200000081, 200000093, 200000101, 200000107]},
	{"id": "hard", "name": "Hard", "width": 9, "height": 9, "walls": 16, "seeds": [155921, 300000001, 300000007, 300000017, 300000023, 300000043, 300000047, 300000071, 300000083, 300000089]},
]


## Returns a copy of the registered difficulty descriptors in progression order.
static func get_difficulties() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for preset in PRESETS:
		result.append(preset.duplicate())
	return result


## Returns the stable difficulty IDs in menu and progression order.
static func get_difficulty_ids() -> Array[String]:
	var result: Array[String] = []
	for preset in PRESETS:
		result.append(preset.id)
	return result


## Returns the number of fixed numbered levels registered for a difficulty.
static func get_level_count(difficulty: String) -> int:
	var preset := _find_preset(difficulty)
	return preset.seeds.size() if not preset.is_empty() else 0


## Returns a fixed level configuration, defaulting to the first level for compatibility.
static func get_configuration(difficulty: String, level_number: int = 1) -> Configuration:
	var preset := _find_preset(difficulty)
	if preset.is_empty() or level_number < 1 or level_number > preset.seeds.size():
		return null
	var identifier := "%s_%03d" % [preset.id, level_number]
	var seed_value: int = preset.seeds[level_number - 1]
	return Configuration.new(identifier, preset.name, preset.width, preset.height, preset.walls, seed_value, level_number, preset.id)


## Returns the next numbered level, crossing to the next difficulty when needed.
static func get_next_configuration(difficulty: String, level_number: int) -> Configuration:
	var current_index := -1
	for index in range(PRESETS.size()):
		if PRESETS[index].id == difficulty:
			current_index = index
			break
	if current_index < 0 or level_number < 1 or level_number > PRESETS[current_index].seeds.size():
		return null
	if level_number < PRESETS[current_index].seeds.size():
		return get_configuration(difficulty, level_number + 1)
	if current_index + 1 >= PRESETS.size():
		return null
	return get_configuration(PRESETS[current_index + 1].id, 1)


## Returns a random registered difficulty using equal probability for each preset.
static func get_random_difficulty(random: RandomNumberGenerator) -> String:
	if PRESETS.is_empty():
		return ""
	return PRESETS[random.randi_range(0, PRESETS.size() - 1)].id


## Finds one preset by ID, returning an empty dictionary for unknown IDs.
static func _find_preset(difficulty: String) -> Dictionary:
	for preset in PRESETS:
		if preset.id == difficulty:
			return preset
	return {}
