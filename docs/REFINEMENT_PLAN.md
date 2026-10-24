# Project Lumen — Refinement Execution Plan

Status: implementation underway on 2026-10-24. The functional menu, level catalog, preferences, tutorial, session flow, victory actions, responsive background, and basic screen fades are implemented; automated checks pass. Manual user review and the gated visual-asset work remain. This plan covers the appearance/gameplay refinements and the menu/level-flow refinements in [`../TASKS.md`](../TASKS.md). External playtesting is a later, separate milestone.

The confirmed behavior below comes from user decisions. Implementation details may be resolved autonomously within this scope. New visual production requires consulting the user so they can switch the execution model and approve the direction described in [`UI_ASSET_BRIEF.md`](UI_ASSET_BRIEF.md).

## 1. Goals and preserved foundations

- Replace the current direct-to-difficulty menu with a complete menu, level-selection, Settings, and Tutorial flow.
- Provide ten fixed, reproducible levels for each registered difficulty and a random mode that can include future difficulties automatically.
- Save player preferences and first-launch tutorial state while continuing to discard puzzle sessions on exit.
- Improve resizing, victory feedback, interface consistency, and visual clarity through the approved replacement assets.
- Preserve the Akari rules, constructive generator validity, multiple-solution policy, explicit seeds/generator version, and separation of configuration, board definition, and mutable game state.
- Preserve mouse/keyboard/gamepad actions, the shared cell marker, synchronized input selection, wall-skipping navigation, and board-to-button focus transitions.
- Keep all first-party code, comments, documentation, labels, and commit messages in English. Document new and changed GDScript declarations according to [`ENGINEERING_PRACTICES.md`](ENGINEERING_PRACTICES.md).

## 2. Confirmed screen flow

| Entry | Destination / behavior |
|---|---|
| First launch | Open Tutorial and immediately save that it has been seen. Closing or skipping it does not trigger another automatic presentation. |
| Later launch | Open the main menu with saved preferences applied. |
| Main menu | Start Game, Settings, Tutorial, Quit, and a separate corner mute/unmute shortcut. |
| Start Game | Show all registered difficulties, currently Easy/Medium/Hard, plus Random Level at the same hierarchy. |
| A difficulty | Open its numbered-level selection with Level 1 through Level 10. |
| A numbered level | Start a clean instance of that level's fixed puzzle. |
| Random Level | Select uniformly from all registered difficulties and generate a puzzle from the chosen preset with a fresh session seed. |
| Settings | Music volume, windowed/fullscreen choice, and a Controls reference tab for Keyboard / Mouse and Gamepad. No remapping interface. |
| Tutorial from menu | Open the tutorial from its beginning for review. |
| Exit to Menu during gameplay or victory | Return to the main menu, discarding all moves, board-session state, and the temporary random seed. Escape and gamepad B perform the same action. |

Ordinary menu Back navigation returns to the parent screen. At the main menu, Escape/B does not quit. During a puzzle or its victory panel, Exit to Menu always goes directly to the main menu. Quit is available from the main menu; gameplay offers Restart and Exit to Menu.

## 3. Work packages and execution order

The packages below divide the two parent tasks into reviewable changes. They define dependency order; the asset package can be scheduled earlier when the user is ready to switch models, but it must not delay independent functional work.

### Package 1 — Difficulty and numbered-level catalog

**Work**

- Represent difficulties as an ordered catalog of stable IDs and preset parameters. Menus, random selection, and next-difficulty progression must consume that catalog instead of duplicating a hard-coded list.
- Create ten levels per difficulty, each with its own stable ID and explicit fixed seed. Preserve the existing first-level IDs, seeds, and puzzles where the generator/configuration is unchanged.
- Keep the current Easy 5×5/5 walls, Medium 7×7/10 walls, and Hard 9×9/16 walls, with the current 70% numbered-wall rule rounded down.
- Separate the difficulty preset, numbered-level identity, and resolved generation configuration. Continue recording generator version for fixed-level reproduction.
- Make all ten numbered levels selectable; do not add locks or saved completion tracking.
- Resolve Next Level from catalog order: advance within a difficulty, then to the first level of the next difficulty; return no next target only at the final level of the final difficulty.

**Dependencies:** none beyond the current generator and level model.

**Done when:** all catalog entries resolve correctly, fixed puzzles remain reproducible and valid, and adding a difficulty to the catalog makes it available to the relevant consumers without editing their selection logic.

### Package 2 — Preferences and audio/display settings

**Work**

- Add one small local settings store under Godot's user-data location. Use the native configuration format; a database service is unnecessary for these values.
- Save music volume, global mute, windowed/fullscreen mode, and the tutorial-seen flag. Automatically load on startup and save when a preference changes.
- Keep reasonable defaults for a missing settings file and handle missing/invalid individual values without losing other valid preferences.
- Control music volume independently while leaving effects at their existing configured volume. Provide no separate effects-volume slider.
- Implement global mute without overwriting the stored music level or other audio volumes; unmuting restores them. Persist mute across launches.
- Apply windowed/fullscreen changes and save the choice. Preserve ordinary window maximization support.
- Keep puzzle moves, random seeds, level completion, and session history out of this settings file.

