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
