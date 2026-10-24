# Automated Domain Checks

The small standalone GDScript runners check game rules and generation without depending on the interface or a third-party test framework.

Use the Python standard-library wrapper to run all four suites in a temporary project with no MCP autoload. It links the existing source and tests, so checks do not stop, restart, or re-register the user's editor play session. The wrapper requires Python 3 and runs on the current Linux development setup.

From the repository root, run with a Godot 4.7.2 executable:

```sh
python3 tests/run_checks.py --godot /path/to/godot
```

If `godot` or `godot4` is already on PATH, omit `--godot`. The machine-specific executable location is documented in `docs/DEVELOPMENT_SETUP.md`. Temporary files are created under ignored `work/` and removed automatically.

The wrapper returns a nonzero exit code on failure. On 2026-10-24:

- `run_core.gd`: 29 checks passed, covering wall blocking, bulb conflicts, boundary/zero clues, annotations, reset, the fixed fixture, and replacing a bulb with X (including lighting updates, clearing violations, and completing a puzzle).
- `run_generation.gd`: 281 checks passed, covering the three catalog configurations, exact wall/clue counts, seeded reproduction independent from global randomness, configuration/board isolation, invalid input handling, and solution validity across 120 additional boards (40 seeds per difficulty).
- `run_input.gd`: 50 checks passed, covering arrow/WASD bindings, action bindings, repeat behavior, modified shortcuts, initial selection, boundaries, wall selection, button transitions, and returning to the remembered cell at all three board sizes.
- `run_gamepad.gd`: 47 checks passed using synthetic events, covering standardized buttons on multiple device IDs, Escape/B mapping, D-pad and stick state, deadzone, stable cardinal direction, connection/reset behavior, and repeat timing. These checks do not certify physical controller compatibility; the user tested and approved Xbox interaction on 2026-10-24. Generic controller hardware remains untested.

The main fixed-board fixture has a known solution at zero-based `(x, y)` coordinates `(0, 0)`, `(2, 1)`, `(1, 2)`, `(4, 2)`, and `(2, 4)`. This is test data only; gameplay accepts any placement satisfying the rules.

Manual checks for the user include visual clarity, hover/cursor feedback, left/right clicks, victory locking, Restart, Back to Menu, clean re-entry, Quit, and audio balance. Core checks do not replace that review.
