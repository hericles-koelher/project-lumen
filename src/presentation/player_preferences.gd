extends RefCounted
## Loads and saves the small set of persistent player preferences.

## User-data path used for local settings.
const SETTINGS_PATH := "user://player_settings.cfg"
## Default linear music volume matching the prototype's current quiet mix.
const DEFAULT_MUSIC_VOLUME := 0.089125

## Current music volume between silence and full volume.
var music_volume := DEFAULT_MUSIC_VOLUME
## Whether the master output is muted.
var is_muted := false
## Whether the game should start in fullscreen mode.
var fullscreen := false
## Whether the first-launch tutorial has been opened.
var tutorial_seen := false


## Loads valid saved values while retaining defaults for missing or invalid entries.
func load_preferences() -> void:
	music_volume = DEFAULT_MUSIC_VOLUME
	is_muted = false
	fullscreen = false
	tutorial_seen = false
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	var saved_volume: Variant = config.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME)
	if typeof(saved_volume) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(saved_volume)):
		music_volume = clampf(float(saved_volume), 0.0, 1.0)
	var saved_mute: Variant = config.get_value("audio", "muted", false)
	if typeof(saved_mute) == TYPE_BOOL:
		is_muted = saved_mute
	var saved_fullscreen: Variant = config.get_value("display", "fullscreen", false)
	if typeof(saved_fullscreen) == TYPE_BOOL:
		fullscreen = saved_fullscreen
	var saved_tutorial: Variant = config.get_value("tutorial", "seen", false)
	if typeof(saved_tutorial) == TYPE_BOOL:
		tutorial_seen = saved_tutorial


## Saves all current preferences to the local user-data file.
func save_preferences() -> Error:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "muted", is_muted)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("tutorial", "seen", tutorial_seen)
	return config.save(SETTINGS_PATH)


## Marks the tutorial as seen as soon as it is opened and persists the flag.
func mark_tutorial_seen() -> void:
	tutorial_seen = true
	save_preferences()
