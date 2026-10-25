# Architecture

## Principle

Game rules and data should be understandable and verifiable without depending on the graphical interface. Presentation reads game state and forwards player actions; it is not the source of truth for the rules.

## Conceptual layers

1. **Level catalog and configuration:** an ordered catalog stores stable difficulty IDs, generation parameters, and ten fixed seeds per difficulty. It resolves numbered levels and progression targets; random sessions use a selected preset plus a temporary seed.
2. **Board definition:** dimensions and immutable structural content, such as empty cells and numbered or unnumbered walls.
3. **Game state:** mutable player choices and derived data needed to evaluate the current situation.
4. **Presentation:** Godot scenes and controls that draw the board and translate input into game actions.
5. **Generation:** creation of a valid board definition from configuration, independent of the visual scene.

## Planned organization

Code in [`../src/`](../src/) should grow with actual needs, avoiding unused abstractions. An initial division might use `core/` for rules and models, `generation/` for procedural creation, and `presentation/` for scenes and interaction.

## Data flow

Difficulty preset and seed policy → resolved level configuration → generator → board definition → initial game state → presentation. Player actions update game state; rules calculate illumination, conflicts, and victory.

## Current implementation

- `src/levels/prototype_levels.gd` is the ordered difficulty catalog used by the difficulty menu, uniform random selection, numbered-level selection, and cross-difficulty progression. Each current difficulty contains ten fixed seed entries.
- `src/presentation/player_preferences.gd` loads and saves music volume, global mute, fullscreen mode, and tutorial-seen state under `user://player_settings.cfg`. It does not store puzzle state or random seeds.

- `src/core/board_definition.gd`: structural dimensions, wall positions, and clue values. Symbols are `.` for playable cells, `#` for unnumbered walls, and digits 0–4 for numbered walls.
- `src/core/game_state.gd`: mutable bulb/annotation placement and rule evaluation, independent from scene nodes.
- `src/generation/level_configuration.gd`: validated, resolved generation parameters, stable difficulty ID, and reproduction metadata, independent from the board and player state.
- `src/generation/board_generator.gd`: local seeded randomness, constructive solution, clue derivation, and final validity check.
- `src/levels/prototype_levels.gd`: stable difficulty IDs, preset parameters, and explicit seeds for ten levels in each of three difficulties.
- `src/levels/easy_fixed.gd`: the original manually authored 5×5 board, retained as a core-test fixture.
- `src/presentation/main.gd`: main menu, difficulty/level selection, settings, tutorial, gameplay, victory flow, audio, input routing, mouse visibility switching, and responsive rendering.
- `src/presentation/board_cell.gd`: individual cell drawing and mouse events, including hover and conflict indicators.
- `src/presentation/lumen_theme.gd`: shared board palette, Quiet Ink typography, editable control states, and reusable surfaces.
- `src/presentation/victory_sparkles.gd`: finite textured light animation, independent of game rules and input.
- `src/input/input_bindings.gd`: named keyboard and standardized gamepad actions installed into Godot's InputMap.
- `src/input/board_navigation.gd`: input-independent one-cell movement across all board positions, including walls, and transitions to the button row. Game state separately rejects actions on walls.
- `src/input/gamepad_state.gd`: per-device D-pad/left-stick state and a stable cardinal direction.
- `src/input/cell_action_guard.gd`: monotonic, per-action/per-cell controller bounce filtering, independent from game rules and scene nodes.
- `src/input/direction_repeat.gd`: bounded held-direction repeat, independent from frame timing and scene focus.

Opening a numbered level resolves its fixed catalog configuration; random selection chooses a registered difficulty and creates a temporary seed. Both paths generate and validate a board and create a fresh game state. The controller retains active configuration metadata but discards the construction solution. Random configuration is memory-only and is cleared on return to the main menu. Restart resets the existing game state and does not regenerate the board. Cell visuals scale to keep the three board sizes inside the same board frame.

Bulb and annotation actions replace each other in a single state mutation. Walls reject both actions, and the presentation blocks board changes after victory. Mouse, keyboard, and gamepad share these actions and navigation handlers; see [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md).

After a player action, the controller evaluates the whole small board and refreshes its views. Winning is derived from the rules, not from comparison against a stored bulb arrangement.

Settings creates its shell once per visit. Tab changes replace only the inner content, refresh the existing tab highlights, and remove outgoing content controls from directional navigation. The shell, header, scroll container, and footer retain their instances without a new entrance fade. Display-mode changes update the existing button in place. Back, Escape, and B exit directly to the main menu from either Settings tab.
