# Architecture

## Principle

Game rules and data should be understandable and verifiable without depending on the graphical interface. Presentation reads game state and forwards player actions; it is not the source of truth for the rules.

## Conceptual layers

1. **Level configuration:** concrete generation parameters, initially width, height, target wall count, and seed. Resolve these from a predefined difficulty preset selected by the player or assigned to a level, together with the chosen seed policy.
2. **Board definition:** dimensions and immutable structural content, such as empty cells and numbered or unnumbered walls.
3. **Game state:** mutable player choices and derived data needed to evaluate the current situation.
4. **Presentation:** Godot scenes and controls that draw the board and translate input into game actions.
5. **Generation:** creation of a valid board definition from configuration, independent of the visual scene.

## Planned organization

Code in [`../src/`](../src/) should grow with actual needs, avoiding unused abstractions. An initial division might use `core/` for rules and models, `generation/` for procedural creation, and `presentation/` for scenes and interaction.

## Data flow

Difficulty preset and seed policy → resolved level configuration → generator → board definition → initial game state → presentation. Player actions update game state; rules calculate illumination, conflicts, and victory.

## Current implementation

- `src/core/board_definition.gd`: structural dimensions, wall positions, and clue values. Symbols are `.` for playable cells, `#` for unnumbered walls, and digits 0–4 for numbered walls.
- `src/core/game_state.gd`: mutable bulb/annotation placement and rule evaluation, independent from scene nodes.
- `src/generation/level_configuration.gd`: validated, resolved generation parameters and reproduction metadata, independent from the board and player state.
- `src/generation/board_generator.gd`: local seeded randomness, constructive solution, clue derivation, and final validity check.
- `src/levels/prototype_levels.gd`: stable IDs, preset parameters, and explicit seeds for the three playable levels.
- `src/levels/easy_fixed.gd`: the original manually authored 5×5 board, retained as a core-test fixture.
- `src/presentation/main.gd`: menu/game flow, input actions, audio, and rendering updates.
- `src/presentation/board_cell.gd`: individual cell drawing and mouse events, including hover and conflict indicators.
- `src/presentation/lumen_theme.gd`: shared colors, typography, and control styling.

Opening a difficulty resolves its catalog configuration, generates and validates a board, and creates a fresh game state. The controller retains configuration metadata but discards the construction solution. Restart resets the existing game state and does not regenerate the board. Cell visuals scale to keep the three board sizes inside the same board frame.

After a player action, the controller evaluates the whole small board and refreshes its views. Winning is derived from the rules, not from comparison against a stored bulb arrangement.
