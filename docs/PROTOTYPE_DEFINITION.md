# Prototype Definition

Status: initial prototype definition and procedural-generation implementation approved on 2026-10-24. The broader prototype test and milestone review remain separate tasks. Tuning values may be adjusted after playtesting.

## Confirmed foundations

- Build a small 2D Akari game in Godot with simple provisional visuals.
- Separate game rules from presentation, and level configuration from board definition and mutable game state.
- Generate boards with at least one valid solution; multiple solutions are initially acceptable.
- Target PC with mouse input for the first prototype.
- Include three difficulty presets: Easy, Medium, and Hard, with one level per preset in the completed prototype. Initial dimensions and wall counts are defined below and may be adjusted after playtesting.
- Start implementation with one configuration to validate the core, then add the remaining difficulty presets and their levels.
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

## Level selection

- Show an initial screen with three buttons: Easy, Medium, and Hard.
- Each button opens the single prototype level assigned to that difficulty, using its predefined configuration and fixed seed.

## Board interaction

- Left-click an empty playable cell to place a bulb.
- Left-click a cell containing a bulb to remove it.
- Walls cannot contain bulbs.
- Provide a Restart button that removes all player-placed bulbs and resets derived illumination and conflicts while preserving the current board definition, clues, and level seed.
- Allow bulb placements that create rule violations; players can correct them by removing bulbs.
- Right-click a playable cell without a bulb to toggle a visible no-bulb annotation. This is a player note, not a restriction enforced by the rules.
- Left-clicking an annotated cell removes its annotation and places a bulb in a single action.
- Annotations do not affect illumination, clue counts, or victory checks. Store them in mutable game state, separately from the board definition.
- Restart also clears all annotations, and the solved-state input lock applies to annotations as well.

## Immediate feedback and completion checks

- After every change to player board state, including restart, recalculate illumination, bulb conflicts, numbered clue counts, and the win condition before displaying the updated state.
- Visually distinguish illuminated and unilluminated cells.
- Immediately highlight bulbs that illuminate one another and numbered walls whose adjacent bulb count exceeds their clue. Remove the warning when the violation is corrected.
- An unmet clue with fewer bulbs than required does not by itself indicate an error during play, but prevents victory.
- Detect completion automatically when all playable cells are illuminated, no bulbs illuminate one another, and all numbered clues are satisfied.

## Provisional visual direction

- Use light-colored playable cells and dark walls, with clearly readable numbers on numbered walls.
- Use yellow to indicate illuminated cells and a recognizable bulb symbol for placed bulbs.
- Show player no-bulb annotations as an X.
- Highlight bulb conflicts and exceeded numbered clues in red.
- Keep the board grid and overlapping states readable, including annotations on illuminated cells and bulbs in conflict.
- Use simple provisional visuals; exact colors, shapes, and spacing will be refined during asset prototyping and playtesting.

## Audio and expanded asset planning

- Include the application icon, playable-cell hover feedback, sound effects, and background music in asset planning.
- Music should be calm, relaxing, instrumental lo-fi, suitable for concentration and seamless looping.
- Use [`ASSET_INVENTORY.md`](ASSET_INVENTORY.md) for the complete production checklist. Acquisition methods, exact specifications, and final asset choices remain under discussion.

## Victory flow


- On completion, block further board moves and show "Puzzle solved!".
- Offer Restart and Back to Menu actions. Keep Quit accessible.
- Restart clears the solved state and bulbs, preserves the puzzle, and enables board interaction again.

## Navigation and exit

- Provide a Back to Menu button during gameplay to return to difficulty selection.
- Provide a Quit button to exit the game from gameplay and the initial menu.
- Leaving a level discards its entire play session, including bulbs, annotations, and solved status. Do not save or resume sessions.
- Every time a level is opened, initialize a clean game state for its predefined puzzle. Preserve its board definition and seed, but never restore previous player actions.

## Excluded features

- Do not include automatic hints or an undo history. These are not planned follow-up features.
- Players correct bulb placements directly by left-clicking an existing bulb to remove it, as already required for the prototype.

## Discussion plan

Ask one question at a time and record confirmed answers before moving to the next decision.

1. Define target platform, input method, and the prototype's primary play flow.
2. Define difficulty presets and how seeds are selected for new puzzles and restarts.
3. Define interactions, visual feedback, provisional assets, and the victory flow.
4. Agree on scope boundaries and observable completion criteria before implementation.

## Completion criteria

The prototype milestone is complete only after the following outcomes have been implemented and validated:

- Easy, Medium, and Hard each open their assigned level with the agreed dimensions and target wall count.
- Each level is reproducible from its resolved configuration, fixed seed, and generator version, and has at least one solution satisfying all Akari rules. Multiple solutions remain acceptable.
- Left-click bulb placement and removal, right-click annotation toggling, and replacing annotations with bulbs behave as specified.
- Illumination, bulb conflicts, exceeded clues, and victory detection update correctly after every board-state change, including restart.
- Provisional visuals clearly distinguish cells, walls, clues, bulbs, illumination, annotations, and conflicts.
- Solving a puzzle shows "Puzzle solved!" and locks board interaction; Restart restores a clean, playable instance of the same puzzle.
- Difficulty selection, Back to Menu, Restart, and Quit work throughout the agreed flow. Leaving and reopening any level always produces a clean session.
- Relevant rule and generation checks and manual playtesting have been completed, and issues preventing the agreed flow have been resolved.

Approving this definition completes the planning task, not the playable prototype milestone.

## Future evolution

- Keyboard navigation and actions were implemented and approved after user playtesting on 2026-10-24; see [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md) for the agreed bindings and focus behavior.
- Support gamepad navigation across the board and placing or removing bulbs.
- Keep player actions separate from mouse-specific handling so these input methods can be added without changing game rules. Exact bindings and navigation behavior are deferred.
