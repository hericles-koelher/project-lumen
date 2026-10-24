extends Control
## Builds the prototype interface and coordinates input, game state, feedback, and audio.

## Game-state type used for the active puzzle.
const State = preload("res://src/core/game_state.gd")
## Catalog of fixed difficulty configurations.
const Levels = preload("res://src/levels/prototype_levels.gd")
## Procedural board generator used to open a level.
const Generator = preload("res://src/generation/board_generator.gd")
## Shared keyboard and gamepad action mappings.
const Bindings = preload("res://src/input/input_bindings.gd")
## Input-independent model for board and button focus.
const Navigation = preload("res://src/input/board_navigation.gd")
## Per-device gamepad direction tracker.
const GamepadState = preload("res://src/input/gamepad_state.gd")
## Timer model for held gamepad navigation.
const DirectionRepeat = preload("res://src/input/direction_repeat.gd")
## Control used to draw and interact with one board cell.
const CellView = preload("res://src/presentation/board_cell.gd")
## Palette and theme factory shared by the interface.
const Visuals = preload("res://src/presentation/lumen_theme.gd")
## Background illustration displayed behind each screen.
const BACKGROUND = preload("res://assets/backgrounds/menu_concept.png")
## Project logo displayed on the main menu.
const LOGO = preload("res://assets/branding/project_lumen_icon_concept.png")
## Custom cursor image for ordinary pointer areas.
const ARROW_TEXTURE = preload("res://assets/icons/cursor_arrow.svg")
## Custom cursor image for clickable cells and buttons.
const HAND_TEXTURE = preload("res://assets/icons/cursor_clickable.svg")
## Background music stream played while the game is open.
const MUSIC = preload("res://assets/audio/music/our_morning_coffee.mp3")
## Sound played when a bulb is placed.
const PLACE_SOUND = preload("res://assets/audio/sfx/bulb_place.wav")
## Sound played when a bulb is removed.
const REMOVE_SOUND = preload("res://assets/audio/sfx/bulb_remove.wav")
## Sound played when an X annotation is toggled.
const MARK_SOUND = preload("res://assets/audio/sfx/annotation_toggle.wav")
## Sound played when an interface button is activated.
const CLICK_SOUND = preload("res://assets/audio/sfx/button_click.wav")
## Sound played when an action increases rule violations.
const WARNING_SOUND = preload("res://assets/audio/sfx/rule_warning.wav")
## Sound played when the puzzle is solved.
const VICTORY_SOUND = preload("res://assets/audio/sfx/puzzle_solved.wav")

## Mutable puzzle state, or null while no level is open.
var _state: State
## Most recent derived lighting, clue, conflict, and victory data.
var _evaluation: Dictionary = {}
## Reproduction metadata for the currently open puzzle.
var _current_configuration: Dictionary = {}
## Cell controls in row-major board order.
var _cells: Array[Control] = []
## Centered container whose child is the active menu or game page.
var _screen: CenterContainer
## Label displaying the current lit-cell count.
var _status: Label
## Label displaying rule guidance or current violations.
var _warning: Label
## Label shown after all Akari rules are satisfied.
var _victory: Label
## Audio player for the looping background track.
var _music: AudioStreamPlayer
## Audio player for button and board-action sounds.
var _action_audio: AudioStreamPlayer
## Audio player for warning and victory sounds.
var _feedback_audio: AudioStreamPlayer
## Current board and action-button selection model.
var _navigation: Navigation
## Focusable container representing board navigation focus.
var _board_focus: PanelContainer
## Action buttons shown below the active board.
var _game_buttons: Array[Button] = []
## Buttons currently shown on the menu or error page.
var _menu_buttons: Array[Button] = []
## Name of the active page, used by Back navigation.
var _page_name := ""
## Tracked directional state from connected controllers.
var _gamepad := GamepadState.new()
## Held-direction repeat timer for gamepad navigation.
var _direction_repeat := DirectionRepeat.new()


