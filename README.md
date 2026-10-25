# Project Lumen

Project Lumen is a 2D Akari (Light Up) puzzle game built with Godot 4.7.2. The prototype separates puzzle rules from presentation and uses seeded procedural generation to create boards with at least one valid solution.

## Current status

The project contains three difficulty presets, each with ten reproducible levels, plus a random mode that chooses uniformly among registered difficulties. The game includes a first-launch tutorial, Settings, music and global mute controls, windowed/fullscreen support, mouse/keyboard/gamepad interaction, puzzle feedback, level progression, and a victory screen.

The selected visual direction is Quiet Ink, with a warm illustrated room, hand-lettered title, translucent controls with amber lighting, and a short sparkle celebration on victory. The current UI screenshots appear below. The integrated visual refinements are ready for the user's final playthrough; the external playtest remains a later task. See [`TASKS.md`](TASKS.md) for current status and remaining work.

## Screenshots

| Main menu | Gameplay |
|:--:|:--:|
| ![Main menu](docs/screenshots/main-menu.png) | ![Gameplay](docs/screenshots/gameplay.png) |
| Settings — Controls | Tutorial |
| ![Settings Controls tab](docs/screenshots/settings-controls.png) | ![Tutorial](docs/screenshots/tutorial.png) |

### Victory

![Victory panel and sparkle effect](docs/screenshots/victory.png)

These captures show the current integrated screens at 1152 × 800. They are generated from an isolated Godot scene and do not interrupt an open play session. See [`docs/UI_STYLE_GUIDE.md`](docs/UI_STYLE_GUIDE.md) for visual details and scaling behavior.

## Run the project

Open `project.godot` in Godot 4.7.2 and press F5. The configured main scene is `src/presentation/main.tscn`. See [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md) for setup and the development-tool connection.

## Play

Left-click a playable cell to place or remove a bulb. Right-click toggles an X note; marking a bulb replaces it with X. The goal is to illuminate every playable cell, avoid bulb conflicts, and satisfy every numbered wall. The tutorial explains the rules in game.

- **Keyboard:** arrows or WASD navigate; Space toggles a bulb; X toggles a note; Enter/Space activates a focused button; Escape returns to the main menu from gameplay or victory.
- **Gamepad:** D-pad or left stick navigates; A toggles a bulb or confirms; X toggles a note; B backs out of a submenu or exits gameplay to the main menu.
- **Mouse:** pointer movement or a click shows the pointer again. It hides after three seconds of inactivity or when another input method is used.

Restart clears player moves and keeps the current board. Exit to Menu discards the active session. Music volume, global mute, display mode, and the tutorial-seen state are saved locally. Puzzle progress and random seeds are not saved. See [`docs/INPUT_CONTROLS.md`](docs/INPUT_CONTROLS.md) for the full control and navigation reference.

## Project guide

- [`AGENTS.md`](AGENTS.md) — working conventions and repository index.
- [`TASKS.md`](TASKS.md) — completed work, current user-review checkpoints, and the external-playtest task.
- [`docs/PROJECT_OVERVIEW.md`](docs/PROJECT_OVERVIEW.md) and [`docs/PROTOTYPE_DEFINITION.md`](docs/PROTOTYPE_DEFINITION.md) — project scope and agreed prototype behavior.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — code responsibilities and data flow.
- [`docs/REFINEMENT_PLAN.md`](docs/REFINEMENT_PLAN.md) — implementation status, work packages, review checkpoints, and later playtest milestone.
- [`docs/PROCEDURAL_GENERATION.md`](docs/PROCEDURAL_GENERATION.md) — difficulty presets, seeds, validity, and reproducibility.
- [`docs/UI_STYLE_GUIDE.md`](docs/UI_STYLE_GUIDE.md) and [`docs/UI_ASSET_BRIEF.md`](docs/UI_ASSET_BRIEF.md) — current Quiet Ink implementation and its visual-production decisions.
- [`assets/ASSET_MANIFEST.md`](assets/ASSET_MANIFEST.md) — asset sources and licenses.
- [`tests/README.md`](tests/README.md) — automated verification and manual-review coverage.
