extends Control
## Builds the game screens and coordinates level sessions, input, preferences, and feedback.

## Game-state type used for active puzzles and tutorial diagrams.
const State = preload("res://src/core/game_state.gd")
## Board-definition type used to construct tutorial diagrams.
const Board = preload("res://src/core/board_definition.gd")
## Ordered difficulty and fixed-level catalog.
const Levels = preload("res://src/levels/prototype_levels.gd")
## Procedural board generator used to open levels.
const Generator = preload("res://src/generation/board_generator.gd")
## Shared keyboard and gamepad action mappings.
const Bindings = preload("res://src/input/input_bindings.gd")
## Input-independent model for board and action-button focus.
const Navigation = preload("res://src/input/board_navigation.gd")
## Per-device gamepad direction tracker.
const GamepadState = preload("res://src/input/gamepad_state.gd")
## Timer model for held gamepad navigation.
const DirectionRepeat = preload("res://src/input/direction_repeat.gd")
## Short per-cell action filter for accidental repeated controller presses.
const CellActionGuard = preload("res://src/input/cell_action_guard.gd")
## Control that draws one Akari board cell.
const CellView = preload("res://src/presentation/board_cell.gd")
## Persistent local player preferences.
const Preferences = preload("res://src/presentation/player_preferences.gd")
## Shared colors, typography, and style-box factory.
const Visuals = preload("res://src/presentation/lumen_theme.gd")
## Finite light celebration shown behind the victory panel.
const Sparkles = preload("res://src/presentation/victory_sparkles.gd")
## Quiet Ink background derived from the user's selected visual concept.
const BACKGROUND = preload("res://assets/backgrounds/quiet_ink_room_cozy.png")
## Hand-lettered project title and hanging bulb restored from the approved concept.
const WORDMARK = preload("res://assets/branding/project_lumen_wordmark.png")
## Transparent light particle rendered by the image-generation tool.
const SPARKLE_TEXTURE = preload("res://assets/fx/victory_sparkle.png")
## Speaker symbol shown while audio is enabled.
const AUDIO_ON = preload("res://assets/icons/audio_on.svg")
## Crossed speaker symbol shown while all audio is muted.
const AUDIO_MUTED = preload("res://assets/icons/audio_muted.svg")
## Dedicated left arrow for the Settings tab header.
const SETTINGS_ARROW_LEFT = preload("res://assets/icons/settings_tab_arrow_left.svg")
## Dedicated right arrow for the Settings tab header.
const SETTINGS_ARROW_RIGHT = preload("res://assets/icons/settings_tab_arrow_right.svg")
## Neutral directional-pad outline used by the Settings input reference.
const GAMEPAD_DPAD = preload("res://assets/icons/gamepad_dpad.svg")
## Neutral left-stick outline; its editable L label is added by the interface.
const GAMEPAD_LEFT_STICK = preload("res://assets/icons/gamepad_left_stick.svg")
## Custom cursor for ordinary pointer areas.
const ARROW_TEXTURE = preload("res://assets/icons/cursor_arrow.svg")
## Custom cursor for clickable controls and cells.
const HAND_TEXTURE = preload("res://assets/icons/cursor_clickable.svg")
## Background music stream.
const MUSIC = preload("res://assets/audio/music/our_morning_coffee.mp3")
## Sound played when a bulb is placed.
const PLACE_SOUND = preload("res://assets/audio/sfx/bulb_place.wav")
## Sound played when a bulb is removed.
const REMOVE_SOUND = preload("res://assets/audio/sfx/bulb_remove.wav")
## Sound played when an X annotation is toggled.
const MARK_SOUND = preload("res://assets/audio/sfx/annotation_toggle.wav")
## Sound played when an interface control is activated.
const CLICK_SOUND = preload("res://assets/audio/sfx/button_click.wav")
## Sound played when an action increases rule violations.
const WARNING_SOUND = preload("res://assets/audio/sfx/rule_warning.wav")
## Sound played when the puzzle is solved.
const VICTORY_SOUND = preload("res://assets/audio/sfx/puzzle_solved.wav")
## Maximum board rendering extent before accounting for the viewport.
const MAX_BOARD_EXTENT := 420.0
## Distance between board cells in pixels.
const BOARD_GAP := 5
## Shared horizontal breathing room between neighboring action buttons.
const BUTTON_GAP := 14
## Vertical space before a Back button on a selection screen.
const BACK_BUTTON_GAP := 24.0
## Seconds of mouse inactivity before hiding the free pointer.
const POINTER_IDLE_SECONDS := 3.0
## Tutorial pages with rule-accurate miniature board examples.
const TUTORIAL_PAGES := [
	{"title": "Light up the board", "body": "Place bulbs to light every playable cell. Light travels in straight rows and columns until a wall or the board edge.", "rows": ["....", "....", "....", "...."], "bulbs": [5], "marks": []},
	{"title": "Read the numbered walls", "body": "A numbered wall needs exactly that many bulbs in its four neighboring cells. A 0 needs none. Walls also stop light.", "rows": [".1..", "....", "0..#", "...."], "bulbs": [5], "marks": []},
	{"title": "Avoid bulb conflicts", "body": "Two bulbs must never see each other in the same uninterrupted row or column. Walls block their line of sight.", "rows": ["....", "....", "....", "...."], "bulbs": [4, 7], "marks": []},
	{"title": "Use bulbs and X notes", "body": "Left-click or press Space/A to toggle a bulb. Right-click or press X to toggle a note. A bulb and an X replace each other in one action; notes do not affect the rules.", "rows": ["....", "....", "....", "...."], "bulbs": [0], "marks": [15]},
	{"title": "Complete the puzzle", "body": "Light every playable cell, avoid bulb conflicts, and satisfy every numbered wall. You can remove a bulb or replace it with an X at any time.", "rows": [".#.", "#.#", ".#."], "bulbs": [0, 2, 6, 8], "marks": []},
]
## Card height required by the current longest tutorial step, including its 4×4 diagram.
const TUTORIAL_CARD_HEIGHT := 474.0
## Shared diagram area sized for the largest current four-row tutorial board.
const TUTORIAL_DIAGRAM_HEIGHT := 161.0

## Current mutable player state, or null when no puzzle is open.
var _state: State
## Latest derived illumination, clue, conflict, and solved-state values.
var _evaluation: Dictionary = {}
## Configuration metadata for the active fixed or random level.
var _current_configuration: Dictionary = {}
## Whether the current puzzle belongs to Random Level mode.
var _random_mode := false
## Grid-cell controls in row-major order.
var _cells: Array[Control] = []
## Full-viewport center container for the current screen.
var _screen: CenterContainer
## Layer above screens for victory dimming and panels.
var _overlay_layer: Control
## Active page content container.
var _page_content: VBoxContainer
## Label showing the current lit-cell count.
var _status: Label
## Music player, looped across screens.
var _music: AudioStreamPlayer
## Player for board and button action sounds.
var _action_audio: AudioStreamPlayer
## Player for warning and victory feedback sounds.
var _feedback_audio: AudioStreamPlayer
## Persistent local player preference store.
var _preferences := Preferences.new()
## Navigation model for current board and buttons.
var _navigation: Navigation
## Focusable board frame.
var _board_focus: PanelContainer
## Action buttons shown beneath the current puzzle.
var _game_buttons: Array[Button] = []
## Victory-panel action buttons while its overlay is open.
var _victory_buttons: Array[Button] = []
## Focusable controls on the current non-game screen.
var _menu_controls: Array[Control] = []
## Corner mute/unmute button shown on the main menu.
var _mute_shortcut: Button
## Optional Settings shoulder hints shown while at least one controller is connected.
var _settings_lb_hint: Label
var _settings_rb_hint: Label
## Current Settings page, used to route shoulder and arrow navigation.
var _settings_active_tab := ""
## Current screen identifier for Back behavior.
var _page_name := ""
## Selected difficulty while browsing its numbered levels.
var _selected_difficulty := ""
## Index of the current tutorial page.
var _tutorial_page := 0
## Per-device directional state from connected controllers.
var _gamepad := GamepadState.new()
## Held-direction repeat timer for controller navigation.
var _direction_repeat := DirectionRepeat.new()
## Controller-only suppression of repeated bulb or annotation actions on the same cell.
var _cell_action_guard := CellActionGuard.new()
## Whether pointer hover is the active source of the shared cell marker.
var _pointer_selection_active := false
## Elapsed mouse inactivity while the game window has focus.
var _pointer_idle_elapsed := 0.0
## Whether this presentation has hidden the mouse pointer.
var _pointer_hidden := false
## Whether real mouse activity currently owns interface highlighting.
var _mouse_navigation_active := false
## Random generator used only to choose temporary random sessions.
var _session_random := RandomNumberGenerator.new()

