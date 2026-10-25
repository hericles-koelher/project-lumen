# Automated Domain Checks

The standalone GDScript runners check game rules, fixed-level catalogs, generation, navigation, player preferences, and scene-level menu/session flows without a third-party test framework.

Use the Python standard-library wrapper to run all seven suites in an isolated temporary project with no MCP autoload. It links the existing source and tests, imports project assets into the temporary project, and directs Godot's `user://` storage to a temporary XDG data directory. Checks do not modify player preferences or stop, restart, or re-register the user's editor play session. The wrapper requires Python 3 and runs on the current Linux development setup.

From the repository root, run with a Godot 4.7.2 executable:

```sh
python3 tests/run_checks.py --godot /path/to/godot
```

If `godot` or `godot4` is already on PATH, omit `--godot`. The machine-specific executable location is documented in `docs/DEVELOPMENT_SETUP.md`. Temporary files are created under ignored `work/` and removed automatically.

The wrapper returns a nonzero exit code on failure. On 2026-10-24, all seven suites passed cleanly with no errors or warnings (731 checks total):

- `run_core.gd`: 29 checks passed, covering wall blocking, bulb conflicts, boundary/zero clues, annotations, reset, the fixed fixture, and replacing a bulb with X (including lighting updates, clearing violations, and completing a puzzle).
- `run_generation.gd`: 479 checks passed, covering all 30 unique fixed-level IDs, explicit seeds, stable first-level identities, catalog progression boundaries, random difficulty inclusion, exact wall/clue counts, seeded reproduction independent from global randomness, configuration/board isolation, invalid input handling, and solution validity across 120 additional boards (40 seeds per difficulty).
- `run_input.gd`: 63 checks passed, covering arrow/WASD bindings, action bindings, repeat behavior, modified shortcuts, initial selection, boundaries, one-cell movement onto and across consecutive walls, top-left wall selection, rejected wall actions leaving state unchanged, button-row resizing, and returning to the remembered cell at all three board sizes.
- `run_gamepad.gd`: 47 checks passed using synthetic events, covering standardized buttons on multiple device IDs, Escape/B mapping, D-pad and stick state, deadzone, stable cardinal direction, connection/reset behavior, and repeat timing. These checks do not certify physical controller compatibility; the user tested and approved Xbox interaction on 2026-10-24. Generic controller hardware remains untested.
- `run_action_guard.gd`: 14 checks passed with supplied timestamps, covering the 150 ms default, exact boundaries, independent action/cell pairs, rejected presses not extending the interval, reset, and a custom interval.
- `run_preferences.gd`: 22 checks passed, covering isolated user-data paths, default values, round-trip persistence, invalid/missing values, independent fallback, NaN/infinity handling, volume clamping, and immediate tutorial-seen persistence.
- `run_flow.gd`: checks returning-player and first-launch routes, tutorial Skip and Next/Done focus, persistent equal-height tutorial card and diagram slot, tutorial re-entry from its first page, active-tab focus in Settings and Controls, Settings Back behavior, mute/zero-volume behavior, content-sized menu buttons, controller-only duplicate-action suppression with immediate alternate inputs/cells/actions, selected-wall highlighting and action rejection, mute-button bounds, idle pointer hiding, mouse/keyboard/controller switching, stick-drift rejection, same-cell hover restoration, pointer restoration on focus loss and scene disposal, widescreen/ultrawide viewport and background coverage, level progression boundaries, modal victory focus, random-session restart identity, and session disposal. The runner sets the root window to 1152 × 800 and releases audio before cleanup. It disables live raw-input handling so physical controller events stay outside the synthetic scene. It does not interact with the user's running game. Headless pointer checks verify the visibility policy because that backend always reports a visible OS cursor.

The main fixed-board fixture has a known solution at zero-based `(x, y)` coordinates `(0, 0)`, `(2, 1)`, `(1, 2)`, `(4, 2)`, and `(2, 4)`. This is test data only; gameplay accepts any placement satisfying the rules.

Manual review remains with the user and should cover:

- First launch, tutorial navigation/Skip, and tutorial review from the main menu.
- Pointer hiding after three seconds of inactivity and immediately on keyboard/controller use; movement/click restores it, including movement inside the same cell. Confirm neutral analog drift does not hide it and leaving/closing the game restores it.
- Mouse, keyboard, and Xbox navigation through every menu, Settings tab, and numbered-level selection.
- Controller A/X double-press suppression on one cell; verify different actions/cells remain immediate and tune the initial 150 ms interval from hardware feedback.
- Volume changes including 0%, global mute/unmute of all audio, and persistence after reopening the game.
- Windowed/fullscreen/maximized layouts, responsive background, board sizing, and accessible actions at each difficulty.
- Random-session restart preserving the same puzzle, New Random Level replacing it, and menu exit discarding it.
- Victory actions on a middle level, Easy Level 10, the final registered level, and a random puzzle; verify Tab, mouse, Escape, and B cannot reach the locked board or hidden gameplay buttons.
- Cell hover and cursor clarity, keyboard/gamepad one-cell movement through walls, mouse-to-keyboard selection handoff, and audio balance.

Automated checks cover functional state and focus rules; they do not replace visual or physical gamepad review.

## Settings refinement verification — 2026-10-25

The updated isolated `run_flow.gd` suite passed 115 headless checks with zero failures after the Settings corrections. Coverage includes unchanged header/content/footer geometry, persistent shell/control instances, no new fade when changing tabs, in-place selection highlights, selecting the current tab without resetting its content/scroll, valid directional-focus targets, inset arrow alignment, and real overflow scrolling. Back-button, Escape, and B events are each checked from both Settings tabs and must exit directly to the main menu. The display-mode checks exercise both activations and verify that the page/button remain alive, button text and persisted preferences change correctly, and focus/scroll are retained. This display-mode case runs headlessly to avoid turning an offscreen graphical test window into fullscreen on the player's desktop; native window-manager transitions remain a manual check. The earlier seven-suite result above remains the historical 2026-10-24 baseline; the unrelated domain suites were not rerun for these presentation changes.

Actual Godot renders of Audio & Display and Controls were inspected at 1152 × 800, 1672 × 941, 1920 × 1080, and 1152 × 640. The 1672 × 941 Controls render was compared with the [approved mockup](../docs/concepts/settings-approved-prototype.png). These checks used temporary player preferences and a separate offscreen window, leaving the player's running game untouched. The README Controls screenshot reflects the corrected layout; user visual and physical-controller approval remains pending.
