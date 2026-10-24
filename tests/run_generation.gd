extends SceneTree

const Generator = preload("res://src/generation/board_generator.gd")
const Configuration = preload("res://src/generation/level_configuration.gd")
const Levels = preload("res://src/levels/prototype_levels.gd")
const State = preload("res://src/core/game_state.gd")

var _checks := 0
var _failures := 0


func _init() -> void:
	_test_presets()
	_test_seed_batch()
	_test_invalid_configuration()
	print("Generation checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


func _test_presets() -> void:
	var expected_counts := {"easy": 3, "medium": 7, "hard": 11}
	for difficulty in expected_counts:
		var configuration = Levels.get_configuration(difficulty)
		var before: Dictionary = configuration.to_dictionary()
		var first := Generator.generate(configuration)
		_expect(first.ok, "The catalog level must generate: %s" % difficulty)
		if not first.ok:
			continue
		seed(999) # Unrelated global randomness must not affect the generator.
		var repeated := Generator.generate(configuration)
		_expect(first.board.to_rows() == repeated.board.to_rows(), "Identical configuration must reproduce the board.")
		_expect(first.solution == repeated.solution, "The construction witness must be reproducible too.")
		_expect(configuration.to_dictionary() == before, "Generation must not mutate configuration.")
		_expect(first.configuration == before, "Reproduction metadata must contain the resolved parameters.")
		_expect(first.board.width == configuration.width and first.board.height == configuration.height, "Generated dimensions must match configuration.")
		_expect(first.board.wall_indices().size() == configuration.target_wall_count, "Wall count must match the target exactly.")
		var numbered := 0
		for index in first.board.wall_indices():
			if first.board.clue_at(index) >= 0:
				numbered += 1
		_expect(numbered == expected_counts[difficulty], "Numbered-wall count must be floored from seventy percent.")
		_expect(_witness_solves(first), "The constructed solution must satisfy the actual game rules.")
		var rows: PackedStringArray = first.board.to_rows()
		rows[0] = "changed"
		_expect(first.board.to_rows()[0] != "changed", "Exported rows must not mutate the board definition.")


func _test_seed_batch() -> void:
	for difficulty in ["easy", "medium", "hard"]:
		var fingerprints: Dictionary = {}
		for value in range(40):
			var configuration = Levels.get_configuration(difficulty)
			configuration.level_seed = value
			var generated := Generator.generate(configuration)
			_expect(generated.ok, "Every valid batch configuration must generate successfully.")
			if generated.ok:
				_expect(_witness_solves(generated), "Every accepted board in the batch needs a valid solution.")
				fingerprints["/".join(generated.board.to_rows())] = true
		_expect(fingerprints.size() > 1, "Changing seeds should produce board variety within a preset.")


func _witness_solves(generated: Dictionary) -> bool:
	var state := State.new(generated.board)
	for index in generated.solution:
		if not state.toggle_bulb(index):
			return false
	var rows_before: PackedStringArray = generated.board.to_rows()
	var solved: bool = state.evaluate().solved
	state.reset()
	return solved and state.board.to_rows() == rows_before


func _test_invalid_configuration() -> void:
	_expect(not Generator.generate(null).ok, "A missing configuration must fail explicitly.")
	var cases := ["dimensions", "wall_count", "wall_mix", "ratio", "nan_ratio", "too_few_clues", "version"]
	for invalid_case in cases:
		var configuration = Levels.get_configuration("easy")
		match invalid_case:
			"dimensions": configuration.width = 0
			"wall_count": configuration.target_wall_count = 25
			"wall_mix": configuration.target_wall_count = 1
			"ratio": configuration.numbered_wall_ratio = 1.0
			"nan_ratio": configuration.numbered_wall_ratio = NAN
			"too_few_clues": configuration.numbered_wall_ratio = 0.01
			"version": configuration.generator_version = 999
		var result := Generator.generate(configuration)
		_expect(not result.ok and not result.get("error", "").is_empty(), "Invalid input needs an explicit error: %s" % invalid_case)