## Loads preferences and builds the root audio, background, screen, and first page.
func _ready() -> void:
	Bindings.install()
	Input.ignore_joypad_on_unfocused_application = true
	Input.joy_connection_changed.connect(_on_gamepad_connection_changed)
	for device in Input.get_connected_joypads():
		_on_gamepad_connection_changed(device, true)
	_preferences.load_preferences()
	_apply_display_mode()
	theme = Visuals.create_theme()
	Input.set_custom_mouse_cursor(ARROW_TEXTURE, Input.CURSOR_ARROW, Vector2(8, 5))
	Input.set_custom_mouse_cursor(HAND_TEXTURE, Input.CURSOR_POINTING_HAND, Vector2(16, 5))
	_create_audio()
	_create_backdrop()
	_screen = CenterContainer.new()
	_screen.name = "Screen"
	_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_screen)
	_overlay_layer = Control.new()
	_overlay_layer.name = "OverlayLayer"
	_overlay_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay_layer)
	_create_mute_shortcut()
	_session_random.randomize()
	if _preferences.tutorial_seen:
		_show_menu()
	else:
		_start_tutorial(true)


## Releases custom cursor textures and audio before presentation leaves the scene tree.
func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	for player in [_music, _action_audio, _feedback_audio]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null


## Creates persistent music, board-action, and rule-feedback audio players.
func _create_audio() -> void:
	_music = AudioStreamPlayer.new()
	_music.name = "Music"
	var stream := MUSIC.duplicate() as AudioStreamMP3
	stream.loop = true
	_music.stream = stream
	add_child(_music)
	_action_audio = AudioStreamPlayer.new()
	_action_audio.name = "ActionAudio"
	add_child(_action_audio)
	_feedback_audio = AudioStreamPlayer.new()
	_feedback_audio.name = "FeedbackAudio"
	add_child(_feedback_audio)
	_set_music_volume(_preferences.music_volume * 100.0, false)
	_set_global_mute(_preferences.is_muted, false)
	_music.play()


## Adds a scalable full-window background behind the active screen.
func _create_backdrop() -> void:
	var backdrop := TextureRect.new()
	backdrop.name = "Backdrop"
	backdrop.texture = BACKGROUND
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(backdrop, 0)


## Clears old controls and creates a centered page container sized for the viewport.
func _new_page(page_name: String, preferred_width: float, preferred_height: float = 0.0) -> VBoxContainer:
	_page_name = page_name
	_gamepad.reset()
	_direction_repeat.reset()
	_cell_action_guard.reset()
	_clear_overlay()
	for child in _screen.get_children():
		_screen.remove_child(child)
		child.queue_free()
	_cells.clear()
	_game_buttons.clear()
	_victory_buttons.clear()
	_menu_controls.clear()
	_settings_lb_hint = null
	_settings_rb_hint = null
	_settings_active_tab = ""
	_board_focus = null
	_navigation = null
	var available_width := maxf(320.0, get_viewport_rect().size.x - 32.0)
	var available_height := maxf(320.0, get_viewport_rect().size.y - 32.0)
	_screen.modulate.a = 0.0
	var panel := PanelContainer.new()
	panel.name = page_name
	panel.custom_minimum_size.x = minf(preferred_width, available_width)
	if preferred_height > 0.0:
		panel.custom_minimum_size.y = minf(preferred_height, available_height)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", Visuals.page_surface())
	_screen.add_child(panel)
	var content := VBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	_page_content = content
	var transition := create_tween()
	transition.tween_property(_screen, "modulate:a", 1.0, 0.14)
	return content


## Wraps a screen's primary content in the shared dark Quiet Ink card.
func _add_content_card(parent: Control, card_name: String, horizontal_padding: int = 34) -> VBoxContainer:
	var card := PanelContainer.new()
	card.name = card_name
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", Visuals.content_card_surface(horizontal_padding))
	parent.add_child(card)
	var card_content := VBoxContainer.new()
	card_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_content.add_theme_constant_override("separation", 14)
	card.add_child(card_content)
	return card_content


## Adds a non-interactive vertical gap before a Back button.
func _add_back_button_gap(parent: VBoxContainer, height: float = BACK_BUTTON_GAP) -> void:
	var spacer := Control.new()
	spacer.name = "BackButtonGap"
	spacer.custom_minimum_size.y = height
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(spacer)


## Creates a centered label with a chosen font size and optional alignment.
func _label(parent: Node, text: String, font_size: int = 20, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color(0.03, 0.07, 0.13, 0.85))
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label


