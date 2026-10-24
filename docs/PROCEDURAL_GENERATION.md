# Procedural Generation

## Initial parameters

- board width and height;
- target wall count;
- integer seed for the pseudo-random number generator.

## Requirements

- Generation parameters come from predefined difficulty presets rather than arbitrary values entered by the player.
- A preset defines board width, height, and target wall count. Difficulty may be selected by the player or assigned to a particular level; the prototype's supported flow is still to be decided.
- Each level has an explicit integer seed, separate from its stable level ID. Difficulty does not imply a single seed; different levels may share a preset and use different seeds.
- Initial fixed preset values are recorded in [`PROTOTYPE_DEFINITION.md`](PROTOTYPE_DEFINITION.md). Resolve concrete parameters before generation begins.
- Presets express intended difficulty; actual puzzle difficulty must be assessed through playtesting. Board size and wall count alone do not guarantee a particular solving difficulty.

- The same configuration and generator version should produce the same board definition.
- An accepted level must have at least one solution that satisfies the Akari rules.
- Multiple solutions are allowed in the first prototype.
- Generation must have a retry limit and fail explicitly if it cannot find a valid board; avoid unbounded loops.
- Impossible or inconsistent parameters should be rejected with a clear error.

## Incremental strategy

Start with small boards that are easy to validate. One practical approach is to construct a conflict-free bulb arrangement, derive its illumination, and then place walls while preserving at least one known solution. Implement and document the concrete method together with its checks.

A general solver, solution counting, and a unique-solution requirement are future improvements.

## Level seeds and reproducibility

- Store a stable level ID, difficulty preset reference, explicit seed, and generator version in each level entry. Concrete seeds will be selected during implementation.
- Use a generator-local pseudo-random source initialized from the level seed. Do not share random state with presentation or other systems. Keep generation order deterministic.
- Reproduction requires the same resolved parameters, seed, generator version, and compatible random-number implementation. A seed alone is insufficient.
- Record the resolved dimensions, target wall count, seed, and generator version when reporting a generation issue. Changing a difficulty preset may change its levels even when their seeds stay the same.
- Keep level identity independent from its generated content: changing a seed replaces the puzzle without requiring a new level ID.
- A global campaign seed and stable per-level seed derivation are optional future extensions.
- If released puzzles must survive generator or engine changes exactly, save their board definitions instead of depending on regenerating them with old algorithms. This persistence is deferred beyond the initial prototype.