**Dependencies:** none; the Settings screen will consume this service in Package 4.

**Done when:** preferences take effect immediately, survive reopening the game, and cannot cause a puzzle session to resume.

### Package 3 — Responsive layout and gameplay cleanup

**Work**

- Correct root/container sizing so the background covers the available area in windowed, maximized, and fullscreen modes.
- Keep the board, headings, and buttons usable at each supported board size and the target PC window sizes. Preserve the board's square cell proportions.
- Remove informational text beneath the board, including the controls legend and textual instruction/violation area. Retain direct visual feedback on bulbs and numbered walls. Move the victory presentation to its dedicated overlay in Package 6.
- Keep only action buttons in the area below the board. Retain existing header information above it unless a later visual review calls for a specific change.
- Identify concrete clipping, alignment, contrast, or spacing issues and correct them within the current assets. Do not silently redesign the board symbols or the recently approved shared selector.
- Allow the action-button row and focus model to handle the extra New Random Level action rather than assuming exactly three buttons.

**Dependencies:** Package 2 for testing the integrated display setting; final artwork integration follows Package 8.

**Done when:** resizing does not leave uncovered background or inaccessible controls, all board sizes remain readable, and removed text is not needed to recognize rule violations.

### Package 4 — Main menu, selection screens, and Settings UI

**Work**

- Build the main menu and its corner global-mute shortcut.
- Build Start Game with registered difficulties and Random Level. A difficulty opens its ten numbered-level buttons; Random Level starts a random session directly.
- Build Settings with music volume and display-mode controls and a Controls tab. Keep the control reference grouped into Keyboard / Mouse and Gamepad, using the actual approved actions.
- Support mouse, keyboard, and recognized gamepads for buttons, tabs, selectors, and slider interaction, with visible focus and readable selected states.
- Keep ordinary menu Back navigation coherent. Use Exit to Menu for leaving gameplay and victory; do not route puzzle exits back to the numbered-level screen.
- Initially use existing reusable resources to establish behavior. Final menu/button redesign is integrated only after visual approval.

**Dependencies:** Packages 1 and 2; use Package 3's responsive layout approach.

**Done when:** every screen is reachable and usable with the approved input methods, preferences can be changed, and main-menu mute reflects the current state.

### Package 5 — Random sessions and session lifecycle

**Work**

- Draw a difficulty uniformly from the current catalog, with no fixed probability constants tied to three difficulties. Generate a puzzle using that preset and a fresh seed.
- Keep the seed hidden and in memory only for the active random session. Do not create a seed history, a saved random puzzle, or a seed-entry control.
- Restart clears player choices and derived state while preserving the current difficulty, seed, walls, and clues.
- Show New Random Level only in random mode. It discards the current session, draws a difficulty again, and generates a puzzle; drawing the same difficulty again is valid.
- Exit to Menu, Escape/B, and quitting discard the active session and its random seed. Reopening a numbered level always gives its clean fixed puzzle; choosing Random Level creates a fresh session.
- Make the shared session/navigation code aware of the current mode without duplicating the Akari rules or presentation logic.

**Dependencies:** Packages 1 and 4.

**Done when:** restart and replacement have distinct behavior, random selection automatically includes newly registered difficulties, and no exited session is restored.

### Package 6 — Victory flow and progression

**Work**

- Replace the small victory label with a centered panel saying “Puzzle solved!” over the visible, slightly dimmed completed board.
- Lock board actions while solved. Keep all panel buttons immediately usable through mouse, keyboard, and gamepad.
- For numbered levels, offer Next Level, Restart, and Exit to Menu. Next Level starts a clean puzzle at the catalog's next target, crossing to the next difficulty after a difficulty's final level.
- Omit Next Level only after the final level of the last registered difficulty; do not invent an additional endgame screen or automatic transition.
- For random levels, offer New Random Level, Restart, and Exit to Menu.
- Make Escape/B exit to the main menu from the victory panel. Restart removes the overlay and unlocks the clean current puzzle.
- Trigger victory audio/celebration on entering the solved state, avoiding repeated triggers during redraw or focus changes. Integrate final decoration/effect components after Package 8.

**Dependencies:** Packages 1, 4, and 5; final visual treatment depends on Package 8.

**Done when:** each victory action reaches the expected clean state, final-level boundaries work, and focus cannot return to a locked board.

### Package 7 — Tutorial content and first-launch flow

**Work**

- Build a short paginated tutorial with illustrated miniature boards and concise English text.
- Cover the goal, orthogonal lighting and wall blocking, numbered/zero clues, bulb conflicts, bulb placement/removal, X notes, replacement between bulb/X, and the win condition.
- Use correct Akari examples and the same board symbols as gameplay. Reuse components where possible; request new illustrative assets through Package 8.
- Provide previous/next navigation, a page indicator, and Skip. Finish and Skip lead to the main menu; revisiting from the main menu starts at the first page.
- On a first launch, open the tutorial and persist the seen flag immediately. Do not wait for completion or Skip. Later launches go directly to the main menu even if the first tutorial was interrupted.
- Support the approved input methods and ensure tutorial navigation cannot accidentally place bulbs in the underlying game.

