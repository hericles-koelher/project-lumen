# Engineering Practices

This document defines the default standards for code, assets, documentation, and day-to-day changes in Project Lumen. Apply them to new work and use them when editing existing work, unless a documented project decision gives a clear reason to differ.

## 1. Language and communication

- Write all repository content in English: source code, identifiers, comments, commit messages, documentation, task entries, user-facing text in the game, and test names.
- Use clear, idiomatic English. Prefer simple words over clever abbreviations.
- Use the same term for the same concept throughout the project. Consult the project overview and game rules before introducing domain vocabulary.
- Comments explain intent, constraints, or non-obvious trade-offs. Do not narrate code that is already clear.

## 2. Core principles

### KISS — Keep It Simple

- Choose the simplest design that meets the current, stated requirement.
- Prefer direct control flow and small, cohesive functions over layers of indirection.
- Do not build speculative frameworks, plugin systems, or general-purpose abstractions for hypothetical future needs.
- Add an abstraction when it removes meaningful duplication, isolates a real responsibility, or makes behavior substantially easier to verify.

### DRY — Don't Repeat Yourself

- Keep each rule, calculation, and piece of configuration authoritative in one place.
- Reuse shared behavior when multiple callers need the same concept and semantics.
- Do not force unrelated code into a shared helper merely because the lines look similar. Duplication is preferable to a misleading abstraction when behavior is likely to evolve differently.

### YAGNI — You Aren't Gonna Need It

- Implement what the current task and accepted project scope require.
- Defer optional systems, including unique-solution generation and a general puzzle solver, until a task calls for them.
- Record likely future needs in `TASKS.md` or an appropriate design document instead of preemptively implementing them.

### Single responsibility and separation of concerns

- Keep rules, board data, mutable player state, generation, and presentation as distinct responsibilities.
- Keep domain rules independent of scene-tree layout and visual styling where practical.
- A function or script should have one clear reason to change. Split responsibilities when doing so improves comprehension, testing, or reuse; avoid splitting purely to create more files.

## 3. Naming and code layout

- Use descriptive names that convey intent and domain meaning. Avoid unclear abbreviations and one-letter names except for short, conventional local indexes.
- Follow the official naming and formatting conventions for the selected Godot and GDScript version. Confirm conventions against the installed version before adding formatter or lint configuration.
- Keep functions focused and short enough to understand locally. Extract a helper when it gives a meaningful name to a distinct operation or removes real repetition.
- Avoid hidden state and surprising side effects. Make inputs, outputs, and mutations apparent from the API.
- Prefer explicit types for public APIs and non-obvious values. Do not add redundant annotations when inference is clearer and consistent with the project's Godot version.
- Use constants or named enums for domain values instead of scattering unexplained numeric or string literals.
- Group files by responsibility and follow the directory map in `AGENTS.md`. Keep scenes, scripts, and assets near the feature that owns them as the project grows.
- Do not introduce a dependency when a small, understandable implementation using Godot's built-in features will meet the need.

## 4. Game-specific design constraints

- Keep level configuration, board definition, and game state as separate concepts.
- Treat a generated board definition as immutable during a play session; store player bulb placements in game state.
- Make procedural generation deterministic from its explicit configuration and seed. Avoid relying on global random state, wall-clock time, or scene order.
- A generated level must preserve at least one valid solution. Multiple solutions are acceptable in the initial version.
- Keep derived values, such as illuminated cells and conflicts, computed from authoritative board and game-state data. Do not maintain duplicate representations unless profiling or a concrete requirement justifies them.
- Validate input dimensions, wall counts, and other generation parameters at the boundary where configuration enters the system.

## 5. Error handling and robustness

- Validate assumptions at system boundaries and fail with a clear message when input is invalid or generation cannot produce a valid board.
- Avoid silent fallback behavior that can produce a misleading or unsolvable level.
- Bound retries and search work in procedural generation; never use an unbounded retry loop.
- Handle board edges, corners, zero-sized or minimum-sized boards, and clues with fewer than four neighbors deliberately.
- Prefer explicit error paths over continuing with partially valid state.

## 6. Testing and verification

- Coordinate testing with the user. When they take over manual playtesting, stop automated UI input and avoid restarting or stopping their running game. Focus on isolated core checks and incorporate their visual and usability feedback.
- For each behavior change, identify the key rule or user-visible outcome that should hold.
- Test domain rules independently from scene presentation when practical.
- Cover boundary cases for illumination, wall blocking, adjacent clue counts, conflicting bulbs, and win detection as those systems are implemented.
- For deterministic generation, verify that identical configuration and seed reproduce the same board, and that every accepted generated board has at least one valid solution.
- Keep tests focused on observable behavior. Avoid tests that only mirror implementation details or make refactoring unnecessarily difficult.
- Run relevant project checks after changes when the required tools are available. Report exactly what ran and any limitations.
- Do not add broad test frameworks or tooling until the project has a concrete need and a documented setup.

## 7. Documentation and decisions

- Update documentation when behavior, structure, setup, or agreed scope changes.
- Keep `AGENTS.md` concise: it is the entry point and repository map. Put detailed standards and design explanations in the linked documents.
- Add durable architectural or behavioral choices to `docs/TECHNICAL_DECISIONS.md`, including context, choice, and consequences.
- Maintain `TASKS.md` as the actionable project backlog. Keep tasks specific enough to be started and verified.
- Keep checklist entries concise: describe the task, its status, and an optional completion date or document link. Put reasoning, test results, review notes, and progress reports in the relevant documentation or chat instead of task entries.
- Use relative links between repository documents and check that links point to existing files when changing the index.

## 8. Change and Git discipline

- Start each new task only after explicit user permission. Do not interpret task order, approval of a previous task, or a question about readiness as authorization to advance. Complete the authorized task and stop for user review.
- Inspect the working tree before editing. Preserve unrelated user changes and avoid overwriting files without reading them.
- Keep changes scoped to the active task. Do not mix unrelated cleanup or formatting into a feature change.
- After the user approves a completed task, commit its changes in a small, reviewable commit. Write commit messages in English and describe the outcome.
- Never force-push, rewrite shared history, discard user changes, or configure/use a remote unless the user explicitly asks.
- Keep completed task changes available for review until the user approves them, then commit. Task approval authorizes the commit, not a push. Push only after an explicit user request.

## 9. When a guideline needs an exception

If a task conflicts with a guideline, follow the user's explicit instruction for that task. For recurring exceptions or a change to project-wide policy, update this document and record the rationale in `docs/TECHNICAL_DECISIONS.md`.
