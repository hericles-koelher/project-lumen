# UI Capture Tools

Use these tools to capture the actual Godot interface for documentation and visual review without controlling an existing play session.

## Run

From the repository root, with Python 3.9+ and Godot 4.7.2 installed:

```sh
python3 tools/capture_ui.py --godot /absolute/path/to/Godot
```

If `godot` or `godot4` is on PATH, `--godot` can be omitted. The command needs a graphical desktop/session for native rendering; its asset-import phase runs headlessly. No third-party Python packages are required.

The default output is `docs/screenshots/review/`. To preserve an earlier review, choose another directory:

```sh
python3 tools/capture_ui.py --godot /absolute/path/to/Godot --output work/ui-captures
```

The command writes 40 PNGs and `index.json`, covering every base-size screen plus representative widescreen and short-window layouts. Existing files with the same names in the chosen output directory are replaced. It does not update the README gallery or write a visual assessment automatically.

## Isolation and fixtures

`capture_ui.py` creates a disposable project under ignored `work/`, references the repository's source/assets/tools, imports its resources, and runs `capture_ui.gd` in a separate offscreen window that cannot receive focus. Player preferences are stored in temporary user data; music is muted and raw game input is disabled. The development MCP autoload is omitted. Existing game sessions are left running.

The script uses actual page builders and game action handlers. It stages reproducible partial solutions, bulb conflicts, exceeded clues, random gameplay, and victory variants; these fixtures are not new game features. Ambient motion is frozen after the title settles to make page comparisons consistent. Gamepad hints follow connected hardware and may differ on another machine.

The fallback fixture intentionally uses an invalid configuration. **One** “Level generation failed” message is expected. Other error/warning logs, a nonzero exit, or missing images must be investigated. Import and capture logs are written to `work/ui-capture-import.log` and `work/ui-capture.log`.

## Build a Windows test package

With the matching Godot 4.7.2 release template installed, run:

```sh
python3 tools/export_windows_build.py --godot /absolute/path/to/Godot
```

The script stages a temporary project with the same runtime scenes/assets but without the editor-only MCP autoload. It exports a 64-bit Windows release executable plus its `.pck` data file, and packages both with a short control guide. Output is written to ignored `build/windows/Project-Lumen-Windows-x86_64.zip`. Install the matching official Windows x86_64 release template in Godot's Export Template Manager if it is missing. See the [official Windows export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).

## Review limits

A successful command means the captures completed, not that the interface is visually correct. Inspect the images and their dimensions, compare consistent states, and record findings separately. Static images do not validate navigation, animation timing, audio, controller hardware, or fullscreen transitions. The latest assessment is [`../docs/VISUAL_REVIEW.md`](../docs/VISUAL_REVIEW.md).
