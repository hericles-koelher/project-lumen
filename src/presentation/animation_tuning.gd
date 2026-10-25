extends Resource
## Stores editor-adjustable intensity presets for animation candidates.
## Pending animation controllers must read this resource when integrated into Godot.

@export_group("Decorative Lamp")
## Percentage multiplier for the approved six-second light variation; 100 preserves it.
@export_range(0.0, 200.0, 1.0, "suffix:%")
var lamp_light_intensity_percent: float = 100.0

@export_group("Sleeping Cat")
## Percentage of the breathing prototype's reference amplitude; approved at 75 percent.
@export_range(0.0, 200.0, 1.0, "suffix:%")
var cat_breathing_intensity_percent: float = 75.0

## Percentage of the isolated ear prototype's reference angle; approved at 150 percent.
@export_range(0.0, 200.0, 1.0, "suffix:%")
var cat_ear_intensity_percent: float = 150.0

@export_group("Outdoor Foliage")
## Percentage of the outdoor leaves' reference sway; approved at 100 percent.
@export_range(0.0, 200.0, 1.0, "suffix:%")
var outdoor_leaves_intensity_percent: float = 100.0

@export_group("Game Title")
## Percentage of the title startup's brightness variation; 100 is the approved startup flicker intensity.
@export_range(0.0, 200.0, 1.0, "suffix:%")
var title_startup_intensity_percent: float = 100.0

## Percentage of the final lamp halo; approved at 270 percent.
@export_range(0.0, 300.0, 1.0, "suffix:%")
var title_lamp_halo_intensity_percent: float = 270.0

## Number of initial light-on flickers before the steady halo.
@export_range(0, 8, 1)
var title_initial_blink_count: int = 3

## Milliseconds of rest between the end of an initial flicker and the next one.
@export_range(20.0, 2000.0, 5.0, "suffix:ms")
var title_initial_blink_interval_ms: float = 150.0

