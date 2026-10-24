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

## Current fixed-board implementation

- `src/core/board_definition.gd`: structural dimensions, wall positions, and clue values. Symbols are `.` for playable cells, `#` for unnumbered walls, and digits 0–4 for numbered walls.
- `src/core/game_state.gd`: mutable bulb/annotation placement and rule evaluation, independent from scene nodes.
- `src/levels/easy_fixed.gd`: manually authored 5×5 board with five walls. No seed or generator is used for this intermediate fixture.
- `src/presentation/main.gd`: menu/game flow, input actions, audio, and rendering updates.
- `src/presentation/board_cell.gd`: individual cell drawing and mouse events, including hover and conflict indicators.
- `src/presentation/lumen_theme.gd`: shared colors, typography, and control styling.

After a player action, the controller evaluates the whole small board and refreshes its views. Winning is derived from the rules, not from comparison against a stored bulb arrangement. Procedural generation and its configuration layer will be introduced in their own task.
