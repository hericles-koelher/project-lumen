# Project Lumen — Agent Guide

## Mission

This repository contains a 2D Akari (Light Up) game developed with Godot. The initial goal is to build a small, functional, easy-to-understand game, prioritizing correct rules and simple architecture before investing in art and visual themes.

## How to get started

1. Read this guide and use the index below to find task-specific context.
2. Check the current Git state and existing files before editing.
3. Before substantive implementation, verify the primary agent's current model and reasoning effort using the current turn's runtime metadata. Compare them with the task's role and the user's explicit session choice; follow the preflight rules below.
4. Make small, coherent changes that fit the project's current stage; keep documentation and implementation aligned.
5. When finished, summarize changed files, decisions, and checks performed. Never claim something was tested if it was not.

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
- **Interactive decisions:** When a doubt or ambiguity arises, consult the user instead of silently choosing an interpretation. Ask one focused question at a time, explain the concrete choice and your recommendation, and wait for the answer before making dependent changes.
- **Playtest coordination:** When the user is testing the game, leave manual interaction and usability feedback to them. Do not automate clicks or stop/restart their play session while they are testing; coordinate any necessary interruption first.

## Subagent delegation

- **Delegate independent work without another user prompt:** When the user has authorized a task and its scope is clear, delegate separable work that can make useful progress in parallel. This permission applies to execution only; it does not authorize starting a later task, changing scope, bypassing user checkpoints, committing, or pushing.
- **Choose models by responsibility:** Use GPT-6.1 Sol with high reasoning effort for planning, orchestration, final review, and complex or ambiguous problems. Use GPT-6 Luna for well-specified, bounded implementation tasks; choose its reasoning effort to match the requested care and task complexity. The primary agent remains responsible for the user-facing workflow and final result.
- **Choose Luna's reasoning effort deliberately:** Use **Low** for tiny, mechanical changes with an exact location and acceptance check; **Medium** for routine, well-scoped implementation across a small number of files; **High** for multi-file features, careful edge-case handling, or tasks where the user explicitly asks for extra attention; use **Extra High** only for unusually demanding implementation that remains bounded and has a settled design. When available, **Max** is reserved for exceptional, unusually complex work where that extra analysis is likely to improve correctness. Effort does not replace clear scope, review, or verification.
- **Check actual availability first:** Before assigning a model or tool, inspect what the current collaboration and image-generation tools actually support, including model IDs and effort settings. These repository instructions express preferences; they cannot enable a model/tool or guarantee that a request will be routed as intended. If a requested option is unavailable, choose a supported alternative and report the limitation.
- **Verify before implementation:** At each new task boundary, inspect the primary agent's current turn context or equivalent execution metadata before substantive work. Distinguish the repository policy, global defaults, requested overrides, applied conversation settings, and the model/effort recorded for the actual turn. A self-description or a spawn argument alone is not execution proof. Mark missing evidence as unverified. If a different primary model/effort is required, coordinate the session change with the user; this file cannot switch the running model. An explicit user choice takes precedence.
- **Use a two-stage subagent start:** Request the intended model and effort explicitly when spawning a subagent, using a fresh context when required for overrides. Its first assignment must be a short read-only orientation with no implementation. Verify the child's own new turn context, excluding inherited historical context, then send the bounded implementation assignment. If the requested setting was not applied, resolve the mismatch or report it before releasing implementation. Do not create audit documents unless the user asks; a concise status message is sufficient.
- **Plan before parallelizing:** The primary agent establishes the work plan, dependencies, interfaces, acceptance criteria, and any user decisions first. Delegate only tasks whose inputs and contracts are ready. Independent code and visual work may run in parallel once the visual specification is settled and the required user approval has been given.
- **Give every assignment an explicit boundary:** State the objective, necessary project context and references, constraints, dependencies, exact deliverable, validation expected, and the files/directories the subagent exclusively owns. List shared files as read-only. Do not assign two agents to edit the same file or overlapping asset/output paths; if ownership cannot be isolated, keep that work with the primary agent or run it sequentially.
- **Use image generation for rendered assets:** Use the available image-generation tool to render requested artwork. GPT-6 Luna may prepare or coordinate a bounded image task, but must not substitute code-drawn or text-only output for a requested rendered asset. The primary agent checks the generated result, provenance, dimensions, and repository integration. Existing visual approval gates still apply.
- **Integrate and validate centrally:** Subagents return their changes, a concise summary, files changed, checks run, and unresolved issues. The primary agent inspects all diffs, resolves integration conflicts, checks consistency with Project Lumen's architecture and documentation, and runs relevant validation before presenting the work to the user. Treat agent output as a proposal until reviewed.
- **Delegate only when worthwhile:** Avoid delegation for tiny edits, tightly coupled changes, work with unresolved decisions, or cases where coordination and integration would cost more than parallel progress. Do not spawn subagents merely because the tool exists.

