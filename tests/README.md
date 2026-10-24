# Core Checks

The small standalone GDScript runner checks domain behavior without depending on the game interface or a third-party test framework.

Stop any running editor play session before running it; the development MCP runtime autoload also starts in headless processes and shares the project's runtime registry.

From the repository root, run with a Godot 4.7.2 executable:

```sh
godot --headless --path . --script res://tests/run_core.gd
```

Use the full executable path documented in `docs/DEVELOPMENT_SETUP.md` if `godot` is not on PATH.

The runner returns a nonzero exit code on failure. On 2026-10-24, all 23 checks passed, covering wall blocking in both directions, bulb conflicts, clue counts at boundaries, zero clues, annotations, reset, and a valid solution of the fixed level.

The main fixed-board fixture has a known solution at zero-based `(x, y)` coordinates `(0, 0)`, `(2, 1)`, `(1, 2)`, `(4, 2)`, and `(2, 4)`. This is test data only; gameplay accepts any placement satisfying the rules.

Manual checks for the user include visual clarity, hover/cursor feedback, left/right clicks, victory locking, Restart, Back to Menu, clean re-entry, Quit, and audio balance. Core checks do not replace that review.
