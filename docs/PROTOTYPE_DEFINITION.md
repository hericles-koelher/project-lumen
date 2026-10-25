# Prototype Definition

Status: core prototype, deterministic generation, keyboard and Xbox controls, and bulb-to-X replacement were tested and approved. The refinement implementation and 731 automated checks are complete; the user’s final visual/gameplay review remains open. See [`../TASKS.md`](../TASKS.md), [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md), and [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md).

## Confirmed foundations

- Build a small 2D Akari game in Godot; the selected Quiet Ink interface is documented in [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md).
- Separate game rules from presentation, and level configuration from board definition and mutable game state.
- Generate boards with at least one valid solution; multiple solutions are initially acceptable.
- Target PC with mouse, keyboard, and standardized gamepad input. See [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md) for bindings and navigation.
- Include three difficulty presets: Easy, Medium, and Hard. The prototype provides ten explicitly seeded numbered levels for each preset, plus Random Level at the same selection step.
- Use predefined difficulty presets to supply generation parameters, including board dimensions and target wall count.
- Keep a mixture of numbered and unnumbered walls in generated levels. Number 70% of walls, rounded down; use the counts below as initial tuning values.
- Use a seed to reproduce a particular board for the same resolved configuration and generator version.
- Give each level an explicit fixed seed, separate from its stable level ID, and record its difficulty and generator version. Use an isolated random source for generation; record resolved parameters for reproduction. See [`PROCEDURAL_GENERATION.md`](PROCEDURAL_GENERATION.md).
- Write code and repository documentation in English.

## Difficulty presets

| Preset | Width | Height | Target wall count | Numbered | Unnumbered |
|---|---|---|---|---|---|
| Easy | 5 | 5 | 5 | 3 | 2 |
| Medium | 7 | 7 | 10 | 7 | 3 |
| Hard | 9 | 9 | 16 | 11 | 5 |

Numbered counts use `floor(target_wall_count × 0.70)`. The resulting proportions are 60% for Easy, 70% for Medium, and 68.75% for Hard.

Easy is the initial configuration used to validate the core. Wall counts include both numbered and unnumbered walls. These starting values keep walls near 20% of each board while increasing board size; they are tuning baselines, not guarantees of solving difficulty. Actual difficulty depends on wall placement and clues and will be assessed through playtesting. The user has delegated the initial dimensions and wall counts and will report desired adjustments during testing.

## Menu and level selection

- The main menu offers Start Game, Settings, Tutorial, Quit, and a separate corner shortcut to mute/unmute all audio.
- Start Game offers each registered difficulty and Random Level at the same selection step. Selecting a difficulty opens Level 1–10.
- Each numbered level uses its explicit fixed seed and resolved difficulty preset. Random Level chooses uniformly from registered difficulties and holds its seed only for the active session.
- Restart clears player moves while preserving the active board and seed. Exit to Menu discards the session; it is never resumed.

## Board interaction

- Left-click an empty playable cell to place a bulb.
- Left-click a cell containing a bulb to remove it.
- Walls cannot contain bulbs.
- Provide a Restart button that removes all player-placed bulbs and resets derived illumination and conflicts while preserving the current board definition, clues, and level seed.
- Allow bulb placements that create rule violations; players can correct them by removing bulbs.
- Right-click a playable cell to toggle a visible no-bulb annotation. If a bulb is present, replace it with the annotation in one action. This is a player note, not a restriction enforced by the rules.
- Left-clicking an annotated cell removes its annotation and places a bulb in a single action.
- Annotations do not affect illumination, clue counts, or victory checks. Store them in mutable game state, separately from the board definition.
- Restart also clears all annotations, and the solved-state input lock applies to annotations as well.

## Immediate feedback and completion checks

- After every change to player board state, including restart, recalculate illumination, bulb conflicts, numbered clue counts, and the win condition before displaying the updated state.
- Visually distinguish illuminated and unilluminated cells.
- Immediately highlight bulbs that illuminate one another and numbered walls whose adjacent bulb count exceeds their clue. Remove the warning when the violation is corrected.
- An unmet clue with fewer bulbs than required does not by itself indicate an error during play, but prevents victory.
- Detect completion automatically when all playable cells are illuminated, no bulbs illuminate one another, and all numbered clues are satisfied.

## Visual direction