**Dependencies:** Packages 2 and 4; final illustrations/styling depend on Package 8.

**Done when:** a fresh profile sees the tutorial once automatically, interrupted/skipped tutorials stay marked as seen, and manual review remains available from the main menu.

### Package 8 — Visual concepts and asset production

**User checkpoint:** consult the user before creating or reworking interface or celebration assets so they can switch the execution model. Use [`UI_ASSET_BRIEF.md`](UI_ASSET_BRIEF.md) as the production handoff.

**Work**

- Present concepts for menus and buttons that replace the disliked prominent white-card treatment and current button style.
- Agree on composition, palette/font changes if any, icon treatment, state styling, and the victory celebration choice: confetti or simple fireworks.
- Cover all planned screens and reusable components: menu/difficulty/level controls, Settings tabs/slider/selectors, mute icons, control glyphs, tutorial diagrams/navigation, and victory surface/effect components.
- Review concepts before bulk production. Deliver separate reusable artwork, required button/focus states, size/stretch guidance, and a manifest rather than only flattened screen mockups.
- Preserve first-party sources and third-party licenses/provenance when adopted assets are reused or replaced.

**Dependencies:** the agreed screen inventory; functional packages may proceed before art is available.

**Done when:** the user approves a coherent direction and the chosen production model delivers the required components and state references ready for integration.

### Package 9 — Visual integration, motion, and audio balance

**Work**

- Integrate approved art across menus, gameplay controls, tutorial, Settings, and victory. Apply shared theme/font/spacing rules and verify readable labels in every focus/hover/pressed/disabled state.
- Add simple ordinary screen transitions using native animation where suitable. Choose restrained timings and easing during implementation without delaying controls or puzzle feedback.
- Add interface animation and the approved finite victory effect. Keep confetti/fireworks from hiding the board's result or panel actions; effects do not intercept input or delay progression.
- Keep the background adaptive to window changes and avoid stretching decorative corners or baked text.
- Review board readability, overlapping states, marker centering, input handoff, and cursor feedback; make specific corrections supported by the approved direction and playtesting feedback.
- Balance the existing music/effects and preserve music continuity between screens. Do not add a new soundtrack or extra sound-production task without an agreed need.

**Dependencies:** Packages 3–8 and the approved asset family.

**Done when:** the complete flow shares the approved visual language, ordinary transitions remain simple, victory is clear and celebratory, and all interactions remain responsive.

### Package 10 — Verification, user review, and documentation

**Work**

- Update outdated automated checks when behavior changes, especially old assumptions that directional navigation lands on walls. Keep domain/input checks isolated from the user's running play session.
- Verify catalog reproduction, next-level/next-difficulty boundaries, inclusion of newly registered difficulties, random restart/replacement, and session disposal.
- Verify preference loading/saving, global mute/restored volume, display mode, tutorial seen-on-open, and clean first/subsequent launch paths.
- Check all UI states through the implemented focus model. Leave manual visual/gamepad playtesting to the user and coordinate before stopping or restarting an active play session.
- Address concrete issues reported during review within the agreed scope; ask about changes that introduce new design decisions.
- Update current behavior documents, architecture/source maps, setup instructions, controls, asset inventory/manifest, and task status so completed features are distinguishable from remaining plans.
- Keep `TASKS.md` concise; retain implementation reasoning and review results in the relevant documents or chat.
- After approval of each completed package/task, create a coherent English commit. Push only when explicitly requested.

**Dependencies:** validate each package locally as it is completed; final end-to-end review follows Package 9.

**Done when:** relevant automated checks pass, the user approves manual behavior/presentation, documentation describes the delivered game, and approved work is committed.

## 4. Later milestone — External playtest

This remains after the two refinement tasks. It is planned here for completeness and is not authorization to distribute a build now.

- Agree on the tester's operating system and delivery method when this milestone begins.
- Prepare a runnable Godot export with the adopted assets and required licenses/attributions, plus short launch instructions.
- Provide a concise feedback guide covering rule/tutorial clarity, menu flow, difficulty, controls, visuals, audio, and any errors encountered.
- Make the build available through the agreed channel; arrange any direct communication with the tester through the user.
- Collect feedback, reproduce reported issues where possible, and agree on the next backlog priorities before implementing new suggestions.

**Done when:** another person can run the build and their feedback has been recorded and reviewed with the user.

## 5. Collaboration boundaries and next checkpoint

- This document is the execution plan, not a claim that the planned screens or assets already exist.
- Once the plan is approved for implementation, the specific packages may proceed autonomously within the confirmed scope; consult the user for unresolved design choices, visual production, and new scope.
- Do not advance to external playtesting merely because it is next in the backlog.
- Preserve user-led testing and the existing commit-after-approval/push-on-request workflow.
- The user approved implementation. The next checkpoint is manual review of the functional flow and a separate user decision to switch execution model and approve the visual direction before producing replacement menu/button or celebration assets.