## Initializes this node after it enters the scene tree.
func _ready() -> void:
	Bindings.install()
	Input.ignore_joypad_on_unfocused_application = true
	Input.joy_connection_changed.connect(_on_gamepad_connection_changed)
	for device in Input.get_connected_joypads():
		_on_gamepad_connection_changed(device, true)
	theme = Visuals.create_theme()
	Input.set_custom_mouse_cursor(ARROW_TEXTURE, Input.CURSOR_ARROW, Vector2(8, 5))
	Input.set_custom_mouse_cursor(HAND_TEXTURE, Input.CURSOR_POINTING_HAND, Vector2(16, 5))
	_create_audio()
	_create_backdrop()
	_screen = CenterContainer.new()
	_screen.name = "Screen"
	add_child(_screen)
	_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_show_menu()


## Creates and configures the background music and feedback audio players.
func _create_audio() -> void:
	_music = AudioStreamPlayer.new()
	_music.name = "Music"
	var stream := MUSIC.duplicate() as AudioStreamMP3
	stream.loop = true
	_music.stream = stream
	_music.volume_db = -21.0
	add_child(_music)
	_music.play()
	_action_audio = AudioStreamPlayer.new()
	_action_audio.name = "ActionAudio"
	add_child(_action_audio)
	_feedback_audio = AudioStreamPlayer.new()
	_feedback_audio.name = "FeedbackAudio"
	add_child(_feedback_audio)


## Adds a full-rect background image behind the current screen.
func _create_backdrop() -> void:
	var backdrop := TextureRect.new()
	backdrop.name = "Backdrop"
	backdrop.texture = BACKGROUND
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Replaces the current screen content and creates a centered page container.
func _new_page(page_name: String, min_width: float) -> VBoxContainer:
	_page_name = page_name
	_gamepad.reset()
	_direction_repeat.reset()
	for child in _screen.get_children():
		_screen.remove_child(child)
		child.queue_free()
	_cells.clear()
	_game_buttons.clear()
	_menu_buttons.clear()
	_board_focus = null
	_navigation = null
	var panel := PanelContainer.new()
	panel.name = page_name
	panel.custom_minimum_size.x = min_width
	panel.add_theme_stylebox_override("panel", Visuals.box(Color(0.965, 0.937, 0.875, 0.96), 24, Visuals.INK, 2))
	_screen.add_child(panel)
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	return content


## Creates a centered label with the requested text size.
func _label(parent: Node, text: String, font_size: int = 20) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


