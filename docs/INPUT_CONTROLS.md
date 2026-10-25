# Input Controls

Status: keyboard and Xbox interaction were tested and approved by the user on 2026-10-24. Bulb-to-X replacement was also tested and approved on that date.

## Confirmed direction

- Keep the existing mouse controls: left-click toggles bulbs and right-click toggles X annotations.
- Keep keyboard and gamepad behavior aligned with the approved navigation and gameplay actions.
- Gamepad support follows the keyboard interaction approved through user playtesting.
- Route all input methods through the same gameplay actions and rule evaluation.
- The annotation action replaces an existing bulb with X in one step, for right-click, keyboard X, and gamepad X. Repeating it removes X. This updates lighting, clues, conflicts, and victory like any other board change.

## Keyboard and menu bindings

| Action | Keys |
|---|---|
| Move board selection or menu focus | Arrow keys or WASD |
| Place or remove a bulb in the selected cell | Space |
| Add or remove an X annotation in the selected cell | X |
| Activate the focused interface button | Enter or Space |
| Return from a submenu to its parent | Escape |
| Exit gameplay or victory to the main menu | Escape |
| Ignore Back at the main menu | Escape |

## Confirmed gamepad bindings

| Action | Standard mapping / Xbox |
|---|---|
| Move selection and menu focus | D-pad or left stick |
| Place/remove a bulb; confirm a focused button | Bottom face button / A |
| Toggle X annotation | Left face button / X |
| Return from a submenu to its parent; exit gameplay/victory to main menu | Right face button / B |
| Switch Settings tabs while on a Settings page | Left/right shoulder / LB/RB |

## Board selection

- Keyboard and gamepad navigation advance exactly one cell at a time, including numbered and unnumbered walls. Walls can display the selection marker but reject both bulb and X-note actions. This restores the user-preferred behavior after playtesting wall skipping.
- Bulb and annotation actions have no effect on walls.
- Navigation does not wrap to the opposite board edge.
- Directional navigation may leave the board for adjacent interface controls. Moving down from the bottom row transfers focus to the buttons below the board.
- At edges with no adjacent focus target, the selection stays in place.
- In the bottom button row, left/right moves between buttons and up returns to the last selected board cell. Arrow keys and WASD use the same directional behavior.
- Opening a level selects its top-left cell, including when that cell is a wall. The board receives keyboard focus. A yellow corner marker identifies the active cell selection. Keyboard/gamepad focus and playable-cell pointer hover share this marker; only one input source displays it at a time.
- Leaving the board downward focuses the button nearest the selected cell's horizontal position. The cell is remembered while navigating the button row.
- The focus marker is visible only while the board has focus and pointer hover is not the active selector. Focused buttons use the existing theme's focus border.
- Clicking a playable cell synchronizes the remembered selection and returns focus to the board. Mouse hover moves the shared selection and becomes its single visible marker, so keyboard/gamepad navigation resumes from the hovered cell.
- Restart restores board focus at the remembered cell. Opening a level from the menu selects its top-left cell again.
- Victory disables board actions and opens a centered action panel. Focus moves to its first available action; button navigation remains available, and up cannot return to the locked board until restarting.

## Pointer visibility

- Hide the free mouse pointer after three seconds without mouse movement or a mouse-button press while the game window is focused.
- A keyboard press, controller-button press, or intentional left-stick navigation hides it immediately. Stick motion within the navigation deadzone does not hide it.
- Real mouse movement or a mouse-button press restores the pointer immediately and restarts the idle timeout. The mouse remains free; it is never captured or repositioned.
- Hidden-pointer hover cannot replace keyboard/gamepad cell selection. Moving again inside the same playable cell restores its hover selection without requiring a leave/re-enter motion.
- Restore the pointer and reset its idle timer on application focus changes and when the game closes.
- Hide mouse-only button hover highlights together with the pointer, including Settings arrows. Keyboard/gamepad focus remains visible; real mouse activity restores pointer hover styling.
- Real mouse movement or clicking hides keyboard/gamepad button focus highlights while preserving their remembered focus. Keyboard or intentional controller input restores focus highlights and suppresses stationary mouse hover, so the two input methods do not highlight separate buttons simultaneously.

## Interface navigation

- The main menu focuses Start Game. Directional input moves through the current screen without wrapping. Start Game opens difficulty selection; each difficulty opens its numbered levels. Random Level starts a session immediately.
- Enter or Space activates the focused button once per key press. Held activation keys do not repeatedly activate buttons or toggle bulbs/annotations.
- Held directional keys may repeat movement using keyboard repeat events.
- Native Tab focus traversal remains available, but directional navigation is the main agreed flow.
- Tutorial keeps one fixed-size card and replaces only its page content. Each step initially focuses Next, or Done on the last page; Skip remains reachable through normal navigation. Reopening Tutorial from the main menu starts at page one.
- Settings keeps its card, title, tab buttons, content viewport, and Back footer instantiated between Audio & Display and Controls. A tab switch replaces only the inner content without replaying the screen fade; selecting the active tab again retains its content and scroll position. Content that exceeds the viewport scrolls inside it.
- Click either tab or the unframed side-arrow assets to change pages. The complete arrow/hint clusters fit inside the opposite horizontal edges of the inner content card, with equal insets; when a controller is connected, LB/RB appear directly below them. Either shoulder button changes tabs, and the active tab receives focus after a switch.
- Changing display mode updates its button in place, preserving the existing Settings page, focused control, and content scroll position. The selected mode is saved immediately.
- Back, Escape, or B from either Settings tab returns directly to the main menu. Use the tabs, arrow assets, or LB/RB to switch between sections.

