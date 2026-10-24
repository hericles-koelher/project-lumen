extends RefCounted

const Board = preload("res://src/core/board_definition.gd")
const State = preload("res://src/core/game_state.gd")
const Configuration = preload("res://src/generation/level_configuration.gd")
const VERSION := 1


static func generate(configuration: Configuration) -> Dictionary:
	if configuration == null:
		return _failure("A level configuration is required.")
	var error := configuration.validation_error()
	if not error.is_empty():
		return _failure(error)
	if configuration.generator_version != VERSION:
		return _failure("Unsupported generator version: %d." % configuration.generator_version)

	var random := RandomNumberGenerator.new()
	random.seed = configuration.level_seed
	var indices: Array = range(configuration.width * configuration.height)
	_shuffle(indices, random)
	var symbols := PackedStringArray()
	symbols.resize(indices.size())
	symbols.fill(".")
	var walls: Array = indices.slice(0, configuration.target_wall_count)
	for index in walls:
		symbols[index] = "#"
	var layout := Board.new(_to_rows(symbols, configuration.width, configuration.height))
	var construction := State.new(layout)
	var open_cells: Array = indices.slice(configuration.target_wall_count)
	_shuffle(open_cells, random)
	var illuminated: PackedByteArray = construction.evaluate().illuminated
	var solution: Array[int] = []
	for index in open_cells:
		if not illuminated[index]:
			# An unlit cell cannot see an existing bulb. Adding one preserves independence.
			construction.toggle_bulb(index)
			solution.append(index)
			illuminated = construction.evaluate().illuminated

	_shuffle(walls, random)
	for order in range(configuration.numbered_wall_count()):
		var index: int = walls[order]
		symbols[index] = str(construction.adjacent_bulb_count(index))
	var board := Board.new(_to_rows(symbols, configuration.width, configuration.height))
	var verification := State.new(board)
	for index in solution:
		verification.toggle_bulb(index)
	if not verification.evaluate().solved:
		return _failure("The constructed solution failed rule validation.")
	return {
		"ok": true,
		"board": board,
		"configuration": configuration.to_dictionary(),
		# Construction witness for validation; presentation discards it and offers no hints.
		"solution": solution,
	}


static func _shuffle(values: Array, random: RandomNumberGenerator) -> void:
	for index in range(values.size() - 1, 0, -1):
		var other := random.randi_range(0, index)
		var temporary = values[index]
		values[index] = values[other]
		values[other] = temporary


static func _to_rows(symbols: PackedStringArray, width: int, height: int) -> PackedStringArray:
	var rows := PackedStringArray()
	for y in range(height):
		var row := ""
		for x in range(width):
			row += symbols[y * width + x]
		rows.append(row)
	return rows


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "error": message}
