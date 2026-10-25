extends SceneTree
## Captures the real UI in an isolated process for README updates and visual review.

const MainScene = preload("res://src/presentation/main.tscn")
const Preferences = preload("res://src/presentation/player_preferences.gd")
const Generator = preload("res://src/generation/board_generator.gd")
const Levels = preload("res://src/levels/prototype_levels.gd")
const State = preload("res://src/core/game_state.gd")
const Configuration = preload("res://src/generation/level_configuration.gd")
var _output := ""
var _records: Array[Dictionary] = []
var _game: Control


## Starts after the root viewport becomes available.
func _init() -> void:
	call_deferred("_run")


## Renders every normal route and representative layout/state variations.
func _run() -> void:
	_output = OS.get_environment("LUMEN_CAPTURE_OUTPUT")
	var data_root := OS.get_environment("XDG_DATA_HOME")
	if _output.is_empty() or data_root.is_empty() or not OS.get_user_data_dir().begins_with(data_root):
		push_error("UI capture requires explicit output and isolated user data.")
		quit(1)
		return
	root.size = Vector2i(1152, 800)
	root.set_flag(Window.FLAG_NO_FOCUS, true)
	root.position = Vector2i(-10000, -10000)
	var preferences := Preferences.new()
	preferences.tutorial_seen = true
	preferences.is_muted = true
	preferences.music_volume = 0.35
	preferences.save_preferences()
	_game = MainScene.instantiate()
	root.add_child(_game)
	_game.set_process_input(false)
	await create_timer(2.0).timeout
	# Freeze the approved ambient pose so all pages can be compared consistently.
	_game.get_node("Backdrop").set_process(false)
	await _capture("main-menu", "Main menu")
	_game.call("_show_difficulty")
	await _capture("difficulty-selection", "Difficulty and random selection")
	for difficulty in ["easy", "medium", "hard"]:
		_game.call("_show_level_select", difficulty)
		await _capture("levels-" + difficulty, difficulty.capitalize() + " level selection")
	_game.call("_show_settings")
	await _capture("settings-audio", "Settings: Audio & Display")
	_game.call("_show_controls")
	await _capture("settings-controls", "Settings: Controls, top")
	var scroll := _game.get("_screen").find_child("SettingsContentScroll", true, false) as ScrollContainer
	scroll.scroll_vertical = 100000
	await _capture("settings-controls-bottom", "Settings: Controls, bottom")
	_game.call("_start_tutorial", false)
	for step in range(5):
		_game.set("_tutorial_page", step)
		_game.call("_show_tutorial_page")
		await _capture("tutorial-%d" % (step + 1), "Tutorial step %d" % (step + 1))
	for difficulty in ["easy", "medium", "hard"]:
		_game.call("_open_numbered_level", difficulty, 1)
		await _capture("gameplay-" + difficulty, difficulty.capitalize() + " gameplay")
	_game.call("_open_numbered_level", "medium", 1)
	_add_progress_fixture()
	await _capture("gameplay-progress", "Gameplay: valid partial illumination")
	_game.call("_open_numbered_level", "easy", 1)
	_add_feedback_fixture()
	await _capture("gameplay-feedback", "Gameplay: light, X, and conflicts")
	_game.call("_open_numbered_level", "easy", 1)
	_add_clue_warning_fixture()
	await _capture("gameplay-clue-warning", "Gameplay: exceeded numbered clue")
	_game.call("_open_numbered_level", "easy", 1)
	await process_frame
	_solve_current()
	await _capture("victory-numbered", "Numbered victory with Next Level")
	_game.call("_open_numbered_level", "hard", 10)
	await process_frame
	_solve_current()
	await _capture("victory-final", "Final registered level victory")
	_game.get("_session_random").seed = 20261025
	_game.call("_start_random_level")
	await _capture("gameplay-random", "Random gameplay")
	await process_frame
	_solve_current()
	await _capture("victory-random", "Random victory")
	# The fallback is a genuine UI route; this deliberately invalid fixture logs one expected error.
	var invalid = Levels.get_configuration("easy", 1)
	invalid.target_wall_count = invalid.width * invalid.height
	_game.call("_open_configuration", invalid, false)
	await _capture("load-error", "Load-error fallback (invalid fixture)")
	for resolution in [Vector2i(1920, 1080), Vector2i(1152, 640)]:
		root.size = resolution
		await process_frame
		_game.call("_show_menu")
		await _capture("main-menu", "Main menu")
		_game.call("_show_difficulty")
		await _capture("difficulty-selection", "Difficulty selection")
		_game.call("_show_level_select", "hard")
		await _capture("levels-hard", "Hard level selection")
		_game.call("_show_settings")
		await _capture("settings-audio", "Settings: Audio & Display")
		_game.call("_show_controls")
		await _capture("settings-controls", "Settings: Controls")
		_game.call("_start_tutorial", false)
		_game.set("_tutorial_page", 3)
		_game.call("_show_tutorial_page")
		await _capture("tutorial-4", "Tutorial: longest text")
		_game.call("_open_numbered_level", "hard", 1)
		await _capture("gameplay-hard", "Hard gameplay")
		await process_frame
		_solve_current()
		await _capture("victory-numbered", "Numbered victory")
	var manifest := FileAccess.open(_output.path_join("index.json"), FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"captures": _records, "notes": "Isolated real Godot renders; ambient pose frozen; gamepad hints follow connected hardware; fallback logs one expected configuration error."}, "\t"))
	for property in ["_music", "_action_audio", "_feedback_audio"]:
		var player: AudioStreamPlayer = _game.get(property)
		player.stop()
		player.stream = null
	_game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("UI captures completed: ", _records.size())
	quit()


