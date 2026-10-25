# Development Setup

## Requirements

- Godot 4.7.2 stable, standard edition with GDScript.
- Compatibility renderer (OpenGL), selected for this 2D PC prototype.
- Godot MCP Toolkit 1.0.4, included under `addons/godot_mcp_toolkit/` with its original license and attributions. Treat this directory as third-party code; project language conventions apply to first-party work.
- For assistant integration: Node.js 22 or newer and the companion `@npgamedev/godot-mcp-server@1.0.4` bridge.

## Open and run

Import the repository's `project.godot` in the Godot project manager and open it. Press F6 to run the current scene or F5 to run the project. The configured main scene is `src/presentation/main.tscn`.

The first launch presents a short tutorial. Later launches open the main menu, which offers Start Game, Settings, Tutorial, Quit, and a global audio mute shortcut. Start Game opens difficulty selection (including Random Level), then ten numbered levels for the chosen difficulty. Easy is 5×5 with 5 walls, Medium is 7×7 with 10 walls, and Hard is 9×9 with 16 walls; each difficulty has ten explicit seeds. Random Level chooses uniformly among registered difficulties and uses a temporary seed.

Settings includes music volume, global mute, windowed/fullscreen mode, and a read-only Controls tab. Its title, tab header, fixed-size scroll viewport, and Back footer stay in place while tab contents change; overflowing content scrolls within the viewport. Unframed arrow assets align to opposite viewport edges, with connected-controller LB/RB labels directly below; either shoulder changes tabs, and the active tab receives focus after a switch. The tutorial, Settings, and gameplay use a dark translucent content card; gameplay has compact horizontal padding, and the music slider is narrower than the Settings surface. Preferences persist locally, while puzzle moves and random seeds are discarded when returning to the main menu. Gameplay supports mouse, keyboard, and gamepad; left-click/Space/A toggles bulbs, right-click/X toggles X notes, and Escape/B exits to the main menu. Restart preserves the current board and clears its moves. A solved board shows a victory panel with progression/restart/menu actions. The mouse pointer hides after three seconds idle or when keyboard/controller input is used, and reappears with mouse activity. See [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md) for full behavior and [`ARCHITECTURE.md`](ARCHITECTURE.md) for source responsibilities.
On the current development machine, the editor executable is:

```sh
/home/hericles/Programas/Godot/Godot_v4.7.2-stable_linux.x86_64 --editor --path /home/hericles/Documentos/Projetos/Pessoal/projeto-lumen
```

The base viewport is 1152 × 800 and uses `canvas_items` scaling with aspect `expand`. The drawing area follows the window ratio, while the background preserves its own aspect and covers that area. Wide-window checks and rendered previews cover 1920 × 1080 and 2560 × 1080 without pillarboxing.

## Assistant connection

Keep the editor open with Godot MCP Toolkit enabled in Project Settings → Plugins. The toolkit registers a local authenticated editor connection and installs its runtime bridge autoload for playtests.

The Codex bridge's `GODOT_MCP_PROJECT_PATH` must match this repository's absolute path. If the client still targets another project, update that setting and reconnect the MCP client or restart Codex. Do not commit machine-specific client configuration, session tokens, or editor cache files.

Use the plugin to create and edit scenes, inspect nodes, and start or stop playtests. Repository documentation can be edited with ordinary file tools.

## Setup validation

On 2026-10-24, the main scene was opened, configured, and launched through Godot MCP Toolkit 1.0.4 on Godot 4.7.2. The user confirmed the fixed-board prototype was functional. The user also tested and approved generated puzzles, keyboard controls, Xbox controls, and bulb-to-X replacement. The isolated suites pass 731 checks: 29 core, 479 generation/catalog, 63 keyboard/navigation, 47 synthetic gamepad, 14 action-guard, 22 preference, and 77 menu/session-flow checks. The flow checks cover Settings/tutorial focus, pointer idle hiding and input-method handoff, neutral-stick drift, and restoring the pointer. The graphical flow suite also checks native pointer visibility in an isolated offscreen X11 window. Generic controller hardware remains untested. See [`../tests/README.md`](../tests/README.md) for validation details.
