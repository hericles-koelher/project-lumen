# Automated Domain Checks

The small standalone GDScript runners check game rules and generation without depending on the interface or a third-party test framework.

Use the Python standard-library wrapper to run both suites in a temporary project with no MCP autoload. It links the existing source and tests, so checks do not stop, restart, or re-register the user's editor play session. The wrapper requires Python 3 and runs on the current Linux development setup.

From the repository root, run with a Godot 4.7.2 executable:

```sh
python3 tests/run_checks.py --godot /path/to/godot
```

If `godot` or `godot4` is already on PATH, omit `--godot`. The machine-specific executable location is documented in `docs/DEVELOPMENT_SETUP.md`. Temporary files are created under ignored `work/` and removed automatically.

The wrapper returns a nonzero exit code on failure. On 2026-10-24:

- `run_core.gd`: 23 checks passed, covering wall blocking in both directions, bulb conflicts, clue counts at boundaries, zero clues, annotations, reset, and a valid solution of the fixed fixture.
- `run_generation.gd`: 281 checks passed, covering the three catalog configurations, exact wall/clue counts, seeded reproduction independent from global randomness, configuration/board isolation, invalid input handling, and solution validity across 120 additional boards (40 seeds per difficulty).

The main fixed-board fixture has a known solution at zero-based `(x, y)` coordinates `(0, 0)`, `(2, 1)`, `(1, 2)`, `(4, 2)`, and `(2, 4)`. This is test data only; gameplay accepts any placement satisfying the rules.

Manual checks for the user include visual clarity, hover/cursor feedback, left/right clicks, victory locking, Restart, Back to Menu, clean re-entry, Quit, and audio balance. Core checks do not replace that review.
