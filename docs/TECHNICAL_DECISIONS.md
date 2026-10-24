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
- **Consequence:** resolve a concrete level configuration before invoking the generator. Initial preset values are recorded in `PROTOTYPE_DEFINITION.md`; they require playtesting. Seed policy is recorded in TD-005, and the entry flow remains to be defined.

## TD-005 — Explicit per-level seeds independent from level identity

- **Context:** the prototype has one level per difficulty and needs reproducible puzzles that can be replaced individually during tuning.
- **Choice:** store an explicit seed separately from each level's stable ID, together with its difficulty and generator version. Generate with isolated random state and retain resolved parameters in reproduction reports.
- **Consequence:** seeds can change without renaming levels. Reproduction requires matching configuration, generator version, and compatible random behavior. Global seed derivation and saving final board definitions are possible later extensions.