- Use light-colored playable cells and dark walls, with clearly readable numbers on numbered walls.
- Use yellow to indicate illuminated cells and a recognizable bulb symbol for placed bulbs.
- Show player no-bulb annotations as an X.
- Highlight bulb conflicts and exceeded numbered clues in red.
- Keep the board grid and overlapping states readable, including annotations on illuminated cells and bulbs in conflict.
- The selected Quiet Ink palette, artwork, scalable controls, layout, and transitions are recorded in [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md); the final integrated visual review remains pending.

## Audio and assets

- The prototype includes board/interface sounds and the selected calm lo-fi track, “Our Morning Coffee.” Sources and license are in [`../assets/ASSET_MANIFEST.md`](../assets/ASSET_MANIFEST.md).
- The global mute shortcut silences all audio; music volume is adjustable separately from effects.
- The visual assets, menu components, audio icons, cursors, hover state, and finite sparkle effect are cataloged in [`ASSET_INVENTORY.md`](ASSET_INVENTORY.md) and [`../assets/ASSET_MANIFEST.md`](../assets/ASSET_MANIFEST.md).

## Victory flow

- On completion, block further board moves, dim the solved board slightly, and show the centered “Puzzle solved!” panel with a finite sparkle burst.
- Numbered levels offer Next Level, Restart, and Exit to Menu. Next Level advances within the catalog and crosses to the next difficulty; it is absent only at the last registered level.
- Random-level victory offers New Random Level, Restart, and Exit to Menu.
- Restart clears player moves, preserves the puzzle, and enables interaction again. The full exit/progression behavior is in [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md).

## Navigation, Settings, and tutorial

- The first launch opens the tutorial and marks it as seen immediately. It can be revisited from the main menu; Skip and completion return to the menu. Each page initially focuses Next, or Done on the last page.
- Settings provides music volume, global mute, windowed/fullscreen mode, and a read-only Keyboard/Mouse and Gamepad reference. The active Settings tab receives focus when opened.
- The active menu/input behavior is specified in [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md).
- During gameplay and victory, Exit to Menu, Escape, and gamepad B return directly to the main menu. Quit is a main-menu choice.
- Leaving a level discards its entire play session, including bulbs, annotations, solved status, and temporary random seed. Do not save or resume sessions.

## Excluded features

- Do not include automatic hints or an undo history. These are not planned follow-up features.
- Players correct bulb placements directly by left-clicking an existing bulb to remove it, as already required for the prototype.

## Completion criteria

The prototype implementation and isolated checks are complete. The refinement tasks remain open until the user finishes the final review. The delivered prototype meets these criteria:

- Easy, Medium, and Hard each provide ten numbered levels with the agreed dimensions, wall counts, and explicit seeds; Random Level draws from the registered presets.
- Each level is reproducible from its resolved configuration, fixed seed, and generator version, and has at least one solution satisfying all Akari rules. Multiple solutions remain acceptable.
- Left-click bulb placement and removal, right-click annotation toggling, and replacing annotations with bulbs or bulbs with annotations behave as specified across the supported input methods.
- Illumination, bulb conflicts, exceeded clues, and victory detection update correctly after every board-state change, including restart.
- The board presentation distinguishes cells, walls, clues, bulbs, illumination, annotations, and conflicts.
- Solving a puzzle shows "Puzzle solved!" and locks board interaction; Restart restores a clean, playable instance of the same puzzle.
- Difficulty/numbered-level selection, random sessions, Settings, the tutorial, progression, Exit to Menu, Restart, and Quit work throughout the agreed flow. Leaving and reopening any level always produces a clean session.
- Rule, generation, input, and automated flow checks pass. Earlier playtesting approved the core behavior and informed the refinement; the integrated interface still awaits the final user review.

This document records the approved prototype design; the current implementation and outstanding visual review are tracked separately in [`../TASKS.md`](../TASKS.md).

## Input evolution

- Keyboard navigation and actions were implemented and approved after user playtesting on 2026-10-24; see [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md) for the agreed bindings and focus behavior.
- Gamepad navigation and actions were approved after Xbox playtesting on 2026-10-24, including D-pad/left stick, A/X actions, and B/Escape Back shortcuts. Bulb-to-X replacement was also tested and approved on that date.
- Keep player actions independent of input devices. The current bindings and navigation behavior are specified in [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md); physical compatibility with generic controllers remains to be tested.
