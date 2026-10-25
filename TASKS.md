# Project Tasks

This is the project-level backlog. Keep entries actionable, ordered by priority, and aligned with [`docs/REFINEMENT_PLAN.md`](docs/REFINEMENT_PLAN.md).

## In progress

- [ ] Plan, prototype, and implement animations for the background, game title, and board bulbs. Preserve the calm visual style and interface readability; review the proposed implementation and visual results with the user before final integration.
  - [ ] Identify which parts of the existing artwork need separate layers or additional assets for animation, and define their placement and timing.
  - [x] Prototype and approve the decorative lamp's gentle light variation. Candidate 01 was approved by the user on 2026-10-25; see [`lamp-light-candidate-01.md`](docs/concepts/animations/lamp-light-candidate-01.md).
  - [ ] Integrate the approved lamp light candidate into Godot, preserving its alignment under background cover/crop and resizing.
  - [x] Prototype and approve the sleeping cat's subtle breathing. Candidate 01 was approved on 2026-10-25 at 75% intensity with a 4.8-second cycle; see [`cat-breathing-candidate-01.md`](docs/concepts/animations/cat-breathing-candidate-01.md).
  - [ ] Prepare the clean background layer and integrate the approved cat breathing into Godot at 75% intensity, preserving the head/paw positions and alignment under resizing.
  - [x] Prototype and approve an occasional ear-only twitch for the sleeping cat. The corrected candidate was approved on 2026-10-25 at 150% ear intensity, retaining 75% breathing and 8–15-second rests; see [`cat-ear-candidate-01.md`](docs/concepts/animations/cat-ear-candidate-01.md).
  - [ ] Integrate the approved ear-only twitch into Godot without deforming the body, preserving its 150% intensity preset and intermittent timing.
  - [x] Prepare editor-adjustable intensity presets with GDScript `@export` properties: lamp 100%, cat breathing 75%, and cat ear 150%. See `assets/animations/animation_tuning.tres`.
  - [ ] Wire integrated animation controllers to the exported intensity presets so changes made in the Inspector affect their motion; expose the intensities of subsequent animations in the same way.
  - [x] Prototype and approve occasional outdoor leaf swaying. Candidate 01 was approved on 2026-10-25 at 100% intensity, with four-second breezes and 10–18-second rests; see [`outdoor-leaves-candidate-01.md`](docs/concepts/animations/outdoor-leaves-candidate-01.md).
  - [ ] Integrate the approved foliage behind the window frame and indoor objects so every branch reads as outside the house. Identify all visible outdoor branches in the final background and animate each of them with independent timing, preserving the approved 100% intensity and intermittent motion. Verify placement and occlusion at different window sizes and aspect ratios.
  - [x] Prototype and approve the illuminated game-title startup: three initial flickers with 150 ms gaps, followed immediately by the steady lamp halo at 270% intensity. Play once per application launch, not when returning to the menu. Adjustable values are exported through `@export`; see [`title-startup-candidate-01.md`](docs/concepts/animations/title-startup-candidate-01.md). Approved 2026-10-25.
  - [ ] Integrate the approved title startup into Godot, including first-visible-title timing when the first-launch tutorial appears, and prevent replay on menu returns.
  - [ ] Prototype alternative animations for placing and removing a board bulb. Let the user test and choose the options before adopting the final behavior; keep puzzle feedback and input responsive.
  - [ ] Review the combined motion with the user, tune intensity and timing, and update asset provenance and relevant documentation after approval.

## To do

- [ ] Share a playable build with an external tester, collect their feedback, and decide which suggestions to address. See the later milestone in [`docs/REFINEMENT_PLAN.md`](docs/REFINEMENT_PLAN.md).

## Done