## Menu flow and preferences

- Main menu: Start Game, Settings, Tutorial, Quit, and a corner shortcut that globally mutes/unmutes audio.
- Difficulty selection includes every registered difficulty and Random Level at the same level.
- Numbered levels are selected from Level 1 through Level 10 for each difficulty. Next Level advances through catalog order and crosses to the next difficulty after Level 10.
- Settings contains music volume, windowed/fullscreen mode, and a read-only Controls tab. No remapping or separate sound-effects slider is provided.
- Preferences saved locally: music volume, global mute, display mode, and whether the tutorial has opened. Puzzle progress and random seeds are never saved.
- The first launch opens the tutorial and immediately records it as seen. Skip and completion return to the main menu; Tutorial in the menu opens it again from page one.
- Random Level chooses uniformly from registered difficulties. Restart preserves the active board and hidden seed; New Random Level draws again. Leaving to the menu discards the active session.

## Implementation

- `src/input/input_bindings.gd` installs named keyboard and standardized gamepad actions through Godot's InputMap. Keyboard bindings use physical key positions; gamepad bindings accept all device IDs. Installation does not duplicate events.
- `src/input/board_navigation.gd` stores selection and board/button transitions independently of the scene tree and game rules.
- `src/input/gamepad_state.gd` tracks D-pad/left-stick direction by device, handles neutral/deadzone input, and prioritizes the D-pad over the stick on the active device.
- `src/input/direction_repeat.gd` emits a first step immediately on the next frame, then applies the agreed delay and repeat interval. At most one controller step is emitted per frame.
- `src/presentation/main.gd` routes all input methods through the same navigation, bulb, annotation, activation, and Back handlers. It consumes controller events before native UI processing to avoid duplicate actions.
- Screen changes, Restart, victory, focus loss, and controller disconnection clear held movement as appropriate. Controller input is ignored while the game window is unfocused.

## Agreed gamepad behavior

- Reuse the existing named actions, navigation model, focus transitions, and gameplay handlers.
- Suppress accidental repeated controller actions for 150 ms per action type and cell. A rejected press does not extend the interval. Another cell or a switch between bulb and X remains immediate. This filter applies only to controller board actions; mouse, keyboard, menu activation, and movement keep their existing timing.
- Clear the controller action filter on Restart, page/session changes, focus loss, and controller disconnection.
- Confirmed navigation: D-pad and left stick. The agreed action layout uses the bottom face button (Xbox A) for bulbs/confirmation and the left face button (Xbox X) for annotations.
- The right face button (Xbox B) and keyboard Escape return from a submenu to its parent. During gameplay and victory they always exit to the main menu, discarding the session. At the main menu they do nothing; Quit is a separate menu action.
- Confirmed held-direction repeat: move once immediately, wait 0.30 seconds, then repeat one step every 0.12 seconds. These are initial tuning values. Bulb/annotation buttons still activate once per press.
- Confirmed left-stick behavior: ignore input within a 0.30 deadzone and convert the strongest axis into a single cardinal direction. Diagonal tilt never moves diagonally across cells. The deadzone is an initial tuning value.
- A small 0.10 axis-switch margin stabilizes direction near diagonals, so tiny hardware jitter does not cause rapid direction changes. Both analog axes are sampled together once per frame.
- Include connection/disconnection handling and manual tests with the user's available controllers. Inspect device recognition and mapping before adding model-specific exceptions.
- The user completed the physical playtest with an Xbox controller. Use the standardized mapping for both Xbox and recognized generic controllers; actual generic-device compatibility remains unverified until tested with that hardware.
- Godot 4.7 uses SDL 3 on desktop and exposes standardized buttons for recognized devices. Unknown generic controllers may need custom mappings. Controller directions do not have keyboard-style echo; analog sticks also require a deadzone. Sources: [Godot controller guide](https://docs.godotengine.org/en/4.7/tutorials/inputs/controllers_gamepads_joysticks.html), [device recognition](https://docs.godotengine.org/en/4.7/classes/class_input.html#class-input-method-is-joy-known), [standard button positions](https://docs.godotengine.org/en/4.7/classes/class_@globalscope.html#enum-globalscope-joybutton).

Synthetic checks validate mapping and navigation logic, not physical compatibility. The user completed Xbox playtesting; no generic hardware has been tested yet.
