# Board bulb placement and removal — Candidate 01

Status: the user selected Candidate A on 2026-10-25. It is integrated with the approved quick-wave reveal from Candidate 02; in-game visual review was approved on 2026-10-25.

## Purpose

Compare three brief visual responses when the player adds or removes a bulb from a playable cell. Keep input immediate and retain the existing bulb SVG, cell palette, and puzzle feedback.

## Candidates

- **A — Soft pop:** the bulb appears with a restrained scale bounce, or shrinks away on removal. The cell changes between cream and sunlight amber with the bulb state.
- **B — Warm bloom:** a diffuse warm halo expands around the bulb as the cell lights; removal lets the glow recede. This is the most luminous option.
- **C — Tiny spark:** the bulb appears with three brief, small amber sparkles. Removal uses a short fade and contraction without extra particles.

All three update their sample cell state immediately and play the effect over the visual change. Each sample can be tested repeatedly and independently. The durations are intentionally short (about 160–340 ms including the spark accent). The preview is visual only; existing gameplay audio is unchanged.

## Files

- Interactive preview using project-relative SVG artwork: `board-bulb-candidate-01.html`.
- Uses `assets/icons/bulb.svg` and the existing cream, amber, wall, and coral palette. It introduces no new image assets.

## Review

The user selected Soft pop. They also approved a quick outward light wave; see [`board-bulb-candidate-02.md`](board-bulb-candidate-02.md) for its timing and implementation.