- [x] Refine the overall appearance and gameplay details. Completed 2026-10-25.
  - [x] Define the refinement scope and select Quiet Ink (B) with warm victory sparkles; see [`docs/UI_ASSET_BRIEF.md`](docs/UI_ASSET_BRIEF.md).
  - [x] Replace the prominent white-card menus with the selected full-screen illustrated layout, restored wordmark, sleeping cat, warm room light, typography, and spacing.
  - [x] Make the background cover windowed, maximized, fullscreen, widescreen, and ultrawide layouts.
  - [x] Establish reusable dark translucent buttons with the amber illuminated outline; fit text buttons to their labels and retain 40 px horizontal padding.
  - [x] Refine the circular mute shortcut, center its audio icons, and omit text-button padding.
  - [x] Keep one shared cell selector for mouse and keyboard/gamepad; let navigation select walls while rejecting bulb and X actions there.
  - [x] Show a modal “Puzzle solved!” panel over the dimmed board, with a finite warm sparkle effect and correct next-level actions for numbered and random levels.
  - [x] Remove instructional/status text from below the board, leaving its action buttons.
  - [x] Add a five-page tutorial with board diagrams, first-launch display, persistent seen state, revisiting, Skip, and Next/Done focus.
  - [x] Keep one fixed-size tutorial card across all steps, remove Previous, and focus Next/Done after advancing.
  - [x] Focus the active Settings tab when opening Audio & Display or Controls.
  - [x] Hide the free mouse pointer after three seconds of inactivity or immediately on keyboard/controller use; restore it on mouse activity, focus changes, or game exit. Ignore neutral stick drift and preserve cell-selection handoff.
  - [x] Add a shared dark translucent card around the tutorial, Settings, and full gameplay layout; align the victory panel with the same card family and keep gameplay's horizontal padding compact.
  - [x] Keep the Settings title, tabs, fixed scroll viewport, and Back footer in place; use edge-aligned SVG arrows with LB/RB hints below for tab navigation.
  - [x] Match Settings to the approved prototype with larger typography, separated keycaps, gamepad symbols, device/row rules, fixed geometry, and scrolling only when needed; see [`docs/UI_STYLE_GUIDE.md`](docs/UI_STYLE_GUIDE.md).
  - [x] Inset the tab arrows within the inner Settings card and preserve focus/scroll when changing display mode.
  - [x] Keep the Settings shell instantiated during tab changes and make Back/Escape/B exit directly to the main menu from either tab.
  - [x] Shorten the music-volume slider and separate Back from the other menu choices with the agreed vertical spacing.
  - [x] Harden preferences, stable difficulty IDs, wall selection without interaction, modal victory focus, and integration checks.
  - [x] Run the relevant isolated checks; 731 assertions pass. See [`tests/README.md`](tests/README.md).
  - [x] Update behavior, setup, architecture, asset, and visual-style documentation; add current UI screenshots to the README.
  - [x] Finish the user-led visual/gameplay review of the current build and address the agreed remaining feedback, including the final gameplay card sizing and padding. Completed 2026-10-25.
- [x] Refine the menu structure and level-selection flow. Completed 2026-10-25.
  - [x] Add Start Game, Settings, Tutorial, Quit, and a separate global mute shortcut to the main menu.
  - [x] Offer each registered difficulty and Random Level at the same selection step, then Level 1 through Level 10 for a chosen difficulty.
  - [x] Define ten reproducible, explicitly seeded levels per difficulty with stable IDs.
  - [x] Choose random difficulty uniformly from the registered catalog; retain the active puzzle on Restart and discard its temporary seed on exit/replacement.
  - [x] Offer New Random Level only in random mode; provide the right Next Level behavior at difficulty boundaries and the final registered level.
  - [x] Add local music-volume, global-mute, display-mode, and tutorial-seen preferences; keep effects on the same global mute and provide no remapping or separate effects-volume control.
  - [x] Add a read-only Keyboard/Mouse and Gamepad Controls tab; support mouse, keyboard, and standardized controller focus/navigation.
  - [x] Use Exit to Menu, Escape, and gamepad B to leave gameplay or victory and discard the current session.
  - [x] Set focus to the active Settings tab and to Next/Done on each tutorial page.
  - [x] Verify menu/session behavior with the isolated flow checks; see [`tests/README.md`](tests/README.md).
  - [x] Complete the user-led pass through menu navigation, numbered levels, random generation, and mute/unmute on the current build. Completed 2026-10-25.

- [x] Adapt the approved keyboard interaction to gamepad, add the B/Escape Back shortcut, and support replacing a bulb with X across input methods. Completed 2026-10-24.
- [x] Implement and validate keyboard navigation and gameplay actions. Completed 2026-10-24.
- [x] Fix issues found during prototype testing and confirm the prototype completion criteria. Completed 2026-10-24.
- [x] Define and prioritize improvements based on testing and play feedback. Completed 2026-10-24.
- [x] Test the prototype's rules, generation, controls, and visual clarity. Completed 2026-10-24.
- [x] Implement deterministic procedural generation that guarantees at least one valid solution. Completed 2026-10-24.
- [x] Implement a playable prototype with the core Akari rules, mouse hover, and custom cursors. Completed 2026-10-24.
- [x] Prepare and integrate the initial prototype visuals and audio, including board symbols, cursors, typography, music, and sound effects. See [`docs/ASSET_INVENTORY.md`](docs/ASSET_INVENTORY.md) and [`assets/ASSET_MANIFEST.md`](assets/ASSET_MANIFEST.md). Completed 2026-10-24.
- [x] Set up Godot 4.7.2 and document how to run the project. See [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md). Completed 2026-10-24.
- [x] Define the prototype scope, controls, game flow, difficulty presets, seed policy, and completion criteria. See [`docs/PROTOTYPE_DEFINITION.md`](docs/PROTOTYPE_DEFINITION.md). Completed 2026-10-24.
- [x] Improve the project definition, working agreements, and repository map in `AGENTS.md`. Completed 2026-10-23.
