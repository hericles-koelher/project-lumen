# Project Lumen

Development codename for a 2D Akari (Light Up) game built with Godot.

The project starts as a functional prototype with game logic separated from presentation and deterministic procedural level generation. See [`AGENTS.md`](AGENTS.md) for working conventions and the documentation index.

## Status

A playable fixed-board prototype is available in Godot 4.7.2. Easy opens a 5×5 Akari puzzle with lighting, clue checks, conflict feedback, annotations, restart, menu navigation, victory detection, music, and sound effects. Medium and Hard are disabled in this incremental build; procedural generation is a separate upcoming task.

## Run the project

Open `project.godot` in Godot 4.7.2 and press F5. See [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md) for setup and assistant connection details.

Left-click to place or remove a bulb; right-click an open cell to toggle an X annotation. Restart clears the current puzzle, and returning to a level always starts a clean session.