## Creates a styled button and connects its activation to an action.
func _button(parent: Node, node_name: String, text: String, action: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.disabled = disabled
	button.custom_minimum_size.y = 48
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
	button.pressed.connect(func() -> void:
		_play(_action_audio, CLICK_SOUND)
		action.call()
	)
	parent.add_child(button)
	button.focus_entered.connect(_on_focus_changed)
	button.focus_exited.connect(_refresh_selection)
	return button


## Registers a visible control for directional focus navigation.
func _register_menu_control(control: Control) -> void:
	_menu_controls.append(control)


## Creates the one persistent corner shortcut for global audio mute.
func _create_mute_shortcut() -> void:
	_mute_shortcut = _button(self, "MuteShortcut", "", _toggle_global_mute)
	_mute_shortcut.theme_type_variation = &"IconButton"
	_mute_shortcut.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_mute_shortcut.custom_minimum_size = Vector2(48, 48)
	_mute_shortcut.offset_left = -66.0
	_mute_shortcut.offset_top = 18.0
	_mute_shortcut.offset_right = -18.0
	_mute_shortcut.offset_bottom = 66.0
	_refresh_mute_shortcut()
	_mute_shortcut.visible = false


## Creates the main menu and clears any active puzzle session.
func _show_menu() -> void:
	_state = null
	_evaluation.clear()
	_current_configuration.clear()
	_random_mode = false
	_selected_difficulty = ""
	_pointer_selection_active = false
	var content := _new_page("Menu", 430.0)
	var title := TextureRect.new()
	title.name = "Wordmark"
	title.texture = WORDMARK
	title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title.custom_minimum_size.y = 185.0
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.accessibility_name = "Project Lumen"
	content.add_child(title)
	var tagline := _label(content, "A little light, a little logic.", 17)
	tagline.add_theme_color_override("font_color", Visuals.UI_MUTED)
	var start := _button(content, "StartGame", "Start Game", _show_difficulty)
	var settings := _button(content, "Settings", "Settings", _show_settings)
	var tutorial := _button(content, "Tutorial", "Tutorial", _start_tutorial.bind(false))
	var quit := _button(content, "Quit", "Quit", _quit)
	for control in [start, settings, tutorial, quit]:
		_register_menu_control(control)
	_set_mute_visibility(true)
	_menu_controls.append(_mute_shortcut)
	_focus_if_current.call_deferred(start)


## Shows registered difficulties and Random Level at the same menu level.
func _show_difficulty() -> void:
	_set_mute_visibility(false)
	var content := _new_page("Difficulty", 460.0)
	_label(content, "Start Game", 32)
	for preset in Levels.get_difficulties():
		var difficulty: String = preset.id
		var button := _button(content, "Difficulty_%s" % difficulty, preset.name, _show_level_select.bind(difficulty))
		_register_menu_control(button)
	var random_button := _button(content, "RandomLevel", "Random Level", _start_random_level)
	_register_menu_control(random_button)
	_add_back_button_gap(content, 48.0)
	_register_menu_control(_button(content, "BackToMenu", "Back", _show_menu))
	_focus_first_menu_control()


## Shows the ten fixed levels registered for one difficulty.
func _show_level_select(difficulty: String) -> void:
	_selected_difficulty = difficulty
	var content := _new_page("LevelSelect", 540.0)
	var display_name := _difficulty_name(difficulty)
	_label(content, "%s · Select a Level" % display_name, 30)
	var grid := GridContainer.new()
	grid.name = "LevelGrid"
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", BUTTON_GAP)
	grid.add_theme_constant_override("v_separation", 8)
	content.add_child(grid)
	for level_number in range(1, Levels.get_level_count(difficulty) + 1):
		var level_button := _button(grid, "Level_%02d" % level_number, "Level %d" % level_number, _open_numbered_level.bind(difficulty, level_number))
		_register_menu_control(level_button)
	_add_back_button_gap(content)
	_register_menu_control(_button(content, "BackToDifficulty", "Back", _show_difficulty))
	_focus_first_menu_control()


## Opens the fixed puzzle assigned to a difficulty and level number.
func _open_numbered_level(difficulty: String, level_number: int) -> void:
	var configuration = Levels.get_configuration(difficulty, level_number)
	_open_configuration(configuration, false)


## Chooses a registered difficulty uniformly and starts a temporary random puzzle.
func _start_random_level() -> void:
	var difficulty := Levels.get_random_difficulty(_session_random)
	if difficulty.is_empty():
		push_error("No difficulty presets are registered.")
		return
	var configuration = Levels.get_configuration(difficulty)
	configuration.level_id = "random_%s_%08x" % [difficulty, _session_random.randi()]
	configuration.level_number = 0
	configuration.level_seed = _session_random.randi()
	_open_configuration(configuration, true)


## Generates the supplied configuration and builds a clean gameplay page.
func _open_configuration(configuration, random_mode: bool) -> void:
	if configuration == null:
		push_error("A level configuration is required.")
		return
	var generated := Generator.generate(configuration)
	if not generated.ok:
		push_error("Level generation failed: %s" % generated.error)
		var error_content := _new_page("LoadError", 540.0)
		_label(error_content, "This puzzle could not be loaded.", 26)
		_register_menu_control(_button(error_content, "BackToMenu", "Exit to Menu", _show_menu))
		_focus_first_menu_control()
		return
	_random_mode = random_mode
	_selected_difficulty = configuration.difficulty_id
	_state = State.new(generated.board)
	_current_configuration = generated.configuration
	var page_content := _new_page("Game", 540.0)
	var content := _add_content_card(page_content, "GameplayCard", 36)
	_random_mode = random_mode
	_navigation = Navigation.new(_state.board.width, _state.board.height, 3)
	var identity := "%s · %s" % [configuration.difficulty, "Random" if random_mode else "Level %d" % configuration.level_number]
	_label(content, identity, 29)
	_status = _label(content, "", 17)
	_status.name = "Status"
	var board_center := CenterContainer.new()
	board_center.name = "BoardCenter"
	content.add_child(board_center)
	_board_focus = PanelContainer.new()
	_board_focus.name = "BoardFrame"
	_board_focus.focus_mode = Control.FOCUS_ALL
	_board_focus.focus_entered.connect(_on_focus_changed)
	_board_focus.focus_exited.connect(_refresh_selection)
	var frame_style := Visuals.box(Visuals.INK, 18)
	for margin in ["left", "right", "top", "bottom"]:
		frame_style.set("content_margin_%s" % margin, 10)
	_board_focus.add_theme_stylebox_override("panel", frame_style)
	board_center.add_child(_board_focus)
	var grid := GridContainer.new()
	grid.name = "Board"
	grid.columns = _state.board.width
	grid.add_theme_constant_override("h_separation", BOARD_GAP)
	grid.add_theme_constant_override("v_separation", BOARD_GAP)
	_board_focus.add_child(grid)
	var viewport_size := get_viewport_rect().size
	var available_extent := minf(MAX_BOARD_EXTENT, minf(viewport_size.x - 96.0, viewport_size.y - 355.0))
	var longest_side: int = maxi(_state.board.width, _state.board.height)
	var cell_extent := maxf(20.0, floorf((maxf(180.0, available_extent) - BOARD_GAP * (longest_side - 1)) / longest_side))
	for index in range(_state.board.cell_count()):
		var cell := CellView.new()
		cell.cell_extent = cell_extent
		cell.name = "Cell%d" % index
		cell.cell_index = index
		cell.wall = _state.board.is_wall(index)
		cell.clue = _state.board.clue_at(index)
		cell.primary_clicked.connect(_on_mouse_primary)
		cell.secondary_clicked.connect(_on_mouse_secondary)
		cell.pointer_entered.connect(_on_cell_pointer_entered)
		cell.pointer_exited.connect(_on_cell_pointer_exited)
		grid.add_child(cell)
		_cells.append(cell)
	var actions := HBoxContainer.new()
	actions.name = "Actions"
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", BUTTON_GAP)
	content.add_child(actions)
	_game_buttons.append(_button(actions, "Restart", "Restart", _restart))
	if random_mode:
		_game_buttons.append(_button(actions, "NewRandomLevel", "New Random Level", _start_random_level))
	_game_buttons.append(_button(actions, "ExitToMenu", "Exit to Menu", _show_menu))
	_navigation.set_button_count(_game_buttons.size())
	_refresh_board()
	_focus_if_current.call_deferred(_board_focus)


## Shows the fixed Settings shell with its Audio & Display page active.
func _show_settings() -> void:
	_build_settings_page("AudioDisplay")


## Shows the fixed Settings shell with its Controls page active.
func _show_controls() -> void:
	_build_settings_page("Controls")


## Creates the Settings shell once per visit and reuses it when switching tabs.
func _build_settings_page(active_tab: String) -> void:
	if _page_name == "Settings":
		_update_settings_tab(active_tab)
		return
	_set_mute_visibility(false)
	var page_content := _new_page("Settings", 996.0, 684.0)
	var content := _add_content_card(page_content, "SettingsCard", 26)
	content.get_parent().add_theme_stylebox_override("panel", Visuals.settings_card_surface())
	_add_settings_header(content)
	var viewport_frame := PanelContainer.new()
	viewport_frame.name = "SettingsViewportFrame"
	var available_settings_height := maxf(320.0, get_viewport_rect().size.y - 32.0)
	viewport_frame.custom_minimum_size.y = clampf(available_settings_height - 380.0, 140.0, 388.0)
	viewport_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_frame.add_theme_stylebox_override("panel", Visuals.settings_viewport_surface())
	content.add_child(viewport_frame)
	var scroll := ScrollContainer.new()
	scroll.name = "SettingsContentScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_RESERVE
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_frame.add_child(scroll)
	var inset := MarginContainer.new()
	inset.name = "SettingsContentInset"
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_left", 30)
	inset.add_theme_constant_override("margin_right", 24)
	inset.add_theme_constant_override("margin_top", 10)
	inset.add_theme_constant_override("margin_bottom", 10)
	scroll.add_child(inset)
	var scroll_content := VBoxContainer.new()
	scroll_content.name = "SettingsContent"
	scroll_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_content.add_theme_constant_override("separation", 24)
	inset.add_child(scroll_content)
	var footer := MarginContainer.new()
	footer.name = "SettingsFooter"
	footer.add_theme_constant_override("margin_top", 6)
	content.add_child(footer)
	var back := _button(footer, "SettingsBack", "Back", _show_menu)
	back.custom_minimum_size = Vector2(172, 50)
	back.add_theme_font_size_override("font_size", 22)
	_register_menu_control(back)
	_update_settings_tab(active_tab)


## Replaces only the inner tab content, keeping the shell opaque and focus valid.
## Selecting the already active tab retains its controls and scroll position.
func _update_settings_tab(active_tab: String) -> void:
	var audio_tab := _screen.find_child("AudioDisplayTab", true, false) as Button
	var controls_tab := _screen.find_child("ControlsTab", true, false) as Button
	audio_tab.set_pressed_no_signal(active_tab == "AudioDisplay")
	controls_tab.set_pressed_no_signal(active_tab == "Controls")
	if _settings_active_tab != active_tab:
		_gamepad.reset()
		_direction_repeat.reset()
		_settings_active_tab = active_tab
		var content := _screen.find_child("SettingsContent", true, false) as VBoxContainer
		for control in _menu_controls.duplicate():
			if not is_instance_valid(control) or content.is_ancestor_of(control):
				_menu_controls.erase(control)
		for child in content.get_children():
			content.remove_child(child)
			child.queue_free()
		if active_tab == "AudioDisplay":
			_populate_audio_settings(content)
		else:
			_populate_control_settings(content)
		var scroll := _screen.find_child("SettingsContentScroll", true, false) as ScrollContainer
		scroll.scroll_vertical = 0
	var active_button: Button = audio_tab if active_tab == "AudioDisplay" else controls_tab
	_focus_if_current.call_deferred(active_button)


## Adds the audio and display controls to the fixed Settings viewport.
func _populate_audio_settings(content: VBoxContainer) -> void:
	var music_group := VBoxContainer.new()
	music_group.add_theme_constant_override("separation", 20)
	content.add_child(music_group)
	_label(music_group, "Music volume", 27, HORIZONTAL_ALIGNMENT_LEFT)
	_settings_divider(music_group, false, true)
	var volume_row := HBoxContainer.new()
	volume_row.name = "MusicVolumeRow"
	volume_row.custom_minimum_size = Vector2(420.0, 48.0)
	volume_row.add_theme_constant_override("separation", 16)
	volume_row.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	music_group.add_child(volume_row)
	var slider := HSlider.new()
	slider.name = "MusicVolume"
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = _preferences.music_volume * 100.0
	slider.custom_minimum_size.x = 340.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.focus_mode = Control.FOCUS_ALL
	slider.value_changed.connect(_on_music_slider_changed)
	volume_row.add_child(slider)
	_register_menu_control(slider)
	var volume_value := _label(volume_row, "%d%%" % roundi(slider.value), 22)
	volume_value.custom_minimum_size.x = 60
	volume_value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(func(value: float) -> void: volume_value.text = "%d%%" % roundi(value))
	var display_group := VBoxContainer.new()
	display_group.add_theme_constant_override("separation", 20)
	content.add_child(display_group)
	_label(display_group, "Display mode", 27, HORIZONTAL_ALIGNMENT_LEFT)
	_settings_divider(display_group, false, true)
	var mode_button := _button(display_group, "DisplayMode", "Fullscreen" if _preferences.fullscreen else "Windowed", _toggle_display_mode)
	mode_button.custom_minimum_size = Vector2(210, 50)
	mode_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	mode_button.add_theme_font_size_override("font_size", 22)
	_register_menu_control(mode_button)


## Adds the read-only input reference to the fixed Settings viewport.
func _populate_control_settings(content: VBoxContainer) -> void:
	var columns := HBoxContainer.new()
	columns.name = "InputReferenceColumns"
	columns.add_theme_constant_override("separation", 26)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(columns)
	var keyboard := _controls_group(columns, "Keyboard / Mouse")
	var movement := _command_row_frame(keyboard, "Move", 68)
	var keys := HBoxContainer.new()
	keys.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keys.alignment = BoxContainer.ALIGNMENT_CENTER
	keys.add_theme_constant_override("separation", 14)
	movement.add_child(keys)
	for binding in [["↑", "↓", "←", "→"], ["W", "A", "S", "D"]]:
		var key_group := HBoxContainer.new()
		key_group.add_theme_constant_override("separation", 3)
		keys.add_child(key_group)
		for key in binding:
			_settings_keycap(key_group, key, true)
	_command_row(keyboard, "Bulb", ["Space", "Left click"])
	_command_row(keyboard, "X note", ["X", "Right click"])
	_command_row(keyboard, "Confirm", ["Enter", "Space"])
	_command_row(keyboard, "Exit to Menu", ["Esc"])
	_settings_divider(columns, true)
	var gamepad := _controls_group(columns, "Gamepad")
	var pad_movement := _command_row_frame(gamepad, "Move", 132)
	var pad_bindings := HBoxContainer.new()
	pad_bindings.add_theme_constant_override("separation", 12)
	pad_movement.add_child(pad_bindings)
	_gamepad_movement_hint(pad_bindings, GAMEPAD_DPAD, "D-pad")
	_gamepad_movement_hint(pad_bindings, GAMEPAD_LEFT_STICK, "Left stick", "L")
	_gamepad_command_row(gamepad, "Bulb / Confirm", "A", "Bottom", Color("d9e66e"))
	_gamepad_command_row(gamepad, "X note", "X", "Left", Color("a9baff"))
	_gamepad_command_row(gamepad, "Exit to Menu", "B", "Right", Color("ff6b63"))


## Builds the fixed Settings title and tab navigation shared by both Settings pages.
func _add_settings_header(content: VBoxContainer) -> void:
	_label(content, "Settings", 40)
	var navigation := Control.new()
	navigation.name = "SettingsTabNavigation"
	navigation.custom_minimum_size.y = 58.0
	navigation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(navigation)
	_settings_lb_hint = _settings_arrow_cluster(navigation, "PreviousSettingsTab", SETTINGS_ARROW_LEFT, "LB")
	var tabs := HBoxContainer.new()
	tabs.name = "SettingsTabs"
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_theme_constant_override("separation", BUTTON_GAP)
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	navigation.add_child(tabs)
	tabs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tabs.offset_left = 48
	tabs.offset_right = -48
	var audio_tab := _button(tabs, "AudioDisplayTab", "Audio & Display", _show_settings)
	var controls_tab := _button(tabs, "ControlsTab", "Controls", _show_controls)
	for tab in [audio_tab, controls_tab]:
		tab.add_theme_font_size_override("font_size", 22)
		tab.custom_minimum_size = Vector2(252 if tab == audio_tab else 214, 54)
		tab.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	audio_tab.toggle_mode = true
	controls_tab.toggle_mode = true
	_settings_rb_hint = _settings_arrow_cluster(navigation, "NextSettingsTab", SETTINGS_ARROW_RIGHT, "RB")
	_register_menu_control(audio_tab)
	_register_menu_control(controls_tab)
	_refresh_settings_tab_hints()


## Keeps an arrow and its hint inside the corresponding edge of the inner card.
func _settings_arrow_cluster(parent: Control, node_name: String, texture: Texture2D, hint_text: String) -> Label:
	var cluster := VBoxContainer.new()
	cluster.name = "%sCluster" % node_name
	cluster.custom_minimum_size = Vector2(48.0, 58.0)
	cluster.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cluster.alignment = BoxContainer.ALIGNMENT_CENTER
	cluster.add_theme_constant_override("separation", 0)
	parent.add_child(cluster)
	cluster.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT if hint_text == "LB" else Control.PRESET_TOP_RIGHT)
	cluster.offset_left = 0 if hint_text == "LB" else -48
	cluster.offset_right = 48 if hint_text == "LB" else 0
	cluster.offset_top = 0
	cluster.offset_bottom = 58
	var arrow := TextureButton.new()
	arrow.name = node_name
	arrow.ignore_texture_size = true
	arrow.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	arrow.texture_normal = texture
	arrow.texture_hover = texture
	arrow.texture_pressed = texture
	arrow.custom_minimum_size = Vector2(40.0, 38.0)
	arrow.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	arrow.focus_mode = Control.FOCUS_ALL
	arrow.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	arrow.accessibility_name = "Previous Settings tab" if hint_text == "LB" else "Next Settings tab"
	arrow.tooltip_text = arrow.accessibility_name
	arrow.pressed.connect(func() -> void:
		_play(_action_audio, CLICK_SOUND)
		_change_settings_tab()
	)
	arrow.focus_entered.connect(_on_focus_changed)
	arrow.focus_exited.connect(_refresh_selection)
	arrow.mouse_entered.connect(func() -> void:
		if not _pointer_hidden:
			arrow.modulate = Color(1.16, 1.08, 0.88, 1.0)
	)
	arrow.mouse_exited.connect(func() -> void:
		if _mouse_navigation_active or not arrow.has_focus():
			arrow.modulate = Color.WHITE
	)
	arrow.focus_entered.connect(func() -> void:
		if not _mouse_navigation_active:
			arrow.modulate = Color(1.16, 1.08, 0.88, 1.0)
	)
	arrow.focus_exited.connect(func() -> void: arrow.modulate = Color.WHITE)
	cluster.add_child(arrow)
	var hint := _settings_hint(cluster, hint_text)
	cluster.move_child(hint, 1)
	_register_menu_control(arrow)
	return hint


