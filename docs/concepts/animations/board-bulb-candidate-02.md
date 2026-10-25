# Board bulb and illumination sync — Candidate 02

Status: the user approved Quick wave with Soft pop on 2026-10-25. Integrated into Godot; in-game visual review was approved on 2026-10-25.

## Proposed behavior

- Place the bulb with Candidate 01's soft pop (210 ms placement, 160 ms removal).
- Update the board and puzzle evaluation immediately. Animate only the cells whose illuminated state changes; don't block input.
- Respect the board rules: numbered and unnumbered walls stop illumination. If another bulb keeps a cell lit, a future game integration should leave that cell lit rather than animating it off.
- **Quick wave** lights outward from the new bulb along its row and column, in all four directions at once, with 30 ms between cell distances and a 120 ms fade per cell. The alternative all-at-once mode remains in the preview for comparison, but was not selected.
- Removing a bulb withdraws light from the farthest changed cells toward the bulb. The bulb's cell dims last. Puzzle state remains immediate.

The preview shows a nine-by-nine sample with a center bulb position and wall stops. Godot uses the approved timing from the editor-adjustable animation resource.

## Files

- Interactive preview: `board-bulb-candidate-02.html`; uses the existing bulb SVG and palette without adding image assets.
- Candidate 01 retains the original three-way comparison and records the user's selection of Soft pop.

## Review

The user's in-game review should confirm that the wave feels coordinated with the bulb pop, stays brief, and remains clear beside other bulbs and conflict feedback. Check repeated fast inputs, X-replacement removal, and final-cell victory feedback.
