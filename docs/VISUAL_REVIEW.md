# Visual Review — 2026-10-25

The Quiet Ink interface is visually cohesive: the navy surfaces, cream labels, amber light, illustrated room, and warm celebration belong together. The board remains the main point of attention during play; the title and room details give the menus their character. No clipped controls, overlapping labels, or uncovered background edges were observed in the 40 captured frames.

The review found one concrete instructional defect and several smaller balance opportunities. These are findings for the user's next decision; no gameplay, tutorial, or layout implementation was changed during this review. Animation work remains completed and approved in [`../TASKS.md`](../TASKS.md).

## Scope and evidence

- **Game revision:** `495fcf8633b50ae07dc4f034fe051607029c3345` (`495fcf8`), containing the approved animation integration.
- **Renderer:** real Godot 4.7.2 viewport captures, not browser reconstructions or generated mockups.
- **Coverage:** 24 frames at 1152 × 800, eight at 1920 × 1080, and eight at 1152 × 640. Every screen appears at the base size; representative demanding layouts also appear at the other two sizes.
- **Isolation:** a separate offscreen window, disabled raw game input, muted audio, 35% music-volume preference, and disposable player data. The existing play session was not restarted or controlled.
- **Consistent staging:** the title startup settled before capture and the background pose was frozen for comparison. Controller hints reflect the connected Xbox controller. Partial solutions, warnings, and victories were produced through the game's action handlers. The random fixture uses a reproducible capture-only seed.
- **Fallback:** the load-error screen was deliberately triggered with an invalid configuration. Its one configuration-error log is expected and does not indicate that normal boards failed to load. The capture process completed all 40 frames without other error or warning logs.

The [machine-readable manifest](screenshots/review/index.json) records image dimensions, logical viewport, current page, focused control, capture time, and game revision. This is a static composition review; it does not establish motion quality, input responsiveness, physical-controller behavior, audio balance, every hover state, or actual fullscreen transitions. Those depend on the separate user playtests and functional checks.

## Findings

### F01 — Tutorial completion diagram is incomplete (P2, instructional defect)

The final page says “Complete the puzzle,” but its center playable cell is unlit. Four corner bulbs cannot illuminate it because walls isolate it on all four sides. The image therefore contradicts the completion rule being taught.

Evidence: [tutorial step 5](screenshots/review/1152x800/tutorial-5.png); the corresponding definition is in [`../src/presentation/main.gd`](../src/presentation/main.gd), with rows `[".#.", "#.#", ".#."]` and bulbs at `[0, 2, 6, 8]`.

**Proposed next change:** make this a truly completed example, for instance by adding a bulb to the isolated center. No generator or gameplay-rule change is needed.

### F02 — Random gameplay has much wider side gutters (P3, visual balance)

At 1152 × 800, the numbered gameplay card is approximately 510 pixels wide, while the random card grows to approximately 698 pixels with the same 420-pixel board. The extra “New Random Level” action expands the single footer row. This creates a visible change in proportions, covers more of the room, and brings the upper-right card corner close to the moon.

Evidence: [numbered Easy board](screenshots/review/1152x800/gameplay-easy.png), [random board](screenshots/review/1152x800/gameplay-random.png).

**Possible refinement:** agree on a more compact arrangement of the three random actions, preserving their readable labels, spacing, and hit areas. This is a design choice; the existing row fits and has no overlap.

### F03 — Floating button contrast depends on the background (P3, optional polish)

The translucent main-menu and selection buttons cross different scene planes. Tutorial lies over the bright windowsill; Quit and Back lie over the desk; some lower level buttons overlap bright distant houses. Labels remain readable in the captured states, but the changing background makes some buttons less calm and visually uniform than others.

Evidence: [main menu](screenshots/review/1152x800/main-menu.png), [level selection](screenshots/review/1152x800/levels-hard.png), [short-window main menu](screenshots/review/1152x640/main-menu.png).

**Possible refinement:** test a very restrained local background shade behind these groups, preserving the approved floating menus and translucent buttons. This should be compared visually before implementation.

## Smaller observations

| Area | Assessment | Evidence / possible refinement |
|---|---|---|
| Audio & Display | The fixed shared viewport leaves considerable empty space to the right and below its two settings. This is less balanced than Controls, but preserves the required stable shell. | [Audio & Display](screenshots/review/1152x800/settings-audio.png). If revisited, adjust content grouping inside the existing viewport rather than resizing the card per tab. |
| Tutorial inner layout | The outer card keeps its size. Different paragraph heights shift the inner diagram/action stack by roughly 15 pixels between shorter and longer steps. | [Step 1](screenshots/review/1152x800/tutorial-1.png), [step 4](screenshots/review/1152x800/tutorial-4.png). Reserving a shared body-text height could make internal positions steadier. |
| Selection and warning colors | The coral selection rim and red warning rim are close in color. Yellow selection corners, red clue text, and exclamation badges keep the states distinguishable. | [Conflicting bulbs](screenshots/review/1152x800/gameplay-feedback.png), [exceeded clue](screenshots/review/1152x800/gameplay-clue-warning.png). Optional later differentiation should retain the approved selector. |
| Short window | The 9 × 9 board fits, but its clue digits and progress counter are smaller at 1152 × 640. No clipping was observed. | [Hard board](screenshots/review/1152x640/gameplay-hard.png). Comfortable reading distance remains a user check. |

These observations are separate from confirmed defects and have not been added as authorized implementation tasks.

## What works well

