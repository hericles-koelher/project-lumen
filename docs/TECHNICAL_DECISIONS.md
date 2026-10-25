# Technical Decisions

This file records decisions that affect architecture, persisted data, or observable behavior. For each important decision, note the context, choice, and consequences.

## TD-001 — Start with a functional core

- **Context:** the project is also a learning exercise in Godot and game development.
- **Choice:** build a simple, functional version first and defer themed art until the rules and interaction are clear.
- **Consequence:** prioritize readable code, small scenes, and incremental steps.

## TD-002 — Separate rules from presentation

- **Context:** rules need to be easy to verify and should not be tied to visual nodes.
- **Choice:** keep game logic and state decoupled from Godot presentation.
- **Consequence:** the interface reads and changes state through well-defined actions.

## TD-003 — Deterministic generation with a minimum validity guarantee

- **Context:** seeds should make levels reproducible and help debug generated results.
- **Choice:** use dimensions, target wall count, and seed as inputs; guarantee at least one solution while initially allowing multiple solutions.
- **Consequence:** the generator must preserve or verify a valid solution. Uniqueness and a general solver are not first-version requirements.

## TD-004 — Difficulty presets control generation parameters

- **Context:** players should encounter puzzles configured by difficulty rather than manually specifying board dimensions and wall counts.
- **Choice:** define difficulty presets that supply generation parameters. A preset may be selected by the player or assigned to a level; the seed identifies a particular generated board.
- **Consequence:** resolve a concrete level configuration before invoking the generator. Initial preset values are recorded in `PROTOTYPE_DEFINITION.md` and require playtesting. Seed policy is recorded in TD-005. The catalog registers ten fixed levels per difficulty and defines progression order. Each level has a stable ID and an explicit seed.

## TD-005 — Explicit per-level seeds independent from level identity

- **Context:** the game needs reproducible numbered puzzles that can be tuned individually, plus a separate temporary random mode.
- **Choice:** store an explicit seed separately from each level's stable ID, together with its difficulty and generator version. Generate with isolated random state and retain resolved parameters in reproduction metadata. Random mode draws a difficulty uniformly and uses a temporary in-memory seed.
- **Consequence:** seeds can change without renaming levels. Reproduction requires matching configuration, generator version, and compatible random behavior. Global seed derivation and saving final board definitions are possible later extensions.

## TD-006 — Construct a solution before deriving clues

- **Context:** the prototype needs exact wall counts and valid levels without a general solver.
- **Choice:** place walls first, then visit shuffled playable cells and add a bulb only to unlit cells. Derive a shuffled subset of wall clues from this solution and validate the final board using the existing game rules.
- **Consequence:** construction terminates in bounded passes and preserves at least one solution. Difficulty quality and uniqueness are not guaranteed by this method and remain subject to playtesting and future work.

## TD-007 — Number seventy percent of walls, rounded down

- **Context:** the user requested a mixture with fewer numbered walls than the initial 80% proposal.
- **Choice:** use a 70% ratio rounded down, yielding 3, 7, and 11 numbered walls in Easy, Medium, and Hard respectively.
- **Consequence:** ratios differ slightly on small boards because wall counts are integers. These initial values can be tuned after playtesting.


## TD-008 — Navigate through walls without interacting with them

- **Context:** the user tested directional wall skipping and preferred the earlier one-cell navigation for keyboard and gamepad.
- **Choice:** every board position is selectable, including numbered and unnumbered walls. Start at the top-left cell and move one position per step without wrapping; preserve board/button focus transitions.
- **Consequence:** navigation does not need a playable-cell mask. A selected wall shows the shared focus marker, while the game-state action boundary rejects bulbs and X notes. Mouse interaction remains limited to playable cells.


## TD-009 — Filter accidental repeated controller board actions

- **Context:** the user's controller sometimes produces two rapid presses for bulb or annotation actions.
- **Choice:** apply a 150 ms guard per action type and cell, only for gamepad board actions. Different actions and cells remain immediate; mouse and keyboard retain their existing behavior.
- **Consequence:** the input filter uses supplied monotonic timestamps and resets at session/focus/controller boundaries. Rejected presses do not extend the cooldown. Keep the interval easy to tune without adding a configuration screen.

## TD-010 — Hide the free pointer during inactivity or alternate input

- **Context:** the custom mouse pointer overlaps the board and interface focus when the player switches to keyboard or gamepad, and an idle cursor distracts from the screen.
- **Choice:** hide it after three seconds without mouse activity or immediately on a keyboard press, controller-button press, or intentional left-stick movement. Restore it on mouse movement/click or application focus changes. Keep mouse motion free and reject stick drift inside the existing deadzone.
- **Consequence:** hidden pointer hover cannot replace the selected board cell. A real motion over a playable cell restores mouse selection, even when the pointer never left that cell. See [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md).

## TD-011 — Focus the active Settings tab and tutorial continuation

- **Context:** when a new menu page is opened, focus should follow the current task and avoid resetting to an unrelated first control.
- **Choice:** focus Audio & Display or Controls when its Settings view opens. Focus Next on each tutorial page and Done on the last page.
- **Consequence:** mouse, keyboard, and gamepad users can continue with the visible page. Previous and Skip remain in the regular navigation order. See [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md).

## TD-012 — Keep one Settings shell throughout each visit

- **Context:** rebuilding Settings when changing tabs replayed the page fade and caused a visible flash. Treating Controls as a separate navigation level also made Back return to Audio & Display unexpectedly.
- **Choice:** instantiate the card, header, tab buttons, scroll container, and footer once per visit. Replace only the inner tab content; selecting the current tab retains its content and scroll. Update display mode in place. Back, Escape, and B return directly to the main menu from either tab.
- **Consequence:** outgoing content controls must be removed from the focus registry. Tabs, arrows, and LB/RB are the explicit section-switching controls. Apply the page entrance fade only when entering Settings from another screen.

## TD-013 — Keep one fixed tutorial card throughout each visit

- **Context:** changing tutorial steps should not resize or reconstruct the card, and a Previous button is unnecessary because the player can reopen Tutorial from the main menu.
- **Choice:** size one persistent card to fit the current step with the most content, including the largest miniature board. Replace only the page text and diagram when advancing. Provide Next/Done and Skip; omit Previous. Reopening Tutorial starts at the first step.
- **Consequence:** all tutorial steps keep the same layout and Next/Done receives focus after every step change. When tutorial content changes, update the fixed height to continue fitting the largest step. See [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md).

## TD-014 — Reveal board illumination as a quick outward wave

- **Context:** placing or removing a bulb changes several cell-light states at once, and the user selected a synchronized visual response.
- **Choice:** pop the bulb in or shrink it away, then reveal newly lit cells outward along all four rays with 30 ms between cell distances and a 120 ms color fade. Withdraw light from the farthest changed cells inward on removal. Walls stop rays; cells that remain lit by another bulb do not transition.
- **Consequence:** evaluation and input remain immediate. Presentation animation stays inside the board-cell controls and uses editor-adjustable tuning values. See [`the board bulb animation candidate`](concepts/animations/board-bulb-candidate-02.md).