## Creates an optional controller shoulder hint beneath a Settings tab arrow.
func _settings_hint(parent: Node, text: String) -> Label:
	var connected := not Input.get_connected_joypads().is_empty()
	var hint := _label(parent, text if connected else "", 16)
	hint.name = "%sHint" % text
	hint.set_meta("shortcut_label", text)
	hint.custom_minimum_size = Vector2(48.0, 16.0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Visuals.UI_MUTED)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return hint


## Updates the visible LB/RB hints after controller connection changes.
func _refresh_settings_tab_hints() -> void:
	var connected := not Input.get_connected_joypads().is_empty()
	for hint in [_settings_lb_hint, _settings_rb_hint]:
		if is_instance_valid(hint):
			hint.text = str(hint.get_meta("shortcut_label", "")) if connected else ""


## Switches between the two pages within the fixed Settings shell.
func _change_settings_tab() -> void:
	if _settings_active_tab == "AudioDisplay":
		_show_controls()
	else:
		_show_settings()


## Creates one equally sized input-device column with an amber heading rule.
func _controls_group(parent: Node, title: String) -> VBoxContainer:
	var group := VBoxContainer.new()
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	group.add_theme_constant_override("separation", 0)
	parent.add_child(group)
	var heading := _label(group, title, 27, HORIZONTAL_ALIGNMENT_LEFT)
	heading.custom_minimum_size.y = 44
	_settings_divider(group, false, true)
	return group


