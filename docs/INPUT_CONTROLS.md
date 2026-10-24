# Input Controls

Status: keyboard implementation and manual playtesting approved by the user on 2026-10-24. Gamepad adaptation is in planning; implementation has not started.

## Confirmed direction

- Keep the existing mouse controls: left-click toggles bulbs and right-click toggles X annotations.
- Implement keyboard navigation and gameplay actions first, then let the user playtest them.
- Adapt the approved interaction to gamepad only after keyboard testing and user confirmation.
- Route all input methods through the same gameplay actions and rule evaluation.

## Confirmed keyboard bindings

| Action | Keys |
|---|---|
| Move the board selection | Arrow keys or WASD |
| Place or remove a bulb in the selected cell | Space |
| Add or remove an X annotation in the selected cell | X |
| Activate the focused interface button | Enter or Space |

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

- `src/input/keyboard_bindings.gd` installs named keyboard actions through Godot's InputMap. Bindings are declared in this file, use physical key positions, and are installed without duplication.
- `src/input/board_navigation.gd` stores selection and board/button transitions independently of the scene tree and game rules.
- `src/presentation/main.gd` applies keyboard actions according to the current focus, using the same bulb and annotation handlers as mouse input.
- No gamepad events were added. The next input stage will adapt the approved navigation and actions after keyboard playtesting and user confirmation.
