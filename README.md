# Project Lumen

Development codename for a 2D Akari (Light Up) game built with Godot.

The project starts as a functional prototype with game logic separated from presentation and deterministic procedural level generation. See [`AGENTS.md`](AGENTS.md) for working conventions and the documentation index.

## Status

A playable prototype is available in Godot 4.7.2 with one reproducibly generated puzzle per difficulty: Easy 5×5, Medium 7×7, and Hard 9×9. It includes lighting, clue checks, conflict feedback, annotations, restart, menu navigation, victory detection, music, and sound effects. Generated boards have at least one valid solution and may have multiple solutions.

## Run the project

Open `project.godot` in Godot 4.7.2 and press F5. See [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md) for setup and assistant connection details.

Left-click to place or remove a bulb; right-click an open cell to toggle an X annotation. Restart clears the current puzzle, and returning to a level always starts a clean session.
