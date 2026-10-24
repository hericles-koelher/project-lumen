# Game Rules

## Akari rules

- The board contains empty cells and walls. Some walls show a number from 0 to 4.
- The player may place one bulb in each empty cell.
- A bulb illuminates its own cell and empty cells in the same row and column until it reaches a wall or the board edge.
- Two bulbs may not illuminate each other; in practice, two bulbs cannot share a row or column without a wall between them.
- A numbered wall indicates how many bulbs must occupy the orthogonally adjacent empty cells.
- A level is solved when every empty cell is illuminated, no bulb illuminates another, and every numbered clue is satisfied.

## Edge cases to validate during implementation

- Unnumbered walls impose no count.
- Clues on edges and corners count only existing neighbors.
- A wall blocks light; bulbs on opposite sides of it do not see each other.
- The win check must consider the entire board and all rules at once.
