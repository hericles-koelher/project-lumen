# Project Lumen

Development codename for a 2D Akari (Light Up) game built with Godot.

The project starts as a functional prototype with game logic separated from presentation and deterministic procedural level generation. See [`AGENTS.md`](AGENTS.md) for working conventions and the documentation index.

## Status

The Godot 4.7.2 prototype now has a main menu, Settings, a first-launch/revisitable tutorial, ten seeded levels per difficulty (Easy 5×5, Medium 7×7, Hard 9×9), and Random Level. It includes lighting, clue checks, conflict feedback, annotations, restart, progression, victory actions, music, and sound effects. Generated boards have at least one valid solution and may have multiple solutions. Menu and celebration art are still awaiting the agreed visual-production checkpoint.

## Run the project

Open `project.godot` in Godot 4.7.2 and press F5. See [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md) for setup and assistant connection details.

Left-click to place or remove a bulb; right-click a playable cell to toggle an X annotation. Marking a cell containing a bulb replaces that bulb with X. The same replacement applies to the keyboard and gamepad annotation action. Restart clears moves while preserving the active board. Exit to Menu discards the current session; opening a numbered level again starts it clean.

Keyboard: move with arrows or WASD, toggle a bulb with Space, and toggle an X annotation with X. Move down from the last row to the action buttons; left/right changes buttons and up returns to the remembered cell. Enter or Space activates a focused button. See [`docs/INPUT_CONTROLS.md`](docs/INPUT_CONTROLS.md).

Gamepad: use the D-pad or left stick, A to toggle a bulb or confirm a button, X to toggle an annotation, and B to return from a submenu or exit gameplay to the main menu. Keyboard Escape performs the same Back action. These button names follow Xbox positions on recognized controllers. The user tested and approved Xbox navigation, actions, and bulb-to-X replacement on 2026-10-24. Generic controller hardware has not yet been tested.
