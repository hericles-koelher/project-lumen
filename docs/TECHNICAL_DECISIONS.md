# Technical Decisions

This file records decisions that affect architecture, persisted data, or observable behavior. For each important decision, note the context, choice, and consequences.

## TD-001 — Start with a functional core

- **Context:** the project is also a learning exercise in Godot and game development.
- **Choice:** build a simple, functional version first and defer themed art until the rules and interaction are clear.
- **Consequence:** prioritize readable code, small scenes, and incremental steps.

## TD-002 — Separate rules from presentation

- **Context:** rules need to be easy to verify and should not be tied to visual nodes.
- **Choice:** keep game logic and state decoupled from Godot presentation.
- **Consequence:** the interface reads and changes state through well-defined actions.

## TD-003 — Deterministic generation with a minimum validity guarantee

- **Context:** seeds should make levels reproducible and help debug generated results.
- **Choice:** use dimensions, target wall count, and seed as inputs; guarantee at least one solution while initially allowing multiple solutions.
- **Consequence:** the generator must preserve or verify a valid solution. Uniqueness and a general solver are not first-version requirements.

## TD-004 — Difficulty presets control generation parameters

- **Context:** players should encounter puzzles configured by difficulty rather than manually specifying board dimensions and wall counts.
- **Choice:** define difficulty presets that supply generation parameters. A preset may be selected by the player or assigned to a level; the seed identifies a particular generated board.
- **Consequence:** resolve a concrete level configuration before invoking the generator. Initial preset values are recorded in `PROTOTYPE_DEFINITION.md` and require playtesting. Seed policy is recorded in TD-005. The catalog registers ten fixed levels per difficulty and defines progression order. Each level has a stable ID and an explicit seed.

## TD-005 — Explicit per-level seeds independent from level identity

- **Context:** the game needs reproducible numbered puzzles that can be tuned individually, plus a separate temporary random mode.
- **Choice:** store an explicit seed separately from each level's stable ID, together with its difficulty and generator version. Generate with isolated random state and retain resolved parameters in reproduction metadata. Random mode draws a difficulty uniformly and uses a temporary in-memory seed.
- **Consequence:** seeds can change without renaming levels. Reproduction requires matching configuration, generator version, and compatible random behavior. Global seed derivation and saving final board definitions are possible later extensions.

## TD-006 — Construct a solution before deriving clues

- **Context:** the prototype needs exact wall counts and valid levels without a general solver.
- **Choice:** place walls first, then visit shuffled playable cells and add a bulb only to unlit cells. Derive a shuffled subset of wall clues from this solution and validate the final board using the existing game rules.
- **Consequence:** construction terminates in bounded passes and preserves at least one solution. Difficulty quality and uniqueness are not guaranteed by this method and remain subject to playtesting and future work.

## TD-007 — Number seventy percent of walls, rounded down

- **Context:** the user requested a mixture with fewer numbered walls than the initial 80% proposal.
- **Choice:** use a 70% ratio rounded down, yielding 3, 7, and 11 numbered walls in Easy, Medium, and Hard respectively.
- **Consequence:** ratios differ slightly on small boards because wall counts are integers. These initial values can be tuned after playtesting.
