# Project Overview

## Concept

Project Lumen is a 2D logic game based on Akari, also known as Light Up. The player places bulbs in empty cells to illuminate the board while satisfying numbered wall clues and ensuring that no two bulbs illuminate each other.

## First-version goal

Build a small, playable prototype with a readable board, basic interaction, verifiable rules, and reproducibly generated levels. The initial presentation may use simple shapes and colors; themed art comes after the core game is sound.

## Initial scope

- Represent walls, numbered walls, empty cells, and bulbs.
- Allow players to place and remove bulbs.
- Calculate illumination and detect bulb conflicts.
- Check numbered clues and the win condition.
- Generate a level from width, height, target wall count, and seed, ensuring at least one valid solution.
- Resolve generation parameters from predefined difficulty presets, either selected by the player or assigned to a level. Exact presets and the prototype's entry flow remain to be defined.
- Allow multiple solutions in the first version.

## Out of scope for the first version

- Guaranteeing a unique solution.
- An advanced solver or difficulty optimization.
- Progression, rankings, online publishing, and final art.

## Vocabulary

- **Level:** parameters and starting content for a puzzle.
- **Level configuration:** width, height, target wall count, and seed.
- **Difficulty preset:** predefined generation parameters used to resolve a level configuration. A preset may be selected by the player or assigned to a level.
- **Board definition:** structural arrangement of cells and clues.
- **Game state:** placed bulbs, derived illumination, and player progress.
