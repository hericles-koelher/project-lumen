# Animation implementation

This document describes the integrated ambient-room, title-startup, and board-light animations. The motion candidates were approved separately; the user approved their combined in-game presentation on 2026-10-25.

## Room layers and coordinates

`src/presentation/ambient_background.gd` is the persistent room background. It draws `assets/backgrounds/quiet_ink_room_animation_clean.png`, a 1586 × 992 clean plate edited from the current room image to remove the painted cat and outdoor branch silhouettes. The original room remains preserved. The built-in image generation tool produced this technical clean plate using the recorded [edit prompt](concepts/animations/room-clean-plate.prompt.txt). The approved cat, branch, and halo PNGs are separate textures; the clean plate avoids doubled artwork beneath them.

Every animated room layer uses the clean plate's source-image coordinates. The controller scales its `AnimatedRoomLayers` canvas by `max(viewport_width / 1586, viewport_height / 992)` and centers the resulting canvas, matching the background TextureRect's cover crop at every aspect ratio.

| Layer | Source placement and rendering |
|---|---|
| Room lamp | Existing transparent halo centered at 87.6% × 60.6% of the source image; width is 22% of source width. Additive light varies over the approved six-second cycle. |
| Sleeping cat | Separate transparent sprite at `(-210, 480)`, scale `0.35`, on a 192 × 128 mesh. The breathing shader lifts the torso while keeping the head, ears, paws, and tail still. |
| Outdoor panes | Open pane rectangles are `(354, 0, 978, 646)` and `(1420, 0, 166, 451)`. Each pane clips its children to the window opening. |
| Indoor occlusion | Source-coordinate Polygon2D overlays sample the identical clean plate over the left indoor plant and right-side furniture/lamp/books, keeping the foliage behind foreground objects. |
| Outdoor branches | Five unchanged branch textures are drawn behind the window frame and indoor occlusion. Their source rectangles are listed below. A muted blue-gray modulation fits the approved branch texture into the nighttime scene. |

| Branch | Source rectangle | Pane |
|---|---:|---|
| `LeftUpper` | `(220, -20, 280, 280)`, horizontally flipped | Main window |
| `RightUpper` | `(1200, 150, 320, 320)` | Main window |
| `RightSidePane` | `(1430, 30, 260, 260)` | Narrow right pane |
| `LeftLower` | `(430, 500, 280, 280)` | Main window |
| `RightLower` | `(1130, 515, 280, 280)` | Main window |

Each branch has its own four-second breeze. Initial start offsets differ by 0.8 seconds; after a breeze, that branch rests for a fixed four seconds before moving again. The user shortened this pause during in-game review. Movement duration and rest are both exported for Inspector tuning. The foliage shader returns each branch to its exact resting pose. All branches read the same live foliage intensity while retaining independent schedules.

## Cat, ear, and lamp schedules

The cat breathes on the approved 4.8-second cycle. A separate ear-only gesture lasts 0.62 seconds; its first gesture starts after 2.5 seconds for discoverability, and later gestures rest for 8–15 seconds after each gesture ends. Ear and breathing share the cat texture and shader material, but use separate deformation parameters and anatomical masks.

The room lamp remains visible while its halo follows the approved six-second opacity cycle, varying between 4% and 22% at the 100% preset. The background itself is never brightened or deformed by these effects.

## Title startup and menu lifetime

`src/presentation/title_startup.gd` is a Control child of the existing centered, keep-aspect wordmark. It dims only the wordmark and draws the existing halo texture using the fitted image bounds. The title first fades in over 0.4 seconds, holds visibly for 0.3 seconds, then plays the existing three 80 ms flickers separated by 150 ms rests, a 60 ms settle, and a 250 ms halo reveal. At current tuning values the title reaches full brightness 1.34 seconds after the sequence starts and the halo finishes at 1.59 seconds. Including the existing 140 ms menu entrance delay, the full sequence takes about 1.73 seconds from the menu appearing. Input remains available throughout.

