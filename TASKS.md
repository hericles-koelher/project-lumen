# Project Tasks

This is the project-level task list. Keep entries actionable, ordered by priority, and update their status as work progresses.

Tasks are intentionally broad at this stage. Break them into smaller steps when work begins and adjust their order as the prototype evolves.

## To do

- [ ] Implement the selected improvements.
- [ ] Test the improvements and update the project documentation and task list.
- [ ] Refine the overall appearance and gameplay details.
  - [ ] Review the current game together and define the refinement scope and priorities.
  - [ ] Refine visual consistency, typography, colors, spacing, and screen layouts.
  - [ ] Fix maximized-window and fullscreen layouts so the background expands to fill the available screen area.
  - [ ] Improve board readability, cell states, cursor behavior, and interaction feedback.
  - [ ] Make the victory state more noticeable and clearly communicate that the puzzle is solved.
  - [ ] Remove the informational text below the board, leaving only the action buttons in that area.
  - [ ] Develop a short tutorial explaining the goal, Akari rules, bulb placement/removal, and X annotations.
  - [ ] Refine transitions, animations, sound effects, and music balance.
  - [ ] Adjust agreed gameplay and navigation details based on playtesting feedback.
  - [ ] Validate the refinements together and update the documentation.
- [ ] Refine the menu structure and level-selection flow.
  - [ ] Create a main menu with Start Game, Settings, and Quit options.
  - [ ] Add a separate, clearly visible mute/unmute shortcut in a corner of the main menu.
  - [ ] Make Start Game open a difficulty-selection screen with Easy, Medium, and Hard.
  - [ ] After difficulty selection, open a level-selection screen with Level 1 through Level 10.
  - [ ] Define ten reproducible levels per difficulty, each with its own stable ID and explicit seed.
  - [ ] Add a Random Level option that generates a new puzzle using the selected difficulty's parameters.
  - [ ] Define seed handling, replay, and restart behavior for random levels.
  - [ ] Define the Settings options and which preferences should persist between sessions.
  - [ ] Provide clear Back navigation and support the approved input methods throughout the menu flow.
  - [ ] Validate menu navigation, numbered levels, random generation, and mute/unmute behavior.

## In progress

No tasks currently in progress.

## Done

- [x] Adapt the approved keyboard interaction to gamepad, add the B/Esc Back shortcut, and support replacing a bulb with X across input methods. Completed on 2026-10-24.

- [x] Implement and validate keyboard navigation and gameplay actions. Completed on 2026-10-24.

- [x] Fix issues found during testing and confirm the prototype meets its completion criteria. Completed on 2026-10-24.

- [x] Define and prioritize improvements based on testing and play feedback. Completed on 2026-10-24.

- [x] Test the prototype, covering game rules, generation, controls, and visual clarity. Completed on 2026-10-24.

- [x] Implement deterministic procedural generation that guarantees at least one valid solution. Completed on 2026-10-24.

- [x] Implement a playable prototype with a small fixed board and the core Akari rules, integrating the approved assets and mouse hover/cursor states. Completed on 2026-10-24.

- [x] Prepare the prototype visual and audio assets, including board symbols, mouse cursors, hover indicator, typography, music, and sound effects. The user approved the visual direction and selected the music. See [`docs/ASSET_INVENTORY.md`](docs/ASSET_INVENTORY.md) and [`assets/ASSET_MANIFEST.md`](assets/ASSET_MANIFEST.md). In-game integration remains part of prototype implementation. Completed on 2026-10-24.

- [x] Set up the Godot project and document the chosen engine version and how to run it. Godot 4.7.2 and MCP Toolkit 1.0.4; main scene launched successfully through the plugin. See [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md). Completed on 2026-10-24.

- [x] Define the prototype details: scope, target platform, controls, game flow, difficulty presets, seed policy, and completion criteria. See [`docs/PROTOTYPE_DEFINITION.md`](docs/PROTOTYPE_DEFINITION.md). Completed on 2026-10-24.

- [x] Improve the project definition and refine `AGENTS.md` so the project goals, scope, working conventions, and repository map are clear and consistent. Completed on 2026-10-23.
