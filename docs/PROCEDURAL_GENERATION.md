# Procedural Generation

## Initial parameters

- board width and height;
- target wall count;
- integer seed for the pseudo-random number generator.

## Requirements

- Generation parameters come from predefined difficulty presets rather than arbitrary values entered by the player.
- A preset defines board width, height, target wall count, and numbered-wall ratio. The prototype menu selects the single level assigned to each difficulty.
- Each level has an explicit integer seed, separate from its stable level ID. Difficulty does not imply a single seed; different levels may share a preset and use different seeds.
- Initial fixed preset values are recorded in [`PROTOTYPE_DEFINITION.md`](PROTOTYPE_DEFINITION.md). Resolve concrete parameters before generation begins.
- Presets express intended difficulty; actual puzzle difficulty must be assessed through playtesting. Board size and wall count alone do not guarantee a particular solving difficulty.

- The same configuration and generator version should produce the same board definition.
- An accepted level must have at least one solution that satisfies the Akari rules.
- Multiple solutions are allowed in the first prototype.
- Generated boards mix numbered and unnumbered walls. Numbered walls are 70% of the target wall count, rounded down: Easy 3/5, Medium 7/10, and Hard 11/16.
- Generation must use bounded work and fail explicitly rather than returning an invalid board. Any future retry strategy must limit attempts; the current constructive version uses no retries.
- Impossible or inconsistent parameters should be rejected with a clear error.

## Incremental strategy

Generator version 1 uses constructive generation:

1. Validate the explicit configuration and initialize a local `RandomNumberGenerator` from the level seed.
2. Shuffle cell indices with a local Fisher–Yates shuffle and choose exactly the target number of walls.
3. Shuffle playable cells. Visit each once and place a construction bulb only if that cell is still unlit, using the existing game rules to update illumination.
4. Shuffle the wall indices and number exactly `floor(wall_count × 0.70)` of them. Derive each clue from the construction solution's adjacent bulb count.
5. Validate the solution on the final board with the game rules. Return an explicit error if validation fails; never return an unverified board.

An unlit cell cannot see an existing bulb, so adding a bulb there cannot introduce a bulb conflict. Every cell is visited, and illumination only increases during construction, so every playable cell ends illuminated. Clues are derived from that same solution. This provides a valid solution without a general solver or retries. All loops are bounded by the configured board size.

The construction solution is returned for automated verification but discarded by the presentation. It is never used as the win condition or exposed as a hint. Players may solve a board using any valid arrangement.

Configuration limits are 1–64 cells per axis, at most 4096 cells, at least two walls, and at least one playable cell. The resolved numbered-wall count must leave both wall types present. Unsupported generator versions and invalid ratios are rejected explicitly. These are implementation bounds; the playable catalog uses only the three approved presets.

A general solver, solution counting, and a unique-solution requirement are future improvements.

## Level seeds and reproducibility

- Store a stable level ID, difficulty preset reference, explicit seed, and generator version in each level entry. The catalog in `src/levels/prototype_levels.gd` currently uses:

| Level ID | Difficulty | Seed | Generator version |
|---|---|---|---|
| `easy_001` | Easy | 104729 | 1 |
| `medium_001` | Medium | 130363 | 1 |
| `hard_001` | Hard | 155921 | 1 |

These are explicit initial seeds, not encodings of level IDs. The runtime controller retains resolved metadata in `_current_configuration` for reproduction.
- Use a generator-local pseudo-random source initialized from the level seed. Do not share random state with presentation or other systems. Keep generation order deterministic.
- Reproduction requires the same resolved parameters, seed, generator version, and compatible random-number implementation. A seed alone is insufficient.
- Record the resolved dimensions, target wall count, seed, and generator version when reporting a generation issue. Changing a difficulty preset may change its levels even when their seeds stay the same.
- Keep level identity independent from its generated content: changing a seed replaces the puzzle without requiring a new level ID.
- A global campaign seed and stable per-level seed derivation are optional future extensions.
- If released puzzles must survive generator or engine changes exactly, save their board definitions instead of depending on regenerating them with old algorithms. This persistence is deferred beyond the initial prototype.
