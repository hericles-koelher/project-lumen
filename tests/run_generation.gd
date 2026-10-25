extends SceneTree
## Checks level configuration, deterministic generation, and solution validity.

## Procedural generator exercised by these checks.
const Generator = preload("res://src/generation/board_generator.gd")
## Level configuration type used to construct test inputs.
const Configuration = preload("res://src/generation/level_configuration.gd")
## Ordered catalog of registered difficulty presets.
const Levels = preload("res://src/levels/prototype_levels.gd")
## Rule evaluator used to verify generated solution witnesses.
const State = preload("res://src/core/game_state.gd")

## Number of assertions evaluated by this standalone check runner.
var _checks := 0
## Number of failed assertions in this standalone check runner.
var _failures := 0


## Runs generation checks and exits with a failure status when needed.
func _init() -> void:
	_test_presets()
	_test_catalog_progression()
	_test_seed_batch()
	_test_invalid_configuration()
	print("Generation checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


## Records a failed check when the supplied condition is false.
func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


## Checks the supported level presets and their resolved generation parameters.
func _test_presets() -> void:
	var expected_counts := {"easy": 3, "medium": 7, "hard": 11}
	var initial_ids := {"easy": "easy_001", "medium": "medium_001", "hard": "hard_001"}
	var initial_seeds := {"easy": 104729, "medium": 130363, "hard": 155921}
	for difficulty in expected_counts:
		var configuration = Levels.get_configuration(difficulty)
		_expect(configuration.level_id == initial_ids[difficulty], "The original fixed-level identity must remain stable.")
		_expect(configuration.level_seed == initial_seeds[difficulty], "The original fixed-level seed must remain stable.")
		_expect(configuration.difficulty_id == difficulty, "A configuration must carry its stable difficulty ID separately from its display name.")
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


## Checks all fixed level IDs, seeds, and progression boundaries in catalog order.
func _test_catalog_progression() -> void:
	var difficulties := Levels.get_difficulties()
	_expect(difficulties.size() == 3, "The initial catalog must register three difficulties.")
	var seen_level_ids: Dictionary = {}
	for difficulty_index in range(difficulties.size()):
		var difficulty: String = difficulties[difficulty_index].id
		_expect(Levels.get_level_count(difficulty) == 10, "Each registered difficulty must contain ten numbered levels.")
		for level_number in range(1, 11):
			var configuration = Levels.get_configuration(difficulty, level_number)
			_expect(configuration != null and configuration.level_number == level_number, "Every numbered level must resolve its catalog position.")
			_expect(configuration.difficulty_id == difficulty, "Each level must retain its stable difficulty ID.")
			_expect(not seen_level_ids.has(configuration.level_id), "Every numbered level must have a unique stable ID.")
			seen_level_ids[configuration.level_id] = true
			var generated := Generator.generate(configuration)
			_expect(generated.ok, "Every numbered level must generate successfully.")
			if generated.ok:
				_expect(_witness_solves(generated), "Every numbered level must have a valid solution.")
				_expect(generated.configuration.seed == configuration.level_seed, "Each numbered level must retain its explicit seed.")
		var next_configuration = Levels.get_next_configuration(difficulty, 10)
		if difficulty_index < difficulties.size() - 1:
			_expect(next_configuration != null and next_configuration.difficulty == difficulties[difficulty_index + 1].name and next_configuration.level_number == 1, "The final level must progress to the next difficulty.")
		else:
			_expect(next_configuration == null, "Only the final level of the final difficulty has no next level.")
	_expect(Levels.get_next_configuration("easy", 9).level_number == 10, "Progression must continue within a difficulty.")
	var random := RandomNumberGenerator.new()
	random.seed = 42
	var seen: Dictionary = {}
	for _draw in range(300):
		seen[Levels.get_random_difficulty(random)] = true
	_expect(seen.size() == difficulties.size(), "Random selection must include every registered difficulty.")


## Checks deterministic generation and valid solutions across multiple seeds.
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


## Returns whether the generator witness solves the generated board.
func _witness_solves(generated: Dictionary) -> bool:
	var state := State.new(generated.board)
	for index in generated.solution:
		if not state.toggle_bulb(index):
			return false
	var rows_before: PackedStringArray = generated.board.to_rows()
	var solved: bool = state.evaluate().solved
	state.reset()
	return solved and state.board.to_rows() == rows_before


## Checks that invalid level configurations are rejected.
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
