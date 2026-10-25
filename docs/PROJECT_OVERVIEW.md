# Project Overview

## Concept

Project Lumen is a 2D logic game based on Akari, also known as Light Up. The player places bulbs in empty cells to illuminate the board while satisfying numbered wall clues and ensuring that no two bulbs illuminate each other.

## First-version goal

Build a small, playable prototype with a readable board, basic interaction, verifiable rules, and reproducibly generated levels. The core is implemented; the current themed interface and remaining user review are summarized in [`../TASKS.md`](../TASKS.md).

## Initial scope

- Represent walls, numbered walls, empty cells, and bulbs.
- Allow players to place and remove bulbs and X annotations using mouse, keyboard, or gamepad; either action replaces the other symbol when present.
- Calculate illumination and detect bulb conflicts.
- Check numbered clues and the win condition.
- Generate a level from width, height, target wall count, and seed, ensuring at least one valid solution.
- Resolve generation parameters from predefined difficulty presets, either selected by the player or assigned to a level. The approved presets and entry flow are recorded in [`PROTOTYPE_DEFINITION.md`](PROTOTYPE_DEFINITION.md).
- Allow multiple solutions in the first version.

## Deliberately deferred

- Guaranteeing a unique solution, an advanced solver, or automatic difficulty optimization.
- Saved level completion/progress, rankings, accounts, and online publishing.
- Export and distribution for the separate external-playtest milestone.

## Vocabulary

- **Level:** parameters and starting content for a puzzle.
- **Level configuration:** width, height, target wall count, and seed.
- **Difficulty preset:** predefined generation parameters used to resolve a level configuration. A preset may be selected by the player or assigned to a level.
- **Board definition:** structural arrangement of cells and clues.
- **Game state:** placed bulbs, derived illumination, and player progress.