- **Composition:** the title and menu occupy the darker central sky, leaving the cat and decorative lamp visible. The background covers all three captured ratios without black side bars.
- **Hierarchy:** gameplay title, counter, board, and actions form a clear centered stack. The 5 × 5, 7 × 7, and 9 × 9 boards keep a consistent overall extent.
- **Board feedback:** cream/unlit and gold/lit cells are distinct; bulbs and X notes remain readable on both backgrounds. Conflict badges and red numbered clues expose mistakes without replacing the board's palette.
- **Settings:** both tabs share the same card and header geometry. Arrows and LB/RB hints align symmetrically inside the inner frame. The device columns, keycaps, and separators organize the dense Controls content. Top/bottom captures match because the reference fits at this size; these images alone do not prove overflow scrolling.
- **Tutorial:** all five pages fit the stable outer card, including the longest copy in the short window. Next/Done remains the focused action and Skip stays separate.
- **Victory:** dimming gives the message and buttons priority. Warm sparkles match the lighting vocabulary. Numbered, final-level, and random variants are readable and contained; the final-level variant correctly omits Next Level.
- **Fallback:** the load-error message and single exit action are clear and centered.

## Capture catalog

All links below open the original full-resolution PNG. The README uses a selection of the 1152 × 800 frames; the complete set is preserved here for comparison.

### 1152 × 800

| Screen or state | Capture |
|---|---|
| Main menu | [main-menu](screenshots/review/1152x800/main-menu.png) |
| Difficulty and random selection | [difficulty-selection](screenshots/review/1152x800/difficulty-selection.png) |
| Easy level selection | [levels-easy](screenshots/review/1152x800/levels-easy.png) |
| Medium level selection | [levels-medium](screenshots/review/1152x800/levels-medium.png) |
| Hard level selection | [levels-hard](screenshots/review/1152x800/levels-hard.png) |
| Settings: Audio & Display | [settings-audio](screenshots/review/1152x800/settings-audio.png) |
| Settings: Controls, top | [settings-controls](screenshots/review/1152x800/settings-controls.png) |
| Settings: Controls, bottom | [settings-controls-bottom](screenshots/review/1152x800/settings-controls-bottom.png) |
| Tutorial step 1 | [tutorial-1](screenshots/review/1152x800/tutorial-1.png) |
| Tutorial step 2 | [tutorial-2](screenshots/review/1152x800/tutorial-2.png) |
| Tutorial step 3 | [tutorial-3](screenshots/review/1152x800/tutorial-3.png) |
| Tutorial step 4 | [tutorial-4](screenshots/review/1152x800/tutorial-4.png) |
| Tutorial step 5 | [tutorial-5](screenshots/review/1152x800/tutorial-5.png) |
| Easy gameplay | [gameplay-easy](screenshots/review/1152x800/gameplay-easy.png) |
| Medium gameplay | [gameplay-medium](screenshots/review/1152x800/gameplay-medium.png) |
| Hard gameplay | [gameplay-hard](screenshots/review/1152x800/gameplay-hard.png) |
| Gameplay: valid partial illumination | [gameplay-progress](screenshots/review/1152x800/gameplay-progress.png) |
| Gameplay: light, X, and conflicts | [gameplay-feedback](screenshots/review/1152x800/gameplay-feedback.png) |
| Gameplay: exceeded numbered clue | [gameplay-clue-warning](screenshots/review/1152x800/gameplay-clue-warning.png) |
| Numbered victory with Next Level | [victory-numbered](screenshots/review/1152x800/victory-numbered.png) |
| Final registered level victory | [victory-final](screenshots/review/1152x800/victory-final.png) |
| Random gameplay | [gameplay-random](screenshots/review/1152x800/gameplay-random.png) |
| Random victory | [victory-random](screenshots/review/1152x800/victory-random.png) |
| Load-error fallback (invalid fixture) | [load-error](screenshots/review/1152x800/load-error.png) |

### 1920 × 1080

| Screen or state | Capture |
|---|---|
| Main menu | [main-menu](screenshots/review/1920x1080/main-menu.png) |
| Difficulty selection | [difficulty-selection](screenshots/review/1920x1080/difficulty-selection.png) |
| Hard level selection | [levels-hard](screenshots/review/1920x1080/levels-hard.png) |
| Settings: Audio & Display | [settings-audio](screenshots/review/1920x1080/settings-audio.png) |
| Settings: Controls | [settings-controls](screenshots/review/1920x1080/settings-controls.png) |
| Tutorial: longest text | [tutorial-4](screenshots/review/1920x1080/tutorial-4.png) |
| Hard gameplay | [gameplay-hard](screenshots/review/1920x1080/gameplay-hard.png) |
| Numbered victory | [victory-numbered](screenshots/review/1920x1080/victory-numbered.png) |

### 1152 × 640

| Screen or state | Capture |
|---|---|
| Main menu | [main-menu](screenshots/review/1152x640/main-menu.png) |
| Difficulty selection | [difficulty-selection](screenshots/review/1152x640/difficulty-selection.png) |
| Hard level selection | [levels-hard](screenshots/review/1152x640/levels-hard.png) |
| Settings: Audio & Display | [settings-audio](screenshots/review/1152x640/settings-audio.png) |
| Settings: Controls | [settings-controls](screenshots/review/1152x640/settings-controls.png) |
| Tutorial: longest text | [tutorial-4](screenshots/review/1152x640/tutorial-4.png) |
| Hard gameplay | [gameplay-hard](screenshots/review/1152x640/gameplay-hard.png) |
| Numbered victory | [victory-numbered](screenshots/review/1152x640/victory-numbered.png) |

## Reproducing the captures

See [`../tools/README.md`](../tools/README.md). The capture script stages the actual interface in an isolated Godot process and writes a fresh manifest. New screenshots should be reviewed before replacing this report's evidence or the README gallery.