## Adds a quiet horizontal or vertical rule without intercepting pointer input.
func _settings_divider(parent: Node, vertical: bool = false, accent: bool = false) -> void:
	var line: Separator = VSeparator.new() if vertical else HSeparator.new()
	line.add_theme_stylebox_override("separator", Visuals.settings_rule(vertical, accent))
	line.add_theme_constant_override("separation", 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(line)


## Creates a consistently spaced reference row, separating it from preceding rows.
func _command_row_frame(parent: VBoxContainer, action_text: String, label_width: float = 114.0) -> HBoxContainer:
	if parent.get_child_count() > 2:
		_settings_divider(parent)
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 56
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var action := _label(row, action_text, 20, HORIZONTAL_ALIGNMENT_LEFT)
	action.custom_minimum_size.x = label_width
	return row


## Adds a keyboard command with two aligned binding slots and editable key labels.
func _command_row(parent: VBoxContainer, action_text: String, glyphs: Array[String]) -> void:
	var row := _command_row_frame(parent, action_text)
	var bindings := HBoxContainer.new()
	bindings.add_theme_constant_override("separation", 24)
	row.add_child(bindings)
	for index in range(2):
		var slot := CenterContainer.new()
		slot.custom_minimum_size.x = 88 if index == 0 else 112
		bindings.add_child(slot)
		if index < glyphs.size():
			_settings_keycap(slot, glyphs[index])


## Creates one native, noninteractive keycap; movement keys use equal compact boxes.
func _settings_keycap(parent: Node, text: String, compact: bool = false) -> void:
	var keycap := PanelContainer.new()
	keycap.custom_minimum_size = Vector2(28 if compact else 36, 34 if compact else 36)
	keycap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	keycap.add_theme_stylebox_override("panel", Visuals.settings_keycap_surface(compact))
	keycap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(keycap)
	_label(keycap, text, 18 if compact else 19)


## Pairs a neutral gamepad drawing with its editable movement name and stick letter.
func _gamepad_movement_hint(parent: Node, texture: Texture2D, text: String, letter: String = "") -> void:
	var hint := HBoxContainer.new()
	hint.add_theme_constant_override("separation", 8)
	parent.add_child(hint)
	var icon := TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(36, 36)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_child(icon)
	if not letter.is_empty():
		var stick_letter := _label(icon, letter, 19)
		stick_letter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label(hint, text, 18, HORIZONTAL_ALIGNMENT_LEFT)


## Shows a colored Xbox face-button badge alongside its neutral physical position.
func _gamepad_command_row(parent: VBoxContainer, action_text: String, letter: String, position_text: String, color: Color) -> void:
	var row := _command_row_frame(parent, action_text, 154)
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(38, 38)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var surface := Visuals.box(Color(0.035, 0.07, 0.11, 0.7), 19, color, 2)
	surface.set_content_margin_all(0)
	badge.add_theme_stylebox_override("panel", surface)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(badge)
	var badge_letter := _label(badge, letter, 27)
	badge_letter.add_theme_color_override("font_color", color)
	var caption := _label(row, "%s · %s" % [letter, position_text], 20, HORIZONTAL_ALIGNMENT_LEFT)
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL


## Updates the music preference and its current audio-player volume.
func _on_music_slider_changed(value: float) -> void:
	_set_music_volume(value, true)


## Sets music volume from a percentage and optionally saves the preference.
func _set_music_volume(value: float, save: bool) -> void:
	var linear_volume := clampf(value / 100.0, 0.0, 1.0)
	_preferences.music_volume = linear_volume
	if _music != null:
		_music.volume_linear = linear_volume
	if save:
		_preferences.save_preferences()


## Toggles global mute while preserving all current audio levels.
func _toggle_global_mute() -> void:
	_set_global_mute(not _preferences.is_muted, true)


## Applies global mute and optionally saves the preference.
func _set_global_mute(muted: bool, save: bool) -> void:
	_preferences.is_muted = muted
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_mute(master_bus, muted)
	_refresh_mute_shortcut()
	if save:
		_preferences.save_preferences()


## Updates the corner shortcut to show the current mute state.
func _refresh_mute_shortcut() -> void:
	if _mute_shortcut == null:
		return
	_mute_shortcut.icon = AUDIO_MUTED if _preferences.is_muted else AUDIO_ON
	_mute_shortcut.add_theme_constant_override("icon_max_width", 24)
	_mute_shortcut.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mute_shortcut.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mute_shortcut.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	_mute_shortcut.tooltip_text = "Unmute all audio" if _preferences.is_muted else "Mute all audio"
	_mute_shortcut.accessibility_name = _mute_shortcut.tooltip_text


## Applies and saves the display mode in place, preserving Settings focus and scroll.
func _toggle_display_mode() -> void:
	_preferences.fullscreen = not _preferences.fullscreen
	_apply_display_mode()
	_preferences.save_preferences()
	var mode_button := _screen.find_child("DisplayMode", true, false) as Button
	if mode_button != null:
		mode_button.text = "Fullscreen" if _preferences.fullscreen else "Windowed"


## Applies the saved fullscreen or windowed mode to the current window.
func _apply_display_mode() -> void:
	if not is_inside_tree():
		return
	var target_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if _preferences.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != target_mode:
		DisplayServer.window_set_mode(target_mode)


## Shows the tutorial at the requested page and marks it seen on opening.
func _start_tutorial(first_launch: bool = false) -> void:
	_set_mute_visibility(false)
	_tutorial_page = 0
	_preferences.mark_tutorial_seen()
	_show_tutorial_page()


## Creates the fixed-size tutorial card and its persistent labels, diagram slot, and buttons.
func _build_tutorial_shell() -> void:
	var page_content := _new_page("Tutorial", 620.0, TUTORIAL_CARD_HEIGHT + 44.0)
	page_content.get_parent().custom_minimum_size.y = TUTORIAL_CARD_HEIGHT + 44.0
	var content := _add_content_card(page_content, "TutorialCard")
	var tutorial_card := content.get_parent() as PanelContainer
	tutorial_card.custom_minimum_size.y = TUTORIAL_CARD_HEIGHT
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	var page_indicator := _label(content, "", 18)
	page_indicator.name = "TutorialPageIndicator"
	var title := _label(content, "", 30)
	title.name = "TutorialPageTitle"
	var description := _label(content, "", 18)
	description.name = "TutorialPageDescription"
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.x = 400.0
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var diagram_slot := CenterContainer.new()
	diagram_slot.name = "TutorialDiagramSlot"
	diagram_slot.custom_minimum_size.y = TUTORIAL_DIAGRAM_HEIGHT
	diagram_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diagram_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(diagram_slot)
	var actions := HBoxContainer.new()
	actions.name = "TutorialActions"
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", BUTTON_GAP)
	content.add_child(actions)
	var next_button := _button(actions, "NextPage", "Next", _next_tutorial_page)
	_register_menu_control(next_button)
	_register_menu_control(_button(actions, "SkipTutorial", "Skip", _show_menu))


## Updates tutorial text and diagram in place, then focuses Next or Done.
func _show_tutorial_page() -> void:
	if _page_name != "Tutorial":
		_build_tutorial_shell()
	var page: Dictionary = TUTORIAL_PAGES[_tutorial_page]
	var indicator := _screen.find_child("TutorialPageIndicator", true, false) as Label
	indicator.text = "Tutorial · %d / %d" % [_tutorial_page + 1, TUTORIAL_PAGES.size()]
	var title := _screen.find_child("TutorialPageTitle", true, false) as Label
	title.text = page.title
	var description := _screen.find_child("TutorialPageDescription", true, false) as Label
	description.text = page.body
	var diagram_slot := _screen.find_child("TutorialDiagramSlot", true, false) as Control
	for child in diagram_slot.get_children():
		diagram_slot.remove_child(child)
		child.queue_free()
	_add_tutorial_diagram(diagram_slot, page)
	var next_button := _screen.find_child("NextPage", true, false) as Button
	next_button.text = "Done" if _tutorial_page == TUTORIAL_PAGES.size() - 1 else "Next"
	_focus_if_current.call_deferred(next_button)


## Creates an inert diagram using the same cell renderer as gameplay.
func _add_tutorial_diagram(parent: Node, page: Dictionary) -> void:
	var board := Board.new(PackedStringArray(page.rows))
	var state := State.new(board)
	for index in page.bulbs:
		state.toggle_bulb(index)
	for index in page.marks:
		state.toggle_annotation(index)
	var evaluation: Dictionary = state.evaluate()
	var grid := GridContainer.new()
	grid.name = "TutorialBoard"
	grid.columns = board.width
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(grid)
	for index in range(board.cell_count()):
		var cell := CellView.new()
		cell.cell_index = index
		cell.cell_extent = 38.0
		cell.wall = board.is_wall(index)
		cell.clue = board.clue_at(index)
		cell.bulb = bool(state.bulbs[index])
		cell.marked = bool(state.annotations[index])
		cell.illuminated = bool(evaluation.illuminated[index])
		cell.conflict = bool(evaluation.conflicts[index])
		cell.interaction_enabled = false
		grid.add_child(cell)


## Advances to the next tutorial page or returns to the menu after the last page.
func _next_tutorial_page() -> void:
	if _tutorial_page >= TUTORIAL_PAGES.size() - 1:
		_show_menu()
		return
	_tutorial_page += 1
	_show_tutorial_page()


## Updates pointer activity and routes keyboard/gamepad events to shared actions.
func _input(event: InputEvent) -> void:
	if get_window().has_focus():
		_handle_pointer_activity(event)
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		get_viewport().set_input_as_handled()
		if not get_window().has_focus():
			return
		if event is InputEventJoypadButton and event.pressed and _page_name == "Settings" and event.button_index in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER]:
			_change_settings_tab()
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


