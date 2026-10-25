extends SceneTree
## Checks loading, saving, defaults, and invalid values in local player preferences.

## Preference service exercised by these checks.
const Preferences = preload("res://src/presentation/player_preferences.gd")

## Number of assertions evaluated by this check runner.
var _checks := 0
## Number of failed assertions in this check runner.
var _failures := 0


## Runs persistence checks and exits with a failure status when needed.
func _init() -> void:
	if not _test_user_data_isolated():
		quit(1)
		return
	_test_defaults_and_round_trip()
	_test_invalid_and_missing_values()
	_test_volume_clamping()
	_test_non_finite_volume()
	_test_tutorial_flag_is_saved_immediately()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Preferences.SETTINGS_PATH))
	print("Preference checks: %d passed, %d failed" % [_checks - _failures, _failures])
	quit(0 if _failures == 0 else 1)


## Ensures persistence checks cannot write outside the temporary XDG data directory.
func _test_user_data_isolated() -> bool:
	var data_root := OS.get_environment("XDG_DATA_HOME")
	var user_data_path := OS.get_user_data_dir()
	var settings_path := ProjectSettings.globalize_path(Preferences.SETTINGS_PATH)
	_expect(not data_root.is_empty() and user_data_path.begins_with(data_root), "Godot user data must be inside the temporary XDG data directory.")
	_expect(settings_path.begins_with(user_data_path), "Preference checks must only access the isolated project user-data folder.")
	return _failures == 0


## Records a failed check when the supplied condition is false.
func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(message)


## Checks default values and persistence of each supported preference.
func _test_defaults_and_round_trip() -> void:
	var preferences := Preferences.new()
	preferences.load_preferences()
	_expect(is_equal_approx(preferences.music_volume, Preferences.DEFAULT_MUSIC_VOLUME), "Missing settings must use the default music volume.")
	_expect(not preferences.is_muted and not preferences.fullscreen and not preferences.tutorial_seen, "Missing settings must default to unmuted, windowed, and unseen tutorial.")
	preferences.music_volume = 0.42
	preferences.is_muted = true
	preferences.fullscreen = true
	preferences.tutorial_seen = true
	_expect(preferences.save_preferences() == OK, "Valid preferences must save successfully.")
	var loaded := Preferences.new()
	loaded.load_preferences()
	_expect(is_equal_approx(loaded.music_volume, 0.42), "Music volume must survive save and reload.")
	_expect(loaded.is_muted and loaded.fullscreen and loaded.tutorial_seen, "Boolean preferences must survive save and reload.")


## Checks invalid and absent values fall back independently to defaults.
func _test_invalid_and_missing_values() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", "not-a-number")
	config.set_value("audio", "muted", 1)
	config.set_value("display", "fullscreen", true)
	config.set_value("tutorial", "seen", "yes")
	_expect(config.save(Preferences.SETTINGS_PATH) == OK, "Test settings with invalid values must save successfully.")
	var preferences := Preferences.new()
	preferences.music_volume = 0.9
	preferences.is_muted = true
	preferences.fullscreen = false
	preferences.tutorial_seen = true
	preferences.load_preferences()
	_expect(is_equal_approx(preferences.music_volume, Preferences.DEFAULT_MUSIC_VOLUME), "A non-numeric music value must use the default.")
	_expect(not preferences.is_muted, "A non-boolean mute value must use the default.")
	_expect(preferences.fullscreen, "A valid value must load even when another setting is invalid.")
	_expect(not preferences.tutorial_seen, "A non-boolean tutorial value must use the default.")


## Checks numeric music settings are safely clamped to the supported range.
func _test_volume_clamping() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", 1.5)
	_expect(config.save(Preferences.SETTINGS_PATH) == OK, "Test settings with an out-of-range volume must save successfully.")
	var preferences := Preferences.new()
	preferences.fullscreen = true
	preferences.tutorial_seen = true
	preferences.load_preferences()
	_expect(is_equal_approx(preferences.music_volume, 1.0), "Music volume above the range must clamp to full volume.")
	_expect(not preferences.fullscreen and not preferences.tutorial_seen, "Missing values must reset to defaults when preferences reload.")


## Checks NaN and infinity do not enter the active music preference.
func _test_non_finite_volume() -> void:
	for invalid_volume in [NAN, INF]:
		var config := ConfigFile.new()
		config.set_value("audio", "music_volume", invalid_volume)
		config.set_value("audio", "muted", true)
		_expect(config.save(Preferences.SETTINGS_PATH) == OK, "Non-finite test settings must save successfully.")
		var preferences := Preferences.new()
		preferences.load_preferences()
		_expect(is_equal_approx(preferences.music_volume, Preferences.DEFAULT_MUSIC_VOLUME), "Non-finite music volume must use the default.")
		_expect(preferences.is_muted, "Valid settings must still load when volume is non-finite.")


## Checks opening the tutorial persists its seen flag immediately.
func _test_tutorial_flag_is_saved_immediately() -> void:
	var preferences := Preferences.new()
	preferences.tutorial_seen = false
	preferences.save_preferences()
	preferences.mark_tutorial_seen()
	var reloaded := Preferences.new()
	reloaded.load_preferences()
	_expect(reloaded.tutorial_seen, "Opening the tutorial must persist its seen flag immediately.")