## Shows a valid partial solution and a note without triggering victory.
func _add_progress_fixture() -> void:
	var generated := Generator.generate(Levels.get_configuration("medium", 1))
	for index in generated.solution.slice(0, 2):
		_game.call("_on_primary_click", index)
	var state = _game.get("_state")
	var lit: PackedByteArray = state.evaluate().illuminated
	for index in range(state.board.cell_count() - 1, -1, -1):
		if state.board.is_playable(index) and not lit[index]:
			_game.call("_on_secondary_click", index)
			break


## Intentionally exceeds one numbered wall to expose its real warning treatment.
func _add_clue_warning_fixture() -> void:
	var board = _game.get("_state").board
	for index in range(board.cell_count()):
		var clue: int = board.clue_at(index)
		if not board.is_wall(index) or clue < 0:
			continue
		var neighbors: Array[int] = []
		for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var position: Vector2i = board.position_of(index) + direction
			if board.contains(position) and board.is_playable(board.index_of(position)):
				neighbors.append(board.index_of(position))
		if neighbors.size() > clue:
			for neighbor in neighbors.slice(0, clue + 1):
				_game.call("_on_primary_click", neighbor)
			return


## Creates one readable fixture with two bulbs in conflict and an X annotation.
func _add_feedback_fixture() -> void:
	var state = _game.get("_state")
	var selected_pair: Array[int] = []
	for first in range(state.board.cell_count()):
		if not state.board.is_playable(first):
			continue
		for second in range(first + 1, state.board.cell_count()):
			if not state.board.is_playable(second):
				continue
			var candidate = State.new(state.board)
			candidate.toggle_bulb(first)
			candidate.toggle_bulb(second)
			if candidate.evaluate().conflicting_bulbs > 0:
				selected_pair = [first, second]
				break
		if not selected_pair.is_empty():
			break
	for index in selected_pair:
		_game.call("_on_primary_click", index)
	var illumination: PackedByteArray = state.evaluate().illuminated
	for index in range(state.board.cell_count()):
		if state.board.is_playable(index) and illumination[index] and not selected_pair.has(index):
			_game.call("_on_secondary_click", index)
			break
	for index in range(state.board.cell_count() - 1, -1, -1):
		if state.board.is_playable(index) and not selected_pair.has(index):
			_game.call("_on_secondary_click", index)
			break


## Completes a sample through normal action handlers without saving puzzle progress.
func _solve_current() -> void:
	var configuration: Dictionary = _game.get("_current_configuration")
	var resolved := Configuration.new(configuration.level_id, configuration.difficulty, configuration.width, configuration.height, configuration.target_wall_count, configuration.seed, configuration.level_number, configuration.difficulty_id)
	resolved.numbered_wall_ratio = configuration.numbered_wall_ratio
	resolved.generator_version = configuration.generator_version
	var generated := Generator.generate(resolved)
	if not generated.ok:
		push_error("Could not reproduce the capture fixture.")
		return
	for index in generated.solution:
		_game.call("_on_primary_click", index)


## Saves one full viewport and its real page/focus metadata after layout settles.
func _capture(identifier: String, label: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	var resolution := "%dx%d" % [root.size.x, root.size.y]
	var directory := _output.path_join(resolution)
	DirAccess.make_dir_recursive_absolute(directory)
	var image := root.get_texture().get_image()
	var filename := resolution.path_join(identifier + ".png")
	var result := image.save_png(_output.path_join(filename))
	if result != OK:
		push_error("Could not write UI capture: " + filename)
	var focus := root.gui_get_focus_owner()
	_records.append({"id": identifier, "label": label, "file": filename, "width": image.get_width(), "height": image.get_height(), "logical_viewport": {"width": _game.get_viewport_rect().size.x, "height": _game.get_viewport_rect().size.y}, "page": _game.get("_page_name"), "focus": str(focus.name) if focus != null else "none"})
	print("Captured ", filename)