## Advances pointer inactivity and applies held gamepad navigation.
func _process(delta: float) -> void:
	if not get_window().has_focus():
		return
	_advance_pointer_idle(delta)
	var direction := _direction_repeat.advance(_gamepad.direction(), delta)
	if direction != Vector2i.ZERO:
		_set_pointer_hidden(true)
		_navigate(direction)


## Restores the free pointer on focus changes and clears held input on focus loss.
func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_FOCUS_IN]:
		_set_pointer_hidden(false)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and _gamepad != null:
		_gamepad.reset()
		_direction_repeat.reset()
		_cell_action_guard.reset()


## Shows the pointer for real mouse activity and hides it for other intentional input.
## Neutral stick drift and release events do not change the active input method.
func _handle_pointer_activity(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not event.relative.is_zero_approx():
		_set_mouse_navigation_active(true)
		_set_pointer_hidden(false)
		_restore_pointer_selection(event.position)
	elif event is InputEventMouseButton and event.pressed:
		_set_mouse_navigation_active(true)
		_set_pointer_hidden(false)
	elif event is InputEventKey and event.pressed:
		_set_mouse_navigation_active(false)
		_set_pointer_hidden(true)
	elif event is InputEventJoypadButton and event.pressed:
		_set_mouse_navigation_active(false)
		_set_pointer_hidden(true)
	elif event is InputEventJoypadMotion and event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y] and absf(event.axis_value) > Bindings.STICK_DEADZONE:
		_set_mouse_navigation_active(false)
		_set_pointer_hidden(true)


## Hides an idle pointer after the timeout; callers advance only while focused.
func _advance_pointer_idle(delta: float) -> void:
	if _pointer_hidden:
		return
	_pointer_idle_elapsed += maxf(0.0, delta)
	if _pointer_idle_elapsed >= POINTER_IDLE_SECONDS:
		_set_pointer_hidden(true)


## Changes visibility without capturing or moving the mouse, and clears stale hover selection.
func _set_pointer_hidden(hidden: bool) -> void:
	if not hidden:
		_pointer_idle_elapsed = 0.0
	if _pointer_hidden == hidden:
		return
	_pointer_hidden = hidden
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if hidden else Input.MOUSE_MODE_VISIBLE
	_update_pointer_hover_styles()
	if hidden:
		_pointer_selection_active = false
		_refresh_selection()


## Changes highlight ownership without discarding the remembered GUI focus.
func _set_mouse_navigation_active(active: bool) -> void:
	if _mouse_navigation_active == active:
		return
	_mouse_navigation_active = active
	_update_pointer_hover_styles()


