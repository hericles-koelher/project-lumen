# Development Setup

## Requirements

- Godot 4.7.2 stable, standard edition with GDScript.
- Compatibility renderer (OpenGL), selected for this 2D PC prototype.
- Godot MCP Toolkit 1.0.4, included under `addons/godot_mcp_toolkit/` with its original license and attributions. Treat this directory as third-party code; project language conventions apply to first-party work.
- For assistant integration: Node.js 22 or newer and the companion `@npgamedev/godot-mcp-server@1.0.4` bridge.

## Open and run

Import the repository's `project.godot` in the Godot project manager and open it. Press F6 to run the current scene or F5 to run the project. The configured main scene is `src/presentation/main.tscn`.

The initial scene currently displays the project title and subtitle. Difficulty buttons and gameplay will be added during prototype implementation.

On the current development machine, the editor executable is:

```sh
/home/hericles/Programas/Godot/Godot_v4.7.2-stable_linux.x86_64 --editor --path /home/hericles/Documentos/Projetos/Pessoal/projeto-lumen
```

The viewport starts at 1152 × 800 and uses `canvas_items` stretching. This is an initial development setting and can be adjusted after visual validation.

## Assistant connection

Keep the editor open with Godot MCP Toolkit enabled in Project Settings → Plugins. The toolkit registers a local authenticated editor connection and installs its runtime bridge autoload for playtests.

The Codex bridge's `GODOT_MCP_PROJECT_PATH` must match this repository's absolute path. If the client still targets another project, update that setting and reconnect the MCP client or restart Codex. Do not commit machine-specific client configuration, session tokens, or editor cache files.

Use the plugin to create and edit scenes, inspect nodes, and start or stop playtests. Repository documentation can be edited with ordinary file tools.

## Setup validation

On 2026-10-24, the editor authenticated as Godot 4.7.2 through MCP Toolkit 1.0.4. The main scene was created, saved, launched, and stopped through the plugin. Its runtime log contained no errors. Gameplay validation is pending implementation.
