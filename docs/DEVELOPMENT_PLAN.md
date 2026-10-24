# Development Plan

## Delivered foundation

The prototype now includes repository conventions, Godot setup, provisional art/audio, independent Akari rules and board/state models, deterministic valid generation, seeded difficulty presets, and mouse/keyboard/gamepad interaction. See [`../TASKS.md`](../TASKS.md) for completed work and [`ARCHITECTURE.md`](ARCHITECTURE.md) for the implementation map.

## Current planning milestone

The two active parent tasks are overall appearance/gameplay refinement and menu/level-selection refinement. Their agreed behavior, work packages, dependency order, approval checkpoints, and completion criteria are consolidated in [`REFINEMENT_PLAN.md`](REFINEMENT_PLAN.md). The planned interface asset handoff is [`UI_ASSET_BRIEF.md`](UI_ASSET_BRIEF.md).

The functional flows are implemented and are ready for user review. Final art integration remains gated so the user can switch models and approve the visual direction before production. New menus/buttons and celebration assets require user review before production.

## Following milestone

After the refinements, prepare a playable build for another person, collect feedback, and agree on subsequent priorities. Platform and delivery decisions belong to that later task; planning does not authorize distribution now.

## Working approach

Keep each package reviewable and verify the behavior it changes. Update current documentation when implementation lands. Commit completed work after user approval and push only on explicit request. A solver, unique-solution guarantee, remapping screen, and saved puzzle progression are not part of the current refinement scope.