## Creates a styled button that plays its click sound before invoking its action.
func _button(parent: Node, node_name: String, text: String, action: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.disabled = disabled
	button.custom_minimum_size.y = 48
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
	button.pressed.connect(func() -> void:
		_play(_action_audio, CLICK_SOUND)
		action.call()
	)
	parent.add_child(button)
	button.focus_entered.connect(_on_focus_changed)
	button.focus_exited.connect(_refresh_selection)
	return button


## Creates the difficulty menu and clears the active puzzle session.
func _show_menu() -> void:
	_state = null
	_evaluation.clear()
	_current_configuration.clear()
	var content := _new_page("Menu", 350)
	var logo := TextureRect.new()
	logo.texture = LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(110, 100)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(logo)
	_label(content, "Project Lumen", 38)
	_label(content, "A little light, a little logic.", 18)
	_menu_buttons.append(_button(content, "Easy", "Easy", _open_level.bind("easy")))
	_menu_buttons.append(_button(content, "Medium", "Medium", _open_level.bind("medium")))
	_menu_buttons.append(_button(content, "Hard", "Hard", _open_level.bind("hard")))
	_menu_buttons.append(_button(content, "Quit", "Quit", _quit))
	_menu_buttons[0].call_deferred("grab_focus")


## Generates the selected difficulty level and creates its board interface.
func _open_level(difficulty: String) -> void:
	var configuration = Levels.get_configuration(difficulty)
	var generated := Generator.generate(configuration)
	if not generated.ok:
		push_error("Level generation failed for %s: %s" % [difficulty, generated.error])
		var error_content := _new_page("LoadError", 540)
		_label(error_content, "This puzzle could not be loaded.", 26)
		_label(error_content, "Please return to the menu.", 20)
		_menu_buttons.append(_button(error_content, "BackToMenu", "Back to Menu", _show_menu))
		_menu_buttons[0].call_deferred("grab_focus")
		return
	_state = State.new(generated.board)
	_current_configuration = generated.configuration
	var content := _new_page("Game", 540)
	_navigation = Navigation.new(_state.board.width, _state.board.height, 3)
	_label(content, "%s  ·  %d × %d" % [configuration.difficulty, configuration.width, configuration.height], 30)
	_status = _label(content, "")
	_status.name = "Status"
	var board_center := CenterContainer.new()
	board_center.name = "BoardCenter"
	content.add_child(board_center)
	var board_frame := PanelContainer.new()
	board_frame.name = "BoardFrame"
	_board_focus = board_frame
	board_frame.focus_mode = Control.FOCUS_ALL
	board_frame.focus_entered.connect(_on_focus_changed)
	board_frame.focus_exited.connect(_refresh_selection)
	var frame_style := Visuals.box(Visuals.INK, 18)
	frame_style.content_margin_left = 10
	frame_style.content_margin_right = 10
	frame_style.content_margin_top = 10
	frame_style.content_margin_bottom = 10
	board_frame.add_theme_stylebox_override("panel", frame_style)
	board_center.add_child(board_frame)
	var grid := GridContainer.new()
	grid.name = "Board"
	grid.columns = _state.board.width
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	board_frame.add_child(grid)
	var longest_side: int = maxi(_state.board.width, _state.board.height)
	var cell_extent := floorf((400.0 - 5.0 * (longest_side - 1)) / longest_side)
	for index in range(_state.board.cell_count()):
		var cell := CellView.new()
		cell.cell_extent = cell_extent
		cell.name = "Cell%d" % index
		cell.cell_index = index
		cell.wall = _state.board.is_wall(index)
		cell.clue = _state.board.clue_at(index)
		cell.primary_clicked.connect(_on_mouse_primary)
		cell.secondary_clicked.connect(_on_mouse_secondary)
		grid.add_child(cell)
		_cells.append(cell)
	_warning = _label(content, "", 18)
	_warning.name = "Warning"
	_label(content, "Mouse: left / right click  ·  Keyboard: Space / X\nGamepad: A / X  ·  Back: Esc / B", 17)
	_victory = _label(content, "Puzzle solved!", 30)
	_victory.name = "Victory"
	var actions := HBoxContainer.new()
	actions.name = "Actions"
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)
	_game_buttons.append(_button(actions, "Restart", "Restart", _restart))
	_game_buttons.append(_button(actions, "BackToMenu", "Back to Menu", _show_menu))
	_game_buttons.append(_button(actions, "Quit", "Quit", _quit))
	_refresh_board()
	_board_focus.call_deferred("grab_focus")


## Routes keyboard and gamepad events to the shared navigation and action handlers.
func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Consume controller events before native UI handling to prevent duplicate movement.
		get_viewport().set_input_as_handled()
		if not get_window().has_focus():
			return
		if _gamepad.handle_direction_event(event):
			return
		if event is InputEventJoypadButton and event.pressed:
			_dispatch_action(event, false)
		return
	if not event is InputEventKey or not event.pressed:
		return
	var direction := Bindings.direction_for(event)
	if direction != Vector2i.ZERO:
		if _navigate(direction):
			get_viewport().set_input_as_handled()
	else:
		_dispatch_action(event, event.echo)


## Updates frame-based input behavior while the game window is focused.
func _process(delta: float) -> void:
	if not get_window().has_focus():
		return
	# Sample both analog axes once per frame, avoiding two moves from a diagonal update.
	var direction := _direction_repeat.advance(_gamepad.direction(), delta)
	if direction != Vector2i.ZERO:
		_navigate(direction)


