extends SceneTree
## Checks native animation scheduling, live tuning, menu lifetime, and layer alignment.
## Runs in an isolated project/user-data directory, never in the player's live scene.

const MainScene = preload("res://src/presentation/main.tscn")
const Preferences = preload("res://src/presentation/player_preferences.gd")
const SOURCE_EXTENT := Vector2(1586, 992)
var _checks := 0
var _failures := 0


## Defers execution until the isolated scene tree is available.
func _init() -> void:
	call_deferred("_run")


## Exercises first visibility, menu returns, each motion, and responsive source transforms.
func _run() -> void:
	var data_root := OS.get_environment("XDG_DATA_HOME")
	_expect(not data_root.is_empty() and OS.get_user_data_dir().begins_with(data_root), "Animation checks must use isolated user data.")
	if _failures > 0:
		quit(1)
		return
	root.size = Vector2i(1152, 800)
	var preferences := Preferences.new()
	preferences.tutorial_seen = false
	preferences.save_preferences()
	var game := MainScene.instantiate()
	root.add_child(game)
	game.set_process_input(false)
	await process_frame
	_expect(game.get("_page_name") == "Tutorial", "The first-launch tutorial must still precede the menu.")
	_expect(not game.get("_title_startup_played"), "Tutorial must not consume the title animation.")
	game.call("_show_menu")
	await process_frame
	var title: Control = game.get_node("Screen/Menu/Content/Wordmark/StartupLight")
	_expect(not title.get("is_settled"), "The first visible title must play its startup sequence.")
	_expect(is_equal_approx(float(title.get("_settled_at")), 0.64), "Three approved blinks must settle the title at 640 ms.")
	_expect(is_equal_approx(float(title.get("_duration")), 0.89), "The halo fade must end at 890 ms after the startup delay.")
	await create_timer(1.2).timeout
	_expect(title.get("is_settled"), "The title startup must finish automatically.")
	_expect(is_equal_approx(float(title.get("current_halo_opacity")), 0.54), "The approved 270% halo must use 54% final alpha.")
	game.call("_show_settings")
	await process_frame
	game.call("_show_menu")
	await process_frame
	title = game.get_node("Screen/Menu/Content/Wordmark/StartupLight")
	_expect(title.get("is_settled"), "Returning to the menu must show the settled title without replay.")
	var backdrop = game.get_node("Backdrop")
	_expect(backdrop is TextureRect, "The animated background must preserve the existing TextureRect contract.")
	_expect(backdrop.texture.resource_path.ends_with("quiet_ink_room_animation_clean.png"), "The background must use the clean plate, avoiding duplicate cat and branches.")
	var snapshot: Dictionary = backdrop.call("get_motion_snapshot")
	_expect(snapshot.branches.size() == 5, "All five replacement outdoor branches must have controllers.")
	for index in range(1, snapshot.branches.size()):
		_expect(snapshot.branches[index].next != snapshot.branches[index - 1].next, "Branches must not share their initial breeze schedule.")
	backdrop.set_process(false)
	backdrop.set("_elapsed", 2.4)
	backdrop.set("_ear_start_seconds", -1.0)
	backdrop.set("_next_ear_seconds", 100.0)
	backdrop.call("_update_motion")
	snapshot = backdrop.call("get_motion_snapshot")
	_expect(is_equal_approx(float(snapshot.breath_lift), 0.0075), "Breathing peak must preserve the approved 75% amplitude.")
	backdrop.set("_elapsed", 2.5 + 0.62 * 0.16)
	backdrop.set("_ear_start_seconds", 2.5)
	backdrop.call("_update_motion")
	snapshot = backdrop.call("get_motion_snapshot")
	_expect(is_equal_approx(float(snapshot.ear_angle), 0.165), "Ear peak must preserve the approved 150% angle.")
	backdrop.set("_elapsed", 3.0)
	backdrop.call("_update_motion")
	snapshot = backdrop.call("get_motion_snapshot")
	_expect(is_equal_approx(float(snapshot.lamp_alpha), 0.22), "Room-lamp glow must preserve its approved six-second peak.")
	var branch_states: Array = backdrop.get("_foliage")
	for branch in branch_states:
		branch.start = 0.0
	backdrop.set("_elapsed", 1.0)
	backdrop.call("_update_motion")
	snapshot = backdrop.call("get_motion_snapshot")
	for branch in snapshot.branches:
		_expect(absf(float(branch.wind)) > 0.0 and absf(float(branch.flutter)) > 0.0, "Every outdoor branch must receive actual shader motion.")
	backdrop.set("_elapsed", 4.0)
	backdrop.call("_update_motion")
	snapshot = backdrop.call("get_motion_snapshot")
	for branch in snapshot.branches:
		_expect(is_zero_approx(float(branch.wind)) and is_zero_approx(float(branch.flutter)), "Each breeze must return exactly to its resting pose.")
		_expect(is_equal_approx(float(branch.next), 8.0), "Outdoor branches must rest for four seconds after the four-second breeze.")
	var tuning: Resource = backdrop.get("_tuning").duplicate()
	tuning.set("outdoor_leaves_breeze_duration_seconds", 2.0)
	tuning.set("outdoor_leaves_rest_seconds", 3.0)
	backdrop.call("configure", tuning)
	for branch in branch_states:
		branch.start = 0.0
	backdrop.set("_elapsed", 2.0)
	backdrop.call("_update_motion")
	snapshot = backdrop.call("get_motion_snapshot")
	for branch in snapshot.branches:
		_expect(branch.start < 0.0 and is_equal_approx(float(branch.next), 5.0), "Inspector duration and rest must both control the next breeze.")
	for property in ["cat_breathing_intensity_percent", "cat_ear_intensity_percent", "lamp_light_intensity_percent", "outdoor_leaves_intensity_percent"]:
		tuning.set(property, 0.0)
	backdrop.call("configure", tuning)
	backdrop.set("_elapsed", 2.4)
	backdrop.call("_update_motion")
	snapshot = backdrop.call("get_motion_snapshot")
	_expect(is_zero_approx(float(snapshot.breath_lift)) and is_zero_approx(float(snapshot.ear_angle)) and is_zero_approx(float(snapshot.lamp_alpha)), "Zero Inspector intensities must disable the added ambient effects.")
	for branch in snapshot.branches:
		_expect(is_zero_approx(float(branch.wind)) and is_zero_approx(float(branch.flutter)), "Zero foliage intensity must stop every branch.")
	var title_tuning: Resource = tuning.duplicate()
	title_tuning.set("title_lamp_halo_intensity_percent", 100.0)
	title.call("configure", title_tuning, false)
	await process_frame
	_expect(is_equal_approx(float(title.get("current_halo_opacity")), 0.20), "Settled title intensity must be Inspector-adjustable.")
	title_tuning.set("title_lamp_halo_intensity_percent", 200.0)
	await process_frame
	_expect(is_equal_approx(float(title.get("current_halo_opacity")), 0.40), "A live settled title must reflect changed tuning.")
	for resolution in [Vector2i(1152, 800), Vector2i(1920, 1080), Vector2i(2560, 1080)]:
		root.size = resolution
		await process_frame
		await process_frame
		var motion: Dictionary = backdrop.call("get_motion_snapshot")
		var cover: Vector2 = SOURCE_EXTENT * motion.cover_scale
		var offset: Vector2 = motion.cover_offset
		_expect(cover.x + 0.1 >= backdrop.size.x and cover.y + 0.1 >= backdrop.size.y, "Animated source layers must cover every tested aspect ratio.")
		_expect(offset.is_equal_approx((backdrop.size - cover) * 0.5), "All overlays must use the exact centered cover crop.")
		var fitted: Rect2 = title.call("_fitted_wordmark_rect")
		_expect(fitted.position.x >= -0.1 and fitted.end.x <= title.size.x + 0.1, "The title halo must track its fitted wordmark bounds.")
	for property_name in ["_music", "_action_audio", "_feedback_audio"]:
		var player: AudioStreamPlayer = game.get(property_name)
		player.stop()
		player.stream = null
	branch_states.clear()
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("Animation checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


## Records one observable animation-contract assertion.
func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)
