# Project Lumen — Agent Guide

## Mission

This repository contains a 2D Akari (Light Up) game developed with Godot. The initial goal is to build a small, functional, easy-to-understand game, prioritizing correct rules and simple architecture before investing in art and visual themes.

## How to get started

1. Read this guide and use the index below to find task-specific context.
2. Check the current Git state and existing files before editing.
3. Make small, coherent changes that fit the project's current stage; keep documentation and implementation aligned.
4. When finished, summarize changed files, decisions, and checks performed. Never claim something was tested if it was not.

## Working conventions

- **Language:** Write all source code, comments, identifiers, commit messages, and documentation in English. This includes `AGENTS.md`, `README.md`, task lists, and design documents.
- **Engineering practices:** Follow [`docs/ENGINEERING_PRACTICES.md`](docs/ENGINEERING_PRACTICES.md) for concrete rules on simplicity, duplication, naming, testing, and changes.
- **Game architecture:** Keep game rules and calculations independent from the user interface and visual presentation. Distinguish level configuration, board definition, and mutable game state.
- **Reproducible generation:** Level configuration should include width, height, target wall count, and a deterministic seed. The same configuration should reproduce the same result within a supported generator version.
- **Difficulty presets:** Resolve generation parameters from a predefined difficulty preset, selected by the player or assigned to a level. See `docs/PROCEDURAL_GENERATION.md` for the distinction between presets and seeds.
- **Validity first:** Generated boards must have at least one valid solution. Multiple solutions are acceptable for the first version. A solver and uniqueness check are future improvements, not initial requirements.
- **Incremental work:** Make small changes with clear, verifiable outcomes before expanding scope.
- **Godot:** Use GDScript and native resources from the installed engine version. Confirm the available version before relying on version-specific APIs, then record the project's chosen version.
- **Scope:** Do not add dependencies, art systems, menus, or unrequested features unless the current step needs them.
- **Verification:** When behavior changes, describe how to validate it and run relevant available checks. If the engine or a tool is unavailable, state that limitation.
- **Git:** Preserve existing work; do not discard user changes. Do not configure or use a remote unless explicitly requested.
- **Task commits:** Commit completed task changes after the user approves the task. Push only after an explicit user request; task approval alone does not authorize a push.
- **Task boundaries:** Start each new task only after explicit user permission. A task list defines order, not authorization to advance automatically. Questions about readiness or remaining work are not permission to start implementation. Finish the authorized task and stop for user review.
- **Playtest coordination:** When the user is testing the game, leave manual interaction and usability feedback to them. Do not automate clicks or stop/restart their play session while they are testing; coordinate any necessary interruption first.

## Repository index

| Topic | Summary | Further details |
|---|---|---|
| Project overview | Goals, first-version scope, and project vocabulary | [`docs/PROJECT_OVERVIEW.md`](docs/PROJECT_OVERVIEW.md) |
| Architecture | Boundaries between rules, data, generation, and presentation | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| Game rules | Akari rules, lighting, and win condition | [`docs/GAME_RULES.md`](docs/GAME_RULES.md) |
| Procedural generation | Seed, parameters, validity, and generator evolution | [`docs/PROCEDURAL_GENERATION.md`](docs/PROCEDURAL_GENERATION.md) |
| Technical decisions | Important technical decisions and their rationale | [`docs/TECHNICAL_DECISIONS.md`](docs/TECHNICAL_DECISIONS.md) |
| Engineering practices | Required coding and collaboration standards | [`docs/ENGINEERING_PRACTICES.md`](docs/ENGINEERING_PRACTICES.md) |
| Development plan | Proposed incremental path from setup to prototype | [`docs/DEVELOPMENT_PLAN.md`](docs/DEVELOPMENT_PLAN.md) |
| Development setup | Godot version, running the project, and MCP plugin connection | [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md) |
| Asset inventory | Required prototype visuals and optional audio; production decisions | [`docs/ASSET_INVENTORY.md`](docs/ASSET_INVENTORY.md) |
| Asset provenance | Sources, licenses, and status of included assets | [`assets/ASSET_MANIFEST.md`](assets/ASSET_MANIFEST.md) |
| Task list | Actionable project work, ordered by priority | [`TASKS.md`](TASKS.md) |
| Prototype definition | Confirmed prototype decisions and open design questions | [`docs/PROTOTYPE_DEFINITION.md`](docs/PROTOTYPE_DEFINITION.md) |
| Game source | Scripts and scenes, grouped by responsibility | [`src/`](src/) |
| Verification | Automated tests or repeatable validation procedures as they are added | [`tests/`](tests/) |

## Current state

The fixed-board prototype is implemented and was approved by the user on 2026-10-24. Easy opens a manually authored 5×5 board; Medium and Hard remain disabled until the separately authorized procedural-generation task. Rules live in `src/core/`, fixed level data in `src/levels/`, and visuals/input in `src/presentation/`. Core checks are in `tests/run_core.gd`; see `tests/README.md`. Treat `addons/godot_mcp_toolkit/` as third-party code and preserve its license and attributions.
