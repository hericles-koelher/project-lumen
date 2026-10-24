# Project Lumen

Development codename for a 2D Akari (Light Up) game built with Godot.

The project starts as a functional prototype with game logic separated from presentation and deterministic procedural level generation. See [`AGENTS.md`](AGENTS.md) for working conventions and the documentation index.

## Status

A playable prototype is available in Godot 4.7.2 with one reproducibly generated puzzle per difficulty: Easy 5×5, Medium 7×7, and Hard 9×9. It includes lighting, clue checks, conflict feedback, annotations, restart, menu navigation, victory detection, music, and sound effects. Generated boards have at least one valid solution and may have multiple solutions.

## Run the project

Open `project.godot` in Godot 4.7.2 and press F5. See [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md) for setup and assistant connection details.

Left-click to place or remove a bulb; right-click a playable cell to toggle an X annotation. Marking a cell containing a bulb replaces that bulb with X. The same replacement applies to the keyboard and gamepad annotation action. Restart clears the current puzzle, and returning to a level always starts a clean session.

Keyboard: move with arrows or WASD, toggle a bulb with Space, and toggle an X annotation with X. Move down from the last row to the action buttons; left/right changes buttons and up returns to the remembered cell. Enter or Space activates a focused button. See [`docs/INPUT_CONTROLS.md`](docs/INPUT_CONTROLS.md).

Gamepad: use the D-pad or left stick, A to toggle a bulb or confirm a button, X to toggle an annotation, and B to go back. Keyboard Escape performs the same Back action. These button names follow Xbox positions on recognized controllers. The user tested and approved Xbox navigation, actions, and bulb-to-X replacement on 2026-10-24. Generic controller hardware has not yet been tested.