## Shows only the current input method's button highlights.
## The OS cursor can remain over a control even when its image is hidden.
func _update_pointer_hover_styles() -> void:
	for button_type in ["Button", "IconButton"]:
		theme.set_stylebox("hover", button_type, theme.get_stylebox("normal", button_type) if _pointer_hidden else Visuals.button_surface(1, button_type == "IconButton"))
		theme.set_stylebox("focus", button_type, StyleBoxEmpty.new() if _mouse_navigation_active else Visuals.button_surface(4, button_type == "IconButton"))
	for control in _menu_controls:
		if is_instance_valid(control) and control is TextureButton:
			var highlighted: bool = (not _mouse_navigation_active and control.has_focus()) or (not _pointer_hidden and control.is_hovered())
			control.modulate = Color(1.16, 1.08, 0.88, 1.0) if highlighted else Color.WHITE


## Restores hover when a hidden pointer moves inside the same cell without re-entering it.
func _restore_pointer_selection(position: Vector2) -> void:
	if _navigation == null or _evaluation.get("solved", false):
		return
	for cell in _cells:
		if not cell.wall and cell.interaction_enabled and cell.get_global_rect().has_point(position):
			if not _pointer_selection_active or _navigation.selected_cell != cell.cell_index:
				_on_cell_pointer_entered(cell.cell_index)
			return


## Updates directional state when a gamepad connects or disconnects.
func _on_gamepad_connection_changed(device: int, connected: bool) -> void:
	_refresh_settings_tab_hints()
	if connected:
		print("Gamepad connected: %s (standard mapping: %s)" % [Input.get_joy_name(device), Input.is_joy_known(device)])
	else:
		_gamepad.remove_device(device)
		_direction_repeat.reset()
		_cell_action_guard.reset()


## Moves focus according to the visible board or current interface layout.
func _navigate(direction: Vector2i) -> bool:
	_restore_missing_input_focus()
	if _page_name == "Game":
		var active_buttons := _active_game_buttons()
		var focused := get_viewport().gui_get_focus_owner()
		if focused == _board_focus and not _evaluation.get("solved", false):
			_pointer_selection_active = false
			_navigation.move(direction, _nearest_button_below())
			_sync_game_focus(active_buttons)
			return true
		if focused in active_buttons:
			if _evaluation.get("solved", false):
				_navigation.set_button_count(active_buttons.size())
			if direction == Vector2i.UP and _evaluation.get("solved", false):
				return true
			_navigation.select_button(active_buttons.find(focused))
			_navigation.move(direction)
			_sync_game_focus(active_buttons)
			return true
		return false
	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control is HSlider and direction.x != 0:
		focused_control.value = clampf(focused_control.value + direction.x * 5.0, focused_control.min_value, focused_control.max_value)
		return true
	if focused_control in _menu_controls:
		var next_control := _nearest_control(focused_control, direction, _menu_controls)
		if next_control != null:
			next_control.grab_focus()
		return true
	return false


## Finds the closest visible focusable control in the requested direction.
func _nearest_control(current: Control, direction: Vector2i, controls: Array[Control]) -> Control:
	var current_rect := current.get_global_rect()
	var current_center := current_rect.get_center()
	var best: Control
	var best_score := INF
	for candidate in controls:
		if candidate == current or not is_instance_valid(candidate) or not candidate.is_visible_in_tree() or (candidate is BaseButton and candidate.disabled):
			continue
		var rect := candidate.get_global_rect()
		var center := rect.get_center()
		var delta := center - current_center
		var primary := delta.x * direction.x + delta.y * direction.y
		if primary <= 1.0:
			continue
		var lateral := absf(delta.x * direction.y - delta.y * direction.x)
		var score := primary + lateral * 2.2
		if score < best_score:
			best_score = score
			best = candidate
	return best


## Dispatches Back, board actions, slider interactions, and focused buttons.
func _dispatch_action(event: InputEvent, repeated: bool) -> void:
	if Bindings.pressed(event, "lumen_back", true):
		get_viewport().set_input_as_handled()
		if not repeated:
			_go_back()
		return
	_restore_missing_input_focus()
	if _page_name == "Game":
		var active_buttons := _active_game_buttons()
		var focused := get_viewport().gui_get_focus_owner()
		if focused == _board_focus and not _evaluation.get("solved", false):
			if Bindings.pressed(event, "lumen_bulb", true):
				if not repeated and _accept_cell_action(event, &"bulb", _navigation.selected_cell):
					_on_primary_click(_navigation.selected_cell)
			elif Bindings.pressed(event, "lumen_annotation", true):
				if not repeated and _accept_cell_action(event, &"annotation", _navigation.selected_cell):
					_on_secondary_click(_navigation.selected_cell)
			get_viewport().set_input_as_handled()
			return
		if focused in active_buttons and Bindings.pressed(event, "lumen_activate", true):
			get_viewport().set_input_as_handled()
			if not repeated:
				(focused as Button).emit_signal("pressed")
		return
	if focused_control_is_actionable(get_viewport().gui_get_focus_owner(), event):
		var focused := get_viewport().gui_get_focus_owner()
		get_viewport().set_input_as_handled()
		if not repeated and focused is BaseButton and Bindings.pressed(event, "lumen_activate", true):
			(focused as BaseButton).emit_signal("pressed")


## Filters repeated controller actions while preserving mouse and keyboard timing.
func _accept_cell_action(event: InputEvent, action: StringName, cell_index: int) -> bool:
	return not event is InputEventJoypadButton or _cell_action_guard.allow(action, cell_index, Time.get_ticks_msec())


## Returns whether an interface control activation action was pressed.
func focused_control_is_actionable(focused: Control, event: InputEvent) -> bool:
	return focused in _menu_controls and Bindings.pressed(event, "lumen_activate", true)


## Uses the current screen context for Back, with puzzle exits always returning to the main menu.
func _go_back() -> void:
	match _page_name:
		"Menu":
			return
		"Difficulty":
			_show_menu()
		"LevelSelect":
			_show_difficulty()
		"Settings":
			_show_menu()
		"Tutorial", "LoadError":
			_show_menu()
		"Game":
			_play(_action_audio, CLICK_SOUND)
			_show_menu()
		_:
			_show_menu()


## Returns the button row used for the active game or victory panel.
func _active_game_buttons() -> Array[Button]:
	return _victory_buttons if _evaluation.get("solved", false) and not _victory_buttons.is_empty() else _game_buttons


## Finds the gameplay action button nearest to the selected cell horizontally.
func _nearest_button_below() -> int:
	if _game_buttons.is_empty():
		return 0
	var selected_x := _cells[_navigation.selected_cell].get_global_rect().get_center().x
	var closest := 0
	var distance := INF
	for index in range(_game_buttons.size()):
		var candidate := absf(_game_buttons[index].get_global_rect().get_center().x - selected_x)
		if candidate < distance:
			distance = candidate
			closest = index
	return closest


## Restores gameplay selection or the current menu entry when GUI focus is missing.
## Settings resumes on its active tab; Tutorial resumes on Next or Done.
func _restore_missing_input_focus() -> void:
	if get_viewport().gui_get_focus_owner() != null:
		return
	if _page_name == "Game" and _navigation != null:
		_sync_game_focus(_active_game_buttons())
		return
	var preferred: Control
	if _page_name == "Settings":
		preferred = _screen.find_child("ControlsTab" if _settings_active_tab == "Controls" else "AudioDisplayTab", true, false) as Control
	elif _page_name == "Tutorial":
		preferred = _screen.find_child("NextPage", true, false) as Control
	if preferred != null:
		preferred.grab_focus()
		return
	for control in _menu_controls:
		if is_instance_valid(control) and control.is_visible_in_tree() and control.focus_mode != Control.FOCUS_NONE and not (control is BaseButton and control.disabled):
			control.grab_focus()
			return


## Applies board/button navigation selection to Godot GUI focus.
func _sync_game_focus(buttons: Array[Button]) -> void:
	if _navigation.is_on_board() and not _evaluation.get("solved", false):
		_board_focus.grab_focus()
	else:
		_navigation.set_button_count(buttons.size())
		_navigation.select_button(clampi(_navigation.selected_button, 0, buttons.size() - 1))
		buttons[_navigation.selected_button].grab_focus()
	_refresh_selection()


