# Project Tasks

This is the project-level task list. Keep entries actionable, ordered by priority, and update their status as work progresses.

Tasks are intentionally broad at this stage. Break them into smaller steps when work begins and adjust their order as the prototype evolves.

See [`docs/REFINEMENT_PLAN.md`](docs/REFINEMENT_PLAN.md) for execution order, confirmed behavior, dependencies, review checkpoints, and completion criteria. Asset production is specified in [`docs/UI_ASSET_BRIEF.md`](docs/UI_ASSET_BRIEF.md).

## To do

- [ ] Refine the overall appearance and gameplay details.
  - [ ] Review the current game together and define the refinement scope and priorities.
  - [ ] Redesign menu presentation and button visuals, replacing the current prominent white-card treatment.
  - [ ] Consult the user before creating or reworking interface and celebration assets so they can switch the execution model; follow [`docs/UI_ASSET_BRIEF.md`](docs/UI_ASSET_BRIEF.md) and approve the visual direction before production.
  - [ ] Refine visual consistency, typography, colors, spacing, and screen layouts after the menu direction is approved.
  - [ ] Fix maximized-window and fullscreen layouts so the background expands to fill the available screen area.
  - [ ] Improve board readability, cell states, cursor behavior, and interaction feedback.
  - [ ] Show a centered victory panel with "Puzzle solved!" over the completed, slightly dimmed board.
  - [ ] Offer Next Level, Restart, and Exit to Menu after a numbered-level victory; advance from the last level of a difficulty to the first level of the next registered difficulty, hiding Next Level only after the final level of the final difficulty.
  - [ ] Offer New Random Level, Restart, and Exit to Menu after a random-level victory.
  - [ ] Remove the informational text below the board, leaving only the action buttons in that area.
  - [ ] Develop a short paginated tutorial with small illustrated boards covering the goal, illumination, numbered walls, conflicts, bulb placement/removal, and X annotations.
  - [ ] Show the tutorial automatically on the first game launch and provide a Tutorial entry in the main menu for later review.
  - [ ] Mark the tutorial as seen as soon as it opens and persist that flag locally alongside player preferences, even if the player skips it or closes the game.
  - [ ] Add a Skip button to leave the tutorial and return to the main menu.
  - [ ] Use simple screen transitions and add a victory celebration with confetti or simple fireworks after visual approval; refine interface animation and existing audio balance.
  - [ ] Adjust agreed gameplay and navigation details based on playtesting feedback.
  - [ ] Validate the refinements together and update the documentation.
- [ ] Refine the menu structure and level-selection flow.
  - [ ] Create a main menu with Start Game, Settings, Tutorial, and Quit options.
  - [ ] Add a separate mute/unmute shortcut in a corner of the main menu that silences all audio and restores the previous volumes when unmuted.
  - [ ] Make Start Game open a selection screen with Easy, Medium, Hard, and Random Level.
  - [ ] After difficulty selection, open a level-selection screen with Level 1 through Level 10.
  - [ ] Define ten reproducible levels per difficulty, each with its own stable ID and explicit seed.
  - [ ] Make Random Level choose uniformly from all registered difficulty presets and generate a new puzzle using the chosen preset; new difficulties must join the draw without changing selection logic.
  - [ ] Keep the current difficulty, seed, and board when restarting a random level, clearing only player moves.
  - [ ] Add a New Random Level button only in random mode that draws a new difficulty and generates a new board.
  - [ ] Keep the random seed hidden and only in memory for the active level session; discard it when leaving or replacing the level, without saving a seed history.
  - [ ] Add a music volume setting without a separate sound-effects volume control.
  - [ ] Add a windowed/fullscreen setting and save the chosen mode between sessions.
  - [ ] Add a Controls tab in Settings listing keyboard/mouse and gamepad commands without remapping.
  - [ ] Automatically save and restore music volume, global mute, and display mode between sessions.
  - [ ] Use Exit to Menu during gameplay and victory; the button, Escape, and gamepad B return to the main menu and discard all player moves and the temporary random seed, with no session resume.
  - [ ] Provide clear Back navigation and support the approved input methods throughout the menu flow.
  - [ ] Validate menu navigation, numbered levels, random generation, and mute/unmute behavior.
- [ ] Share a playable build with an external tester, collect their feedback, and decide which suggestions to address.

## In progress

- [ ] Refine the overall appearance and gameplay details.
  - [x] Add the responsive screen flow, local preferences, tutorial, numbered/random session behavior, victory actions, and simple screen fades.
  - [ ] User-review the implemented behavior and visuals; replace the current menu/button treatment and add the approved victory celebration after the visual-asset checkpoint.
  - [ ] Complete the remaining visual refinement, playtest feedback, documentation review, and approval.
- [ ] Refine the menu structure and level-selection flow.
  - [x] Add main menu, difficulty and numbered-level selection, Settings/Controls, first-launch tutorial, uniform random-level selection, and session discard/restart behavior.
  - [ ] User-test navigation, preferences, and progression; adjust issues and approve the finished task.

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
