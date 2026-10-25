# Development Plan

## Delivered foundation

The prototype now includes repository conventions, Godot setup, provisional art/audio, independent Akari rules and board/state models, deterministic valid generation, seeded difficulty presets, and mouse/keyboard/gamepad interaction. See [`../TASKS.md`](../TASKS.md) for completed work and [`ARCHITECTURE.md`](ARCHITECTURE.md) for the implementation map.

## Current planning milestone

The two refinement tasks are implemented and awaiting the user's final playthrough and approval. Their behavior, package history, remaining review checkpoints, and criteria are consolidated in [`REFINEMENT_PLAN.md`](REFINEMENT_PLAN.md). The completed visual-asset handoff remains documented in [`UI_ASSET_BRIEF.md`](UI_ASSET_BRIEF.md).

The current integrated flow includes the fixed Settings shell with a shared scroll viewport, edge-aligned arrow assets and controller hints, active-tab/tutorial focus behavior, circular audio shortcut, stronger amber halo, and automatic mouse-pointer hiding. Automated verification previously passed 731 checks; the latest Settings layout has not been run through the game yet. Current UI screenshots are in the README; manual user review remains before task approval.

## Following milestone

After the refinements, prepare a playable build for another person, collect feedback, and agree on subsequent priorities. Platform and delivery decisions belong to that later task; planning does not authorize distribution now.

## Working approach

Keep each package reviewable and verify the behavior it changes. Update current documentation when implementation lands. Commit completed work after user approval and push only on explicit request. A solver, unique-solution guarantee, remapping screen, and saved puzzle progression are not part of the current refinement scope.