## Repository index

| Topic | Summary | Further details |
|---|---|---|
| Project overview | Goals, first-version scope, and project vocabulary | [`docs/PROJECT_OVERVIEW.md`](docs/PROJECT_OVERVIEW.md) |
| Architecture | Boundaries between rules, data, generation, and presentation | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| Game rules | Akari rules, lighting, and win condition | [`docs/GAME_RULES.md`](docs/GAME_RULES.md) |
| Procedural generation | Seed, parameters, validity, and generator evolution | [`docs/PROCEDURAL_GENERATION.md`](docs/PROCEDURAL_GENERATION.md) |
| Technical decisions | Important technical decisions and their rationale | [`docs/TECHNICAL_DECISIONS.md`](docs/TECHNICAL_DECISIONS.md) |
| Engineering practices | Required coding and collaboration standards | [`docs/ENGINEERING_PRACTICES.md`](docs/ENGINEERING_PRACTICES.md) |
| Development plan | Project roadmap, delivered foundation, and next milestones | [`docs/DEVELOPMENT_PLAN.md`](docs/DEVELOPMENT_PLAN.md) |
| Refinement execution plan | Confirmed menu/gameplay scope, implementation packages, dependencies, validation, and user checkpoints | [`docs/REFINEMENT_PLAN.md`](docs/REFINEMENT_PLAN.md) |
| Development setup | Godot version, running the project, and MCP plugin connection | [`docs/DEVELOPMENT_SETUP.md`](docs/DEVELOPMENT_SETUP.md) |
| Asset inventory | Current asset baseline, remaining interface art, and production status | [`docs/ASSET_INVENTORY.md`](docs/ASSET_INVENTORY.md) |
| UI asset brief | Approved Quiet Ink direction, component inventory, and warm sparkle production scope | [`docs/UI_ASSET_BRIEF.md`](docs/UI_ASSET_BRIEF.md) |
| UI implementation guide | Approved Quiet Ink surfaces, artwork scaling, editable controls, and finite sparkle animation | [`docs/UI_STYLE_GUIDE.md`](docs/UI_STYLE_GUIDE.md) |
| Asset provenance | Sources, licenses, and status of included assets | [`assets/ASSET_MANIFEST.md`](assets/ASSET_MANIFEST.md) |
| Task list | Actionable project work, ordered by priority | [`TASKS.md`](TASKS.md) |
| Prototype definition | Confirmed prototype decisions and open design questions | [`docs/PROTOTYPE_DEFINITION.md`](docs/PROTOTYPE_DEFINITION.md) |
| Input controls | Mouse, keyboard, gamepad bindings, pointer visibility, and focus navigation | [`docs/INPUT_CONTROLS.md`](docs/INPUT_CONTROLS.md) |
| Current UI screenshots | README gallery captures of the implemented menu, gameplay, Settings, tutorial, and victory views | [`docs/screenshots/`](docs/screenshots/) |
| Game source | Scripts and scenes, grouped by responsibility | [`src/`](src/) |
| Verification | Automated tests or repeatable validation procedures as they are added | [`tests/`](tests/) |

## Current state

The fixed-board prototype, procedural generation, keyboard interaction, and Xbox support were approved on 2026-10-24. The annotation action replaces an existing bulb with X; this behavior was also tested and approved on 2026-10-24. The current refinement implementation provides ten seeded numbered levels per difficulty plus a uniformly selected random mode; 70% of walls are numbered, rounded down. The current refinement implementation includes a five-page tutorial, a fixed-size scrollable Settings viewport with edge-aligned arrow assets and controller hints, active-tab/tutorial focus, a circular audio shortcut, amber illuminated buttons, and pointer auto-hide after three seconds or on alternate input. Quiet Ink menu resources and warm victory sparkles are integrated; the final manual user review remains pending. Rules live in `src/core/`, configuration/generation in `src/generation/`, selection/bindings/controller state in `src/input/`, the level catalog in `src/levels/`, and views/controller in `src/presentation/`. For isolated checks, see `tests/README.md`; for controls, see `docs/INPUT_CONTROLS.md`. Treat `addons/godot_mcp_toolkit/` as third-party code and preserve its license and attributions.