`src/presentation/main.gd` owns `_title_startup_played` outside the rebuilt menu controls. The initial tutorial does not consume the flag: startup runs the first time the title menu appears. Later returns from Settings, Tutorial, or gameplay create a settled title and halo without replaying. Input remains available during the effect.

## Tuning Resource

`src/presentation/animation_tuning.gd` defines exported values stored in `assets/animations/animation_tuning.tres`. The room and title controllers read their current intensity properties while running; board-cell transitions read the resource when each change is animated.

| Exported property | Approved value | Effect |
|---|---:|---|
| `lamp_light_intensity_percent` | 100% | Room-lamp halo amplitude |
| `cat_breathing_intensity_percent` | 75% | Torso-breathing amplitude |
| `cat_ear_intensity_percent` | 150% | Isolated ear-gesture amplitude |
| `outdoor_leaves_intensity_percent` | 100% reference | Breeze and leaf-flutter amplitude; current saved user override is 160% |
| `outdoor_leaves_breeze_duration_seconds` | 4 s | Movement duration per branch |
| `outdoor_leaves_rest_seconds` | 4 s | Fixed pause after each breeze |
| `title_startup_intensity_percent` | 100% | Title brightness variation |
| `title_lamp_halo_intensity_percent` | 270% | Title halo alpha; the 20% base reaches 54% |
| `title_fade_in_duration_seconds` | 0.4 s | Wordmark opacity reveal before the startup flickers |
| `title_reveal_pause_seconds` | 0.3 s | Hold after the wordmark appears and before the flickers |
| `title_initial_blink_count` | 3 | Initial title flickers |
| `title_initial_blink_interval_ms` | 150 ms | Rest between title flickers |
| `bulb_pop_intensity_percent` | 100% | Board-cell bulb pop |
| `illumination_wave_intensity_percent` | 100% | Newly lit or unlit cell accent |
| `illumination_wave_step_ms` | 30 ms | Delay between outward wave distances |
| `illumination_cell_fade_ms` | 120 ms | Cell-color transition duration |

The Resource remains editable in the Godot Inspector. The exported ranges and defaults are documented beside each property in `animation_tuning.gd`.

## Validation and review

The isolated animation integration suite previously passed 56 checks with zero failures. Its title timing expectations now include the added fade and pause, but the updated suite has not been rerun. It covers first-visible-title timing after the first-launch tutorial, once-per-run behavior, settled menu returns, title tuning changes, approved ambient amplitudes and schedules, all five branch controllers, source cover transforms, and the fitted title image bounds. The updated isolated menu-flow suite passed 177 checks with zero failures.

GPU Compatibility renders showed nonzero breathing and ear motion; the ear-only check changed pixels only in the ear region. Foliage motion stayed inside the windowpane masks and behind indoor polygon occluders: there were no changed pixels inside the polygons beyond a one-pixel raster-edge tolerance, with only 11 changed pixels on those edges. Room-lamp changes stayed localized around the globe. Menu captures were inspected at 1152 × 800, 1920 × 1080, and 2560 × 1080. The clean plate was also inspected at its 1586 × 992 source extent to confirm the original cat and outdoor branches were removed while the indoor composition remained.

The user approved the completed animation work on 2026-10-25 after in-game review, then requested a 0.4-second title fade-in and 0.3-second visible pause before the approved flicker sequence. The implementation is pending the user's review. See the individual [lamp](concepts/animations/lamp-light-candidate-01.md), [cat breathing](concepts/animations/cat-breathing-candidate-01.md), [ear](concepts/animations/cat-ear-candidate-01.md), [foliage](concepts/animations/outdoor-leaves-candidate-01.md), [title](concepts/animations/title-startup-candidate-01.md), and [board bulb](concepts/animations/board-bulb-candidate-02.md) records, along with the [asset manifest](../assets/ASSET_MANIFEST.md) and [automated check notes](../tests/README.md).
