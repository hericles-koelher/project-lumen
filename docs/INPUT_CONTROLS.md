# Input Controls

Status: keyboard and Xbox interaction were tested and approved by the user on 2026-10-24. Bulb-to-X replacement was also tested and approved on that date.

## Confirmed direction

- Keep the existing mouse controls: left-click toggles bulbs and right-click toggles X annotations.
- Keep keyboard and gamepad behavior aligned with the approved navigation and gameplay actions.
- Gamepad support follows the keyboard interaction approved through user playtesting.
- Route all input methods through the same gameplay actions and rule evaluation.
- The annotation action replaces an existing bulb with X in one step, for right-click, keyboard X, and gamepad X. Repeating it removes X. This updates lighting, clues, conflicts, and victory like any other board change.

## Confirmed keyboard bindings

| Action | Keys |
|---|---|
| Move the board selection | Arrow keys or WASD |
| Place or remove a bulb in the selected cell | Space |
| Add or remove an X annotation in the selected cell | X |
| Activate the focused interface button | Enter or Space |
| Back to the previous screen | Escape |

## Confirmed gamepad bindings

| Action | Standard mapping / Xbox |
|---|---|
| Move selection and menu focus | D-pad or left stick |
| Place/remove a bulb; confirm a focused button | Bottom face button / A |
| Toggle X annotation | Left face button / X |
| Back to the previous screen | Right face button / B |

## Board selection

- The selection moves one cell at a time and may pass over walls, including numbered walls.
- Selecting a wall is allowed, but bulb and annotation actions have no effect on it.
- Navigation does not wrap to the opposite board edge.
- Directional navigation may leave the board for adjacent interface controls. Moving down from the bottom row transfers focus to the buttons below the board.
- At edges with no adjacent focus target, the selection stays in place.
- In the bottom button row, left/right moves between buttons and up returns to the last selected board cell. Arrow keys and WASD use the same directional behavior.
- Opening a level selects its top-left cell and gives the board keyboard focus. A visible inner/outer outline identifies the selected cell, including when it is a wall.
- Leaving the board downward focuses the button nearest the selected cell's horizontal position. The cell is remembered while navigating the button row.
- The cell outline is visible only while the board has focus. Focused buttons use the existing theme's focus border.
- Clicking a playable cell synchronizes the remembered selection and returns focus to the board. Mouse hover alone does not move the keyboard selection.
- Restart restores board focus at the remembered cell. Opening a level from the menu starts at the top-left cell again.
- Victory disables board actions and moves board focus to Restart. Button navigation remains available; up does not return to the locked board until restarting.

## Interface navigation

- The initial menu focuses Easy. Up/down or W/S moves through the current vertical menu without wrapping.
- Enter or Space activates the focused button once per key press. Held activation keys do not repeatedly activate buttons or toggle bulbs/annotations.
- Held directional keys may repeat movement using keyboard repeat events.
- Native Tab focus traversal remains available, but directional navigation is the main agreed flow.

## Implementation

- `src/input/input_bindings.gd` installs named keyboard and standardized gamepad actions through Godot's InputMap. Keyboard bindings use physical key positions; gamepad bindings accept all device IDs. Installation does not duplicate events.
- `src/input/board_navigation.gd` stores selection and board/button transitions independently of the scene tree and game rules.
- `src/input/gamepad_state.gd` tracks D-pad/left-stick direction by device, handles neutral/deadzone input, and prioritizes the D-pad over the stick on the active device.
- `src/input/direction_repeat.gd` emits a first step immediately on the next frame, then applies the agreed delay and repeat interval. At most one controller step is emitted per frame.
- `src/presentation/main.gd` routes all input methods through the same navigation, bulb, annotation, activation, and Back handlers. It consumes controller events before native UI processing to avoid duplicate actions.
- Screen changes, Restart, victory, focus loss, and controller disconnection clear held movement as appropriate. Controller input is ignored while the game window is unfocused.

## Agreed gamepad behavior

- Reuse the existing named actions, navigation model, focus transitions, and gameplay handlers.
- Confirmed navigation: D-pad and left stick. The agreed action layout uses the bottom face button (Xbox A) for bulbs/confirmation and the left face button (Xbox X) for annotations.
- The right face button (Xbox B) and keyboard Escape return to the previous screen; during gameplay they perform Back to Menu. At the main menu they do not quit the game.
- Confirmed held-direction repeat: move once immediately, wait 0.30 seconds, then repeat one step every 0.12 seconds. These are initial tuning values. Bulb/annotation buttons still activate once per press.
- Confirmed left-stick behavior: ignore input within a 0.30 deadzone and convert the strongest axis into a single cardinal direction. Diagonal tilt never moves diagonally across cells. The deadzone is an initial tuning value.
- A small 0.10 axis-switch margin stabilizes direction near diagonals, so tiny hardware jitter does not cause rapid direction changes. Both analog axes are sampled together once per frame.
- Include connection/disconnection handling and manual tests with the user's available controllers. Inspect device recognition and mapping before adding model-specific exceptions.
- The user completed the physical playtest with an Xbox controller. Use the standardized mapping for both Xbox and recognized generic controllers; actual generic-device compatibility remains unverified until tested with that hardware.
- Godot 4.7 uses SDL 3 on desktop and exposes standardized buttons for recognized devices. Unknown generic controllers may need custom mappings. Controller directions do not have keyboard-style echo; analog sticks also require a deadzone. Sources: [Godot controller guide](https://docs.godotengine.org/en/4.7/tutorials/inputs/controllers_gamepads_joysticks.html), [device recognition](https://docs.godotengine.org/en/4.7/classes/class_input.html#class-input-method-is-joy-known), [standard button positions](https://docs.godotengine.org/en/4.7/classes/class_@globalscope.html#enum-globalscope-joybutton).

Synthetic checks validate mapping and navigation logic, not physical compatibility. The user completed Xbox playtesting; no generic hardware has been tested yet.