## Applies delayed focus only while the target still belongs to the current screen.
func _focus_if_current(control: Control) -> void:
	if is_instance_valid(control) and control.is_inside_tree() and control.is_visible_in_tree():
		control.grab_focus()


## Selects the first visible interface control when a page opens.
func _focus_first_menu_control() -> void:
	for control in _menu_controls:
		if is_instance_valid(control) and control.is_visible_in_tree() and not control.disabled:
			_focus_if_current.call_deferred(control)
			return


## Synchronizes the navigation model after a focus change.
func _on_focus_changed() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if _page_name == "Game" and _navigation != null:
		if focused == _board_focus and not _evaluation.get("solved", false):
			_navigation.select_cell(_navigation.selected_cell)
		elif focused in _active_game_buttons():
			_navigation.set_button_count(_active_game_buttons().size())
			_navigation.select_button(_active_game_buttons().find(focused))
	_refresh_selection()


## Updates the single cell marker from input source and current focus.
func _refresh_selection() -> void:
	var show_selection: bool = _navigation != null and not _evaluation.get("solved", false) and not _pointer_selection_active and get_viewport().gui_get_focus_owner() == _board_focus
	for index in range(_cells.size()):
		var cell = _cells[index]
		cell.keyboard_selected = show_selection and index == _navigation.selected_cell
		cell.pointer_selection_active = _pointer_selection_active
		cell.queue_redraw()


## Synchronizes the remembered cell and marker when pointer hover enters a playable cell.
func _on_cell_pointer_entered(index: int) -> void:
	if _pointer_hidden:
		return
	_pointer_selection_active = true
	if _navigation != null and not _evaluation.get("solved", false):
		_navigation.select_cell(index)
	_refresh_selection()


## Restores focus-based selection when the pointer leaves board cells.
func _on_cell_pointer_exited(_index: int) -> void:
	_pointer_selection_active = false
	_refresh_selection()


## Selects a clicked cell and gives the board focus while the puzzle is active.
func _select_mouse_cell(index: int) -> void:
	_pointer_selection_active = true
	if not _evaluation.get("solved", false):
		_navigation.select_cell(index)
		_board_focus.grab_focus()
		_refresh_selection()


## Applies the primary mouse action to a cell.
func _on_mouse_primary(index: int) -> void:
	_select_mouse_cell(index)
	_on_primary_click(index)


## Applies the annotation mouse action to a cell.
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


## Toggles an X annotation and refreshes state and rule feedback.
func _on_secondary_click(index: int) -> void:
	if _evaluation.get("solved", false):
		return
	var previous_violations := _violation_count()
	if _state.toggle_annotation(index):
		_play(_action_audio, MARK_SOUND)
		_refresh_board()
		_play_rule_feedback(previous_violations)


## Refreshes cell states and opens the victory panel once when the puzzle is solved.
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
	if _status != null:
		_status.text = "%d / %d cells lit" % [_evaluation.lit_count, _evaluation.playable_count]
	if _evaluation.solved and not was_solved:
		_show_victory()
	elif not _evaluation.solved and was_solved:
		_clear_victory()
	_refresh_selection()


## Creates a centered victory panel over a lightly dimmed completed board.
func _show_victory() -> void:
	_clear_overlay()
	_pointer_selection_active = false
	_board_focus.focus_mode = Control.FOCUS_NONE
	for button in _game_buttons:
		button.focus_mode = Control.FOCUS_NONE
	var dimmer := ColorRect.new()
	dimmer.name = "VictoryDimmer"
	dimmer.color = Color(0.08, 0.12, 0.18, 0.48)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay_layer.add_child(dimmer)
	var celebration := Sparkles.new()
	celebration.name = "VictorySparkles"
	celebration.sparkle_texture = SPARKLE_TEXTURE
	_overlay_layer.add_child(celebration)
	var center := CenterContainer.new()
	center.name = "VictoryPanelCenter"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay_layer.add_child(center)
	var panel := PanelContainer.new()
	panel.name = "VictoryPanel"
	panel.custom_minimum_size = Vector2(440, 200)
	panel.add_theme_stylebox_override("panel", Visuals.victory_surface())
	center.add_child(panel)
	panel.modulate.a = 0.0
	var reveal := create_tween()
	reveal.tween_property(panel, "modulate:a", 1.0, 0.22)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)
	_label(content, "Puzzle solved!", 34)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", BUTTON_GAP)
	content.add_child(actions)
	if _random_mode:
		_victory_buttons.append(_button(actions, "NewRandomLevel", "New Random Level", _start_random_level))
	else:
		var difficulty_id: String = _current_configuration.get("difficulty_id", _selected_difficulty)
		var next_configuration = Levels.get_next_configuration(difficulty_id, int(_current_configuration.get("level_number", 1)))
		if next_configuration != null:
			_victory_buttons.append(_button(actions, "NextLevel", "Next Level", _open_numbered_level.bind(next_configuration.difficulty_id, next_configuration.level_number)))
	_victory_buttons.append(_button(actions, "Restart", "Restart", _restart))
	_victory_buttons.append(_button(actions, "ExitToMenu", "Exit to Menu", _show_menu))
	_navigation.set_button_count(_victory_buttons.size())
	_navigation.select_button(0)
	_focus_if_current.call_deferred(_victory_buttons[0])


## Removes the victory layer and restores the gameplay board/button row.
func _clear_victory() -> void:
	_clear_overlay()
	_board_focus.focus_mode = Control.FOCUS_ALL
	for button in _game_buttons:
		button.focus_mode = Control.FOCUS_ALL
	_navigation.set_button_count(_game_buttons.size())
	_navigation.select_cell(_navigation.selected_cell)
	_focus_if_current.call_deferred(_board_focus)


## Frees all overlay controls before changing or resetting a screen.
func _clear_overlay() -> void:
	if _overlay_layer == null:
		return
	for child in _overlay_layer.get_children():
		_overlay_layer.remove_child(child)
		child.queue_free()
	_victory_buttons.clear()


## Returns the number of current bulb conflicts and exceeded numbered clues.
func _violation_count() -> int:
	return int(_evaluation.get("conflicting_bulbs", 0)) + int(_evaluation.get("exceeded_clues", 0))


## Plays victory audio or a warning when the violation count increases.
func _play_rule_feedback(previous_violations: int) -> void:
	if _evaluation.get("solved", false):
		_play(_feedback_audio, VICTORY_SOUND)
	elif _violation_count() > previous_violations:
		_play(_feedback_audio, WARNING_SOUND)


## Restarts the same board and current random seed, clearing all player moves.
func _restart() -> void:
	_gamepad.reset()
	_direction_repeat.reset()
	_cell_action_guard.reset()
	_state.reset()
	_feedback_audio.stop()
	if not _victory_buttons.is_empty():
		_clear_victory()
	_evaluation = {}
	_refresh_board()
	_navigation.select_cell(_navigation.selected_cell)
	_navigation.set_button_count(_game_buttons.size())
	_board_focus.grab_focus()
	_sync_game_focus(_game_buttons)


## Returns the display name for a registered difficulty ID.
func _difficulty_name(difficulty: String) -> String:
	for preset in Levels.get_difficulties():
		if preset.id == difficulty:
			return preset.name
	return difficulty.capitalize()


## Plays an audio stream on its assigned player.
func _play(player: AudioStreamPlayer, stream: AudioStream) -> void:
	player.stream = stream
	player.play()


## Updates the mute shortcut's visibility after a screen transition.
func _set_mute_visibility(visible_on_menu: bool) -> void:
	if _mute_shortcut != null:
		_mute_shortcut.visible = visible_on_menu


## Closes the running game.
func _quit() -> void:
	get_tree().quit()