## Clears held gamepad movement when the application loses focus.
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and _gamepad != null:
		_gamepad.reset()
		_direction_repeat.reset()


## Updates directional state when a gamepad connects or disconnects.
func _on_gamepad_connection_changed(device: int, connected: bool) -> void:
	if connected:
		print("Gamepad connected: %s (standard mapping: %s)" % [Input.get_joy_name(device), Input.is_joy_known(device)])
	else:
		_gamepad.remove_device(device)
		_direction_repeat.reset()


## Moves the current board, button, or menu focus in the requested direction.
func _navigate(direction: Vector2i) -> bool:
	var focused := get_viewport().gui_get_focus_owner()
	if _navigation != null and focused == _board_focus:
		_navigation.move(direction, _nearest_button_below())
		_sync_navigation_focus()
	elif focused in _game_buttons:
		if direction != Vector2i.UP or not _evaluation.get("solved", false):
			_navigation.select_button(_game_buttons.find(focused))
			_navigation.move(direction)
			_sync_navigation_focus()
	elif focused in _menu_buttons:
		var index := clampi(_menu_buttons.find(focused) + direction.y, 0, _menu_buttons.size() - 1)
		_menu_buttons[index].grab_focus()
	else:
		return false
	return true


## Routes a pressed action to Back, board interaction, or focused-button activation.
func _dispatch_action(event: InputEvent, repeated: bool) -> void:
	if Bindings.pressed(event, "lumen_back", true):
		get_viewport().set_input_as_handled()
		if not repeated:
			_go_back()
		return
	var focused := get_viewport().gui_get_focus_owner()
	if _navigation != null and focused == _board_focus:
		if Bindings.pressed(event, "lumen_bulb", true):
			if not repeated:
				_on_primary_click(_navigation.selected_cell)
		elif Bindings.pressed(event, "lumen_annotation", true):
			if not repeated:
				_on_secondary_click(_navigation.selected_cell)
		else:
			return
	elif focused in _game_buttons or focused in _menu_buttons:
		if not Bindings.pressed(event, "lumen_activate", true):
			return
		# Consume before changing pages, so this press cannot activate the new screen too.
		get_viewport().set_input_as_handled()
		if not repeated:
			focused.emit_signal("pressed")
		return
	else:
		return
	get_viewport().set_input_as_handled()


## Returns from gameplay or an error screen to the main menu.
func _go_back() -> void:
	if _page_name != "Menu":
		_play(_action_audio, CLICK_SOUND)
		_show_menu()


## Finds the action button horizontally nearest to the selected board cell.
func _nearest_button_below() -> int:
	var selected_x := _cells[_navigation.selected_cell].get_global_rect().get_center().x
	var closest := 0
	var distance := INF
	for index in range(_game_buttons.size()):
		var candidate := absf(_game_buttons[index].get_global_rect().get_center().x - selected_x)
		if candidate < distance:
			distance = candidate
			closest = index
	return closest


## Applies the navigation model selection to Godot GUI focus.
func _sync_navigation_focus() -> void:
	if _navigation.is_on_board():
		_board_focus.grab_focus()
	else:
		_game_buttons[_navigation.selected_button].grab_focus()
	_refresh_selection()


## Synchronizes the navigation model when GUI focus changes.
func _on_focus_changed() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if _navigation != null:
		if focused == _board_focus:
			_navigation.select_cell(_navigation.selected_cell)
		elif focused in _game_buttons:
			_navigation.select_button(_game_buttons.find(focused))
	_refresh_selection()


## Updates the visible board selection outline from current GUI focus.
func _refresh_selection() -> void:
	var show_selection := _navigation != null and get_viewport().gui_get_focus_owner() == _board_focus
	for index in range(_cells.size()):
		var cell = _cells[index]
		cell.keyboard_selected = show_selection and index == _navigation.selected_cell
		cell.queue_redraw()


## Stores a clicked cell as the current selection while the puzzle is active.
func _select_mouse_cell(index: int) -> void:
	if not _evaluation.get("solved", false):
		_navigation.select_cell(index)
		_board_focus.grab_focus()
		_refresh_selection()


