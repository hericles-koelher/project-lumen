extends SceneTree
## Checks menu, tutorial, level-session, and victory flows in an isolated scene instance.

## Main-game scene used for the interface integration checks.
const MainScene = preload("res://src/presentation/main.tscn")
## Preference service used to prepare isolated first-run and returning-player states.
const Preferences = preload("res://src/presentation/player_preferences.gd")
## Fixed level catalog used to reproduce test solutions independently from presentation.
const Levels = preload("res://src/levels/prototype_levels.gd")
## Constructive generator used to obtain valid solutions for integration fixtures.
const Generator = preload("res://src/generation/board_generator.gd")

## Number of assertions evaluated by this check runner.
var _checks := 0
## Number of failed assertions in this check runner.
var _failures := 0


## Starts asynchronous flow checks after the scene tree has initialized.
func _init() -> void:
	call_deferred("_run")


## Runs the flow checks and exits with a failure status when needed.
func _run() -> void:
	if not _test_user_data_isolated():
		quit(1)
		return
	root.size = Vector2i(1152, 800)
	if DisplayServer.get_name() != "headless":
		root.set_flag(Window.FLAG_NO_FOCUS, true)
		root.position = Vector2i(-10000, -10000)
	var preferences := Preferences.new()
	preferences.tutorial_seen = true
	preferences.save_preferences()
	var game := MainScene.instantiate()
	root.add_child(game)
	# Keep physical controller input in the player's live game, outside this synthetic runner.
	game.set_process_input(false)
	await process_frame
	_expect(game.get("_page_name") == "Menu", "Returning players must start at the main menu.")
	var start_button: Button = game.get_node("Screen/Menu/Content/StartGame")
	var quit_button: Button = game.get_node("Screen/Menu/Content/Quit")
	_expect(start_button.size.x > quit_button.size.x + 20.0, "Button width must follow label length rather than a shared full-width column.")
	_expect(is_equal_approx(start_button.size.x, start_button.get_combined_minimum_size().x), "A menu button must use its text-and-padding minimum width.")
	var mute_shortcut: Control = game.get("_mute_shortcut")
	var mute_rect := mute_shortcut.get_global_rect()
	_expect(mute_rect.position.x >= 0.0 and mute_rect.end.x <= get_root().size.x, "The corner mute shortcut must stay inside the viewport.")
	await _test_window_coverage(game)
	await _test_audio_preferences(game)
	await _test_settings_back_flow(game)
	await _test_settings_display_mode(game)
	await _test_tutorial_focus(game)
	await _test_keyboard_focus_recovery(game)
	await _test_menu_keyboard_focus_recovery(game)
	await _test_pointer_visibility(game)
	await _test_controller_action_guard(game)
	await _test_wall_selection(game)
	await _test_numbered_progression(game)
	await _test_random_session(game)
	game.call("_show_menu")
	await process_frame
	_expect(game.get("_state") == null and game.get("_current_configuration").is_empty(), "Returning to the main menu must discard the active session.")
	game.call("_set_pointer_hidden", true)
	await _dispose_game(game)
	_expect(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Closing the game scene must restore the free pointer.")
	await _test_first_launch_tutorial()
	print("Flow checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


## Records a failed check when the supplied condition is false.
func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


## Ensures the integration runner cannot access the player's real preferences.
func _test_user_data_isolated() -> bool:
	var data_root := OS.get_environment("XDG_DATA_HOME")
	var user_data_path := OS.get_user_data_dir()
	_expect(not data_root.is_empty() and user_data_path.begins_with(data_root), "Flow checks must use a temporary XDG data directory.")
	_expect(ProjectSettings.globalize_path(Preferences.SETTINGS_PATH).begins_with(user_data_path), "Flow checks must only access temporary user data.")
	return _failures == 0


## Checks wide window ratios expand the viewport and keep the background edge to edge.
func _test_window_coverage(game: Node) -> void:
	var backdrop: TextureRect = game.get_node("Backdrop")
	for resolution in [Vector2i(1920, 1080), Vector2i(2560, 1080)]:
		root.size = resolution
		await process_frame
		await process_frame
		var viewport_size := root.get_visible_rect().size
		var physical_aspect := Vector2(resolution).aspect()
		_expect(absf(viewport_size.aspect() - physical_aspect) < 0.003, "The expanded viewport must match the window aspect without pillarboxing.")
		_expect(backdrop.size.is_equal_approx(viewport_size), "The background must cover the expanded viewport.")
	root.size = Vector2i(1152, 800)
	await process_frame
	await process_frame


## Checks zero music volume and global mute preserve separate preference values.
func _test_audio_preferences(game: Node) -> void:
	game.call("_show_settings")
	await process_frame
	game.call("_on_music_slider_changed", 0.0)
	var music: AudioStreamPlayer = game.get("_music")
	var preferences = game.get("_preferences")
	_expect(is_zero_approx(music.volume_linear), "A zero music slider value must silence the music player.")
	_expect(is_zero_approx(preferences.music_volume), "The zero music level must be stored without being replaced by the mute toggle.")
	game.call("_set_global_mute", true, false)
	var master_bus := AudioServer.get_bus_index("Master")
	_expect(AudioServer.is_bus_mute(master_bus), "Global mute must mute the master audio bus.")
	_expect(is_zero_approx(preferences.music_volume), "Global mute must preserve the music volume preference.")
	game.call("_set_global_mute", false, false)
	_expect(not AudioServer.is_bus_mute(master_bus), "Unmuting must restore the master audio bus.")
	game.call("_set_music_volume", Preferences.DEFAULT_MUSIC_VOLUME * 100.0, false)


## Checks persistent Settings surfaces, tab focus, overflow, and direct menu exits.
func _test_settings_back_flow(game: Node) -> void:
	game.call("_show_settings")
	await process_frame
	await create_timer(0.18).timeout
	_expect(root.gui_get_focus_owner() == game.find_child("AudioDisplayTab", true, false), "Settings must initially focus the Audio & Display tab.")
	var shell: Control = game.find_child("SettingsCard", true, false)
	var header: Control = game.find_child("SettingsTabNavigation", true, false)
	var original_frame: Control = game.find_child("SettingsViewportFrame", true, false)
	var original_scroll: Control = game.find_child("SettingsContentScroll", true, false)
	var original_back: Button = game.find_child("SettingsBack", true, false)
	var original_audio_tab: Button = game.find_child("AudioDisplayTab", true, false)
	var audio_tab_rect: Rect2 = game.find_child("AudioDisplayTab", true, false).get_global_rect()
	var audio_frame_rect: Rect2 = game.find_child("SettingsViewportFrame", true, false).get_global_rect()
	var audio_back_rect: Rect2 = game.find_child("SettingsBack", true, false).get_global_rect()
	var controls_tab: Button = game.find_child("ControlsTab", true, false)
	controls_tab.emit_signal("pressed")
	_expect(is_equal_approx(game.get("_screen").modulate.a, 1.0), "Switching tabs must not fade or flash the Settings shell.")
	await process_frame
	await process_frame
	_expect(root.gui_get_focus_owner() == game.find_child("ControlsTab", true, false), "Opening Controls must focus the active Controls tab.")
	_expect(game.find_child("SettingsCard", true, false) == shell and game.find_child("SettingsTabNavigation", true, false) == header, "Switching tabs must retain the existing card and header instances.")
	_expect(game.find_child("SettingsViewportFrame", true, false) == original_frame and game.find_child("SettingsContentScroll", true, false) == original_scroll, "Switching tabs must retain the content frame and scroll container.")
	_expect(game.find_child("SettingsBack", true, false) == original_back and game.find_child("AudioDisplayTab", true, false) == original_audio_tab, "Switching tabs must retain the footer and tab buttons.")
	_expect(controls_tab.button_pressed and not original_audio_tab.button_pressed, "The selected-tab highlight must update in place.")
	_expect(game.find_child("AudioDisplayTab", true, false).get_global_rect().is_equal_approx(audio_tab_rect), "Changing tabs must not move the Settings header.")
	var frame: Control = game.find_child("SettingsViewportFrame", true, false)
	_expect(frame.get_global_rect().is_equal_approx(audio_frame_rect), "Both Settings tabs must share a fixed content viewport.")
	var back: Button = game.find_child("SettingsBack", true, false)
	_expect(back.get_global_rect().is_equal_approx(audio_back_rect), "Changing tabs must not move the Back footer.")
	var previous_arrow: Control = game.find_child("PreviousSettingsTab", true, false)
	var next_arrow: Control = game.find_child("NextSettingsTab", true, false)
	_expect(absf(previous_arrow.get_parent().get_global_rect().position.x - audio_frame_rect.position.x) <= 1.0, "The previous arrow/hint cluster must align inside the inner card's left edge.")
	_expect(absf(next_arrow.get_parent().get_global_rect().end.x - audio_frame_rect.end.x) <= 1.0, "The next arrow/hint cluster must align inside the inner card's right edge.")
	var overflow := Control.new()
	overflow.custom_minimum_size.y = 900
	game.find_child("SettingsContent", true, false).add_child(overflow)
	await process_frame
	await process_frame
	var scroll: ScrollContainer = game.find_child("SettingsContentScroll", true, false)
	_expect(scroll.get_v_scroll_bar().max_value > scroll.get_v_scroll_bar().page, "Long Settings content must overflow vertically inside its viewport.")
	scroll.scroll_vertical = 200
	await process_frame
	_expect(scroll.scroll_vertical > 0, "Overflowing Settings content must be scrollable.")
	_expect(frame.get_global_rect().is_equal_approx(audio_frame_rect) and back.get_global_rect().is_equal_approx(audio_back_rect), "Scrolling must leave the content frame and footer fixed.")
	_expect(game.find_child("AudioDisplayTab", true, false).get_global_rect().is_equal_approx(audio_tab_rect), "Scrolling must leave the tab header fixed.")
	controls_tab.emit_signal("pressed")
	await process_frame
	_expect(is_instance_valid(overflow) and scroll.scroll_vertical == 200, "Selecting the active tab again must preserve its existing content and scroll.")
	_expect(controls_tab.button_pressed, "Selecting the active tab again must keep its selected highlight.")
	previous_arrow.emit_signal("pressed")
	await process_frame
	_expect(game.get("_settings_active_tab") == "AudioDisplay", "The standalone arrow must switch Settings tabs.")
	_expect(game.find_child("SettingsCard", true, false) == shell and is_equal_approx(game.get("_screen").modulate.a, 1.0), "Arrow tab switches must retain the opaque Settings shell.")
	_expect(scroll.scroll_vertical == 0, "Switching to different tab content must open it at the top.")
	var focus_targets: Array = game.get("_menu_controls")
	var valid_targets := true
	var seen := {}
	for control in focus_targets:
		if not is_instance_valid(control) or not control.is_visible_in_tree():
			valid_targets = false
			continue
		var identity: int = control.get_instance_id()
		if seen.has(identity):
			valid_targets = false
		seen[identity] = true
	_expect(valid_targets, "Tab changes must leave only current, unique controls in directional navigation.")
	_expect(root.gui_get_focus_owner() == original_audio_tab, "Returning to Audio & Display must focus its existing tab button.")
	for tab in ["AudioDisplay", "Controls"]:
		for method in ["button", "keyboard", "gamepad"]:
			game.call("_build_settings_page", tab)
			await process_frame
			if method == "button":
				game.find_child("SettingsBack", true, false).emit_signal("pressed")
			elif method == "keyboard":
				var escape := InputEventKey.new()
				escape.keycode = KEY_ESCAPE
				escape.physical_keycode = KEY_ESCAPE
				escape.pressed = true
				game.call("_dispatch_action", escape, false)
			else:
				var back_event := InputEventJoypadButton.new()
				back_event.button_index = JOY_BUTTON_B
				back_event.pressed = true
				game.call("_dispatch_action", back_event, false)
			await process_frame
			_expect(game.get("_page_name") == "Menu", "%s Back from %s must exit directly to the main menu." % [method, tab])


## Checks both display-mode changes preserve the page, focused button, and scroll.
func _test_settings_display_mode(game: Node) -> void:
	# A graphical fullscreen toggle would move the offscreen runner onto the player's desktop.
	if DisplayServer.get_name() != "headless":
		return
	game.call("_show_settings")
	await process_frame
	await process_frame
	var mode_button: Button = game.find_child("DisplayMode", true, false)
	var card: Control = game.find_child("SettingsCard", true, false)
	var scroll: ScrollContainer = game.find_child("SettingsContentScroll", true, false)
	var overflow := Control.new()
	overflow.custom_minimum_size.y = 900
	game.find_child("SettingsContent", true, false).add_child(overflow)
	await process_frame
	await process_frame
	scroll.scroll_vertical = 200
	mode_button.grab_focus()
	await process_frame
	var saved_scroll := scroll.scroll_vertical
	_expect(saved_scroll > 0, "The display-mode fixture must have a nonzero scroll position to preserve.")
	var preferences = game.get("_preferences")
	for iteration in range(2):
		var previous_mode: bool = preferences.fullscreen
		mode_button.emit_signal("pressed")
		await process_frame
		await process_frame
		var same_page := is_instance_valid(card) and is_instance_valid(mode_button) and is_instance_valid(scroll)
		_expect(same_page, "Changing display mode must update the existing Settings page rather than rebuild it.")
		if not same_page:
			return
		_expect(preferences.fullscreen != previous_mode, "Each display-mode activation must toggle the saved mode.")
		_expect(mode_button.text == ("Fullscreen" if preferences.fullscreen else "Windowed"), "The existing display-mode button must show the newly selected mode.")
		_expect(root.gui_get_focus_owner() == mode_button, "Changing display mode must preserve focus on its button.")
		_expect(scroll.scroll_vertical == saved_scroll, "Changing display mode must preserve the content scroll position.")
		var reloaded := Preferences.new()
		reloaded.load_preferences()
		_expect(reloaded.fullscreen == preferences.fullscreen, "Changing display mode must persist the new preference.")


## Checks tutorial pages reuse one fixed card, omit Previous, and focus Next or Done.
func _test_tutorial_focus(game: Node) -> void:
	game.call("_start_tutorial", false)
	await process_frame
	var page_count: int = game.TUTORIAL_PAGES.size()
	var card: Control = game.find_child("TutorialCard", true, false)
	var original_indicator: Control = game.find_child("TutorialPageIndicator", true, false)
	var original_title: Control = game.find_child("TutorialPageTitle", true, false)
	var original_description: Control = game.find_child("TutorialPageDescription", true, false)
	var original_slot: Control = game.find_child("TutorialDiagramSlot", true, false)
	var original_next: Control = game.find_child("NextPage", true, false)
	var original_skip: Control = game.find_child("SkipTutorial", true, false)
	for page in range(page_count):
		await process_frame
		await process_frame
		var next_button: Button = game.find_child("NextPage", true, false)
		var skip_button: Button = game.find_child("SkipTutorial", true, false)
		var current_card: Control = game.find_child("TutorialCard", true, false)
		var current_diagram: Control = game.find_child("TutorialBoard", true, false)
		_expect(current_card == card, "Tutorial steps must retain the same card instance.")
		_expect(game.find_child("TutorialPageIndicator", true, false) == original_indicator, "Tutorial steps must update the existing page indicator.")
		_expect(game.find_child("TutorialPageTitle", true, false) == original_title, "Tutorial steps must update the existing title.")
		_expect(game.find_child("TutorialPageDescription", true, false) == original_description, "Tutorial steps must update the existing description.")
		_expect(game.find_child("TutorialDiagramSlot", true, false) == original_slot, "Tutorial steps must retain the same diagram slot.")
		_expect(next_button == original_next and skip_button == original_skip, "Tutorial navigation buttons must remain in place between steps.")
		_expect(is_equal_approx(current_card.custom_minimum_size.y, game.TUTORIAL_CARD_HEIGHT), "Tutorial card must use the fixed height sized for its longest step.")
		_expect(is_equal_approx(current_card.custom_minimum_size.y, game.TUTORIAL_CARD_HEIGHT), "Every tutorial step must have the same card height.")
		_expect(current_diagram.size.y <= game.TUTORIAL_DIAGRAM_HEIGHT, "Each tutorial diagram must fit inside the shared fixed-height slot.")
		_expect(game.find_child("PreviousPage", true, false) == null, "The tutorial must not show a Previous button.")
		_expect(root.gui_get_focus_owner() == next_button, "Tutorial page %d must focus Next or Done." % (page + 1))
		if page < page_count - 1:
			next_button.emit_signal("pressed")
			await process_frame
	game.find_child("NextPage", true, false).emit_signal("pressed")
	await process_frame
	_expect(game.get("_page_name") == "Menu", "Done must return to the menu after navigating the tutorial.")
	game.call("_start_tutorial", false)
	await process_frame
	_expect(game.get("_tutorial_page") == 0, "Reopening the tutorial from the menu must always start at its first step.")
	_expect(game.find_child("TutorialCard", true, false) != card, "Reopening the tutorial after leaving it may create a new card shell.")
	_expect(root.gui_get_focus_owner() == game.find_child("NextPage", true, false), "Reopening the tutorial must focus Next on its first step.")
	game.call("_show_menu")
	await process_frame


## Checks real keyboard events recover a lost board focus and still apply their action.
func _test_keyboard_focus_recovery(game: Node) -> void:
	game.call("_open_numbered_level", "easy", 1)
	await process_frame
	game.set_process_input(true)
	var board: Control = game.get("_board_focus")
	board.release_focus()
	var right := InputEventKey.new()
	right.physical_keycode = KEY_RIGHT
	right.pressed = true
	Input.parse_input_event(right)
	await process_frame
	_expect(root.gui_get_focus_owner() == board and game.get("_navigation").selected_cell == 1, "A directional key must restore lost board focus and move in the same press.")
	board.release_focus()
	var space := InputEventKey.new()
	space.physical_keycode = KEY_SPACE
	space.pressed = true
	Input.parse_input_event(space)
	await process_frame
	_expect(root.gui_get_focus_owner() == board and game.get("_state").bulbs[1], "Space must restore lost board focus and toggle the remembered cell in the same press.")
	right.pressed = false
	space.pressed = false
	Input.parse_input_event(right)
	Input.parse_input_event(space)
	game.set_process_input(false)
	game.call("_show_menu")
	await process_frame


## Checks keyboard activation recovers focus across menus and the active Settings tab.
func _test_menu_keyboard_focus_recovery(game: Node) -> void:
	for screen in ["Menu", "Controls", "Tutorial"]:
		if screen == "Menu":
			game.call("_show_menu")
		elif screen == "Controls":
			game.call("_show_controls")
		else:
			game.call("_start_tutorial", false)
		await process_frame
		await process_frame
		var focused := root.gui_get_focus_owner()
		focused.release_focus()
		game.set_process_input(true)
		var key := InputEventKey.new()
		key.physical_keycode = KEY_ENTER
		key.pressed = true
		Input.parse_input_event(key)
		await process_frame
		if screen == "Menu":
			_expect(game.get("_page_name") == "Difficulty", "Enter must recover missing main-menu focus and open difficulty selection.")
		elif screen == "Controls":
			_expect(game.get("_settings_active_tab") == "Controls" and root.gui_get_focus_owner() == focused, "Keyboard recovery must preserve the active Settings tab.")
		else:
			_expect(game.get("_tutorial_page") == 1, "Enter must recover missing tutorial focus and advance its current step.")
		key.pressed = false
		Input.parse_input_event(key)
		game.set_process_input(false)
	game.call("_show_menu")
	await process_frame


## Reads native visibility with a display; headless checks only the visibility policy.
## The headless display backend always reports a visible OS pointer.
func _pointer_is_hidden(game: Node) -> bool:
	if DisplayServer.get_name() == "headless":
		return game.get("_pointer_hidden")
	return Input.mouse_mode == Input.MOUSE_MODE_HIDDEN


## Checks idle hiding, input-method switches, drift, hover handoff, and focus restoration.
func _test_pointer_visibility(game: Node) -> void:
	var initial_focus := root.gui_get_focus_owner()
	game.call("_set_pointer_hidden", false)
	game.call("_advance_pointer_idle", 2.9)
	_expect(not _pointer_is_hidden(game), "The pointer must remain visible before the idle timeout.")
	var motion := InputEventMouseMotion.new()
	game.call("_handle_pointer_activity", motion)
	game.call("_advance_pointer_idle", 0.2)
	_expect(_pointer_is_hidden(game), "Zero-distance motion must not prevent idle hiding.")
	motion.relative = Vector2(1, 0)
	game.call("_handle_pointer_activity", motion)
	_expect(not _pointer_is_hidden(game), "Real mouse movement must reveal the pointer.")
	_expect(game.theme.get_stylebox("focus", "Button") is StyleBoxEmpty, "Mouse activity must hide the keyboard focus halo, including before the first keyboard press.")
	_expect(root.gui_get_focus_owner() == initial_focus, "Mouse highlighting must preserve the remembered keyboard focus.")
	game.call("_advance_pointer_idle", 2.9)
	_expect(not _pointer_is_hidden(game), "Mouse movement must restart the idle timeout.")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_TAB
	key.pressed = true
	game.call("_handle_pointer_activity", key)
	_expect(_pointer_is_hidden(game), "A keyboard press must hide the pointer immediately.")
	_expect(not game.theme.get_stylebox("focus", "Button") is StyleBoxEmpty, "Keyboard input must restore its focus halo after mouse navigation.")
	_expect(game.theme.get_stylebox("hover", "Button") == game.theme.get_stylebox("normal", "Button"), "Keyboard input must suppress the stationary mouse hover halo.")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	game.call("_handle_pointer_activity", click)
	_expect(not _pointer_is_hidden(game), "A mouse click must reveal the pointer without requiring motion.")
	_expect(game.theme.get_stylebox("focus", "Button") is StyleBoxEmpty, "Returning to mouse input must hide keyboard focus highlighting again.")
	key.pressed = false
	game.call("_handle_pointer_activity", key)
	_expect(not _pointer_is_hidden(game), "A key release must not hide a pointer restored by the mouse.")
	var stick := InputEventJoypadMotion.new()
	stick.axis = JOY_AXIS_LEFT_X
	stick.axis_value = 0.05
	game.call("_handle_pointer_activity", stick)
	_expect(not _pointer_is_hidden(game), "Neutral stick drift must not hide the mouse pointer.")
	stick.axis_value = 0.8
	game.call("_handle_pointer_activity", stick)
	_expect(_pointer_is_hidden(game), "Intentional stick input must hide the pointer.")
	game.call("_handle_pointer_activity", motion)
	var button := InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_A
	button.pressed = true
	game.call("_handle_pointer_activity", button)
	_expect(_pointer_is_hidden(game), "A controller press must hide the pointer.")
	game.call("_notification", Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_expect(not _pointer_is_hidden(game), "Losing application focus must restore the free pointer.")
	game.call("_advance_pointer_idle", 2.9)
	_expect(not _pointer_is_hidden(game), "Focus loss must reset the mouse idle timeout.")
	game.call("_open_numbered_level", "easy", 1)
	await process_frame
	var cells: Array = game.get("_cells")
	var playable: Control
	for cell in cells:
		if not cell.wall:
			playable = cell
			break
	motion.position = playable.get_global_rect().get_center()
	game.call("_handle_pointer_activity", motion)
	_expect(game.get("_pointer_selection_active"), "Mouse movement over a playable cell must enable its pointer marker.")
	key.pressed = true
	game.call("_handle_pointer_activity", key)
	_expect(not game.get("_pointer_selection_active"), "Hiding the pointer must release its cell marker.")
	game.call("_on_cell_pointer_entered", playable.cell_index)
	_expect(not game.get("_pointer_selection_active"), "Hidden-pointer enter events must not steal cell selection.")
	game.call("_handle_pointer_activity", motion)
	_expect(game.get("_pointer_selection_active"), "Movement inside the same cell must restore pointer selection without an enter event.")
	game.call("_show_menu")
	game.call("_set_pointer_hidden", false)
	await process_frame


## Checks controller bounce suppression while other cells, actions, and input methods remain immediate.
func _test_controller_action_guard(game: Node) -> void:
	game.call("_open_numbered_level", "easy", 1)
	await process_frame
	var state = game.get("_state")
	var navigation = game.get("_navigation")
	var playable: Array[int] = []
	for index in range(state.board.cell_count()):
		if state.board.is_playable(index):
			playable.append(index)
	navigation.select_cell(playable[0])
	game.call("_sync_game_focus", game.get("_game_buttons"))
	var bulb := InputEventJoypadButton.new()
	bulb.button_index = JOY_BUTTON_A
	bulb.pressed = true
	game.call("_dispatch_action", bulb, false)
	game.call("_dispatch_action", bulb, false)
	_expect(state.bulbs[playable[0]], "Two immediate controller bulb presses must place only one bulb.")
	var note := InputEventJoypadButton.new()
	note.button_index = JOY_BUTTON_X
	note.pressed = true
	game.call("_dispatch_action", note, false)
	_expect(state.annotations[playable[0]] and not state.bulbs[playable[0]], "A different controller action on the same cell must remain immediate.")
	game.call("_dispatch_action", note, false)
	_expect(state.annotations[playable[0]], "Two immediate controller note presses must leave one note.")
	navigation.select_cell(playable[1])
	game.call("_dispatch_action", bulb, false)
	_expect(state.bulbs[playable[1]], "The same controller action on another cell must remain immediate.")
	navigation.select_cell(playable[0])
	var keyboard := InputEventKey.new()
	keyboard.keycode = KEY_SPACE
	keyboard.physical_keycode = KEY_SPACE
	keyboard.pressed = true
	game.call("_dispatch_action", keyboard, false)
	game.call("_dispatch_action", keyboard, false)
	_expect(not state.bulbs[playable[0]], "Two deliberate keyboard presses must remain unaffected by the controller guard.")
	game.call("_on_mouse_primary", playable[0])
	game.call("_on_mouse_primary", playable[0])
	_expect(not state.bulbs[playable[0]], "Two deliberate mouse clicks must remain unaffected by the controller guard.")
	game.call("_restart")
	game.call("_dispatch_action", bulb, false)
	_expect(state.bulbs[playable[0]], "Restart must clear previous controller action suppression.")
	await process_frame


## Checks a selected wall keeps its marker but rejects the shared gameplay actions.
func _test_wall_selection(game: Node) -> void:
	game.call("_open_numbered_level", "easy", 1)
	await process_frame
	var state = game.get("_state")
	var navigation = game.get("_navigation")
	var wall_index: int = state.board.wall_indices()[0]
	if wall_index % state.board.width > 0:
		navigation.select_cell(wall_index - 1)
		game.call("_sync_game_focus", game.get("_game_buttons"))
		game.call("_navigate", Vector2i.RIGHT)
	else:
		navigation.select_cell(wall_index + 1)
		game.call("_sync_game_focus", game.get("_game_buttons"))
		game.call("_navigate", Vector2i.LEFT)
	_expect(navigation.selected_cell == wall_index, "Directional navigation must land on the wall rather than jumping over it.")
	var cells: Array = game.get("_cells")
	_expect(cells[wall_index].keyboard_selected, "A selected wall must display the shared selection marker.")
	var bulbs_before: PackedByteArray = state.bulbs.duplicate()
	var marks_before: PackedByteArray = state.annotations.duplicate()
	game.call("_on_primary_click", wall_index)
	game.call("_on_secondary_click", wall_index)
	_expect(state.bulbs == bulbs_before, "The bulb handler must not alter a selected wall or other bulb placements.")
	_expect(state.annotations == marks_before, "The annotation handler must not alter a selected wall or other notes.")


## Checks victory actions at numbered-level boundaries and across difficulties.
func _test_numbered_progression(game: Node) -> void:
	game.call("_open_numbered_level", "easy", 10)
	await process_frame
	_solve_numbered_level(game, "easy", 10)
	await process_frame
	_expect(game.get("_evaluation").solved, "A valid solution must open victory through the normal rule-evaluation path.")
	var victory_buttons: Array = game.get("_victory_buttons")
	_expect(_button_names(victory_buttons) == ["NextLevel", "Restart", "ExitToMenu"], "Numbered levels must offer progression, restart, and menu exit.")
	var game_buttons: Array = game.get("_game_buttons")
	for button in game_buttons:
		_expect(button.focus_mode == Control.FOCUS_NONE, "Underlying gameplay buttons must not be focusable behind the victory panel.")
	var celebration: Control = game.get_node("OverlayLayer/VictorySparkles")
	_expect(celebration.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Victory sparkles must not intercept input.")
	await create_timer(1.75).timeout
	_expect(not is_instance_valid(celebration) and is_instance_valid(victory_buttons[0]), "The finite sparkle burst must end while victory actions remain available.")
	victory_buttons[0].emit_signal("pressed")
	await process_frame
	_expect(game.get("_page_name") == "Game", "Next Level must open the next numbered puzzle.")
	_expect(game.get("_current_configuration").difficulty_id == "medium", "Easy Level 10 must advance using the next stable difficulty ID.")
	_expect(game.get("_current_configuration").level_number == 1, "Cross-difficulty progression must start at Level 1.")
	game.call("_open_numbered_level", "hard", 10)
	await process_frame
	_solve_numbered_level(game, "hard", 10)
	await process_frame
	_expect(game.get("_evaluation").solved, "The final fixed level must reach victory through the normal rule-evaluation path.")
	victory_buttons = game.get("_victory_buttons")
	_expect(_button_names(victory_buttons) == ["Restart", "ExitToMenu"], "Hard Level 10 must not offer a next level.")
	game.call("_restart")
	await process_frame
	game_buttons = game.get("_game_buttons")
	for button in game_buttons:
		_expect(button.focus_mode == Control.FOCUS_ALL, "Restart must restore gameplay-button focus.")


## Applies a reproduced generator witness through the normal bulb action handler.
func _solve_numbered_level(game: Node, difficulty: String, level_number: int) -> void:
	var generated := Generator.generate(Levels.get_configuration(difficulty, level_number))
	for index in generated.solution:
		game.call("_on_primary_click", index)


## Checks random-level actions, restart identity, and session disposal.
func _test_random_session(game: Node) -> void:
	game.call("_start_random_level")
	await process_frame
	var configuration: Dictionary = game.get("_current_configuration").duplicate(true)
	var state = game.get("_state")
	var original_rows: PackedStringArray = state.board.to_rows()
	var playable_index := -1
	for index in range(state.board.cell_count()):
		if state.board.is_playable(index):
			playable_index = index
			break
	_expect(playable_index >= 0, "A random session must contain at least one playable cell.")
	game.call("_on_primary_click", playable_index)
	_expect(state.bulbs[playable_index], "The random-session fixture must accept a bulb action.")
	game.call("_restart")
	await process_frame
	_expect(not state.bulbs[playable_index], "Restart must clear random-session moves.")
	_expect(state.board.to_rows() == original_rows, "Restart must preserve the random-session board.")
	_expect(game.get("_current_configuration") == configuration, "Restart must preserve the random seed and configuration.")
	game.call("_show_victory")
	await process_frame
	var victory_buttons: Array = game.get("_victory_buttons")
	_expect(_button_names(victory_buttons) == ["NewRandomLevel", "Restart", "ExitToMenu"], "Random victory must offer a new random puzzle, restart, and menu exit.")


## Checks the first-launch tutorial appears and is recorded before it can be skipped.
func _test_first_launch_tutorial() -> void:
	var preferences := Preferences.new()
	preferences.tutorial_seen = false
	preferences.save_preferences()
	var game := MainScene.instantiate()
	root.add_child(game)
	# Keep physical controller input in the player's live game, outside this synthetic runner.
	game.set_process_input(false)
	await process_frame
	_expect(game.get("_page_name") == "Tutorial", "A fresh profile must open the tutorial automatically.")
	var reloaded := Preferences.new()
	reloaded.load_preferences()
	_expect(reloaded.tutorial_seen, "The tutorial-seen preference must be saved as soon as the tutorial opens.")
	var menu_controls: Array = game.get("_menu_controls")
	for control in menu_controls:
		if control.name == "SkipTutorial":
			control.emit_signal("pressed")
			break
	await process_frame
	_expect(game.get("_page_name") == "Menu", "Skip must return to the main menu.")
	await _dispose_game(game)


## Releases audio playback before freeing an isolated game scene.
func _dispose_game(game: Node) -> void:
	for property_name in ["_music", "_action_audio", "_feedback_audio"]:
		var player: AudioStreamPlayer = game.get(property_name)
		player.stop()
		player.stream = null
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout


## Returns the node names of a set of action buttons in display order.
func _button_names(buttons: Array) -> Array[String]:
	var names: Array[String] = []
	for button in buttons:
		names.append(button.name)
	return names