## Selects a clicked cell and applies its primary action.
func _on_mouse_primary(index: int) -> void:
	_select_mouse_cell(index)
	_on_primary_click(index)


## Selects a clicked cell and applies its annotation action.
func _on_mouse_secondary(index: int) -> void:
	_select_mouse_cell(index)
	_on_secondary_click(index)


## Toggles a bulb and refreshes state and rule feedback.
func _on_primary_click(index: int) -> void:
	if _evaluation.get("solved", false):
		return
	var removing := bool(_state.bulbs[index])
	var previous_violations := _violation_count()
	if _state.toggle_bulb(index):
		_play(_action_audio, REMOVE_SOUND if removing else PLACE_SOUND)
		_refresh_board()
		_play_rule_feedback(previous_violations)


## Toggles an annotation and refreshes state and rule feedback.
func _on_secondary_click(index: int) -> void:
	if _evaluation.get("solved", false):
		return
	var previous_violations := _violation_count()
	if _state.toggle_annotation(index):
		_play(_action_audio, MARK_SOUND)
		_refresh_board()
		_play_rule_feedback(previous_violations)


## Reevaluates the puzzle and updates all cell visuals and victory controls.
func _refresh_board() -> void:
	var was_solved: bool = _evaluation.get("solved", false)
	_evaluation = _state.evaluate()
	if _evaluation.solved and not was_solved:
		_gamepad.reset()
		_direction_repeat.reset()
	for index in range(_cells.size()):
		var cell = _cells[index]
		cell.bulb = bool(_state.bulbs[index])
		cell.marked = bool(_state.annotations[index])
		cell.illuminated = bool(_evaluation.illuminated[index])
		cell.conflict = bool(_evaluation.conflicts[index])
		cell.exceeded = cell.wall and cell.clue >= 0 and _evaluation.clue_counts.get(index, 0) > cell.clue
		cell.interaction_enabled = not _evaluation.solved
		cell.refresh()
	_status.text = "%d / %d cells lit" % [_evaluation.lit_count, _evaluation.playable_count]
	_victory.visible = _evaluation.solved
	if _violation_count() > 0:
		_warning.text = "%d bulbs in conflict  ·  %d exceeded clues" % [_evaluation.conflicting_bulbs, _evaluation.exceeded_clues]
		_warning.add_theme_color_override("font_color", Visuals.WARNING)
	else:
		_warning.text = "Light every cell and satisfy the numbered walls."
		_warning.add_theme_color_override("font_color", Visuals.INK)
	var board_had_focus := get_viewport().gui_get_focus_owner() == _board_focus
	_board_focus.focus_mode = Control.FOCUS_NONE if _evaluation.solved else Control.FOCUS_ALL
	if _evaluation.solved and board_had_focus:
		_game_buttons[0].grab_focus()
	_refresh_selection()


## Returns the combined number of bulb conflicts and exceeded clues.
func _violation_count() -> int:
	return int(_evaluation.get("conflicting_bulbs", 0)) + int(_evaluation.get("exceeded_clues", 0))


## Plays victory audio or a warning when the violation count increases.
func _play_rule_feedback(previous_violations: int) -> void:
	if _evaluation.solved:
		_play(_feedback_audio, VICTORY_SOUND)
	elif _violation_count() > previous_violations:
		_play(_feedback_audio, WARNING_SOUND)


## Resets the puzzle while keeping its board and restoring board navigation.
func _restart() -> void:
	_gamepad.reset()
	_direction_repeat.reset()
	_state.reset()
	_feedback_audio.stop()
	_refresh_board()
	_navigation.select_cell(_navigation.selected_cell)
	_sync_navigation_focus()


## Plays the supplied audio stream on the specified audio player.
func _play(player: AudioStreamPlayer, stream: AudioStream) -> void:
	player.stream = stream
	player.play()


## Closes the running game.
func _quit() -> void:
	get_tree().quit()
