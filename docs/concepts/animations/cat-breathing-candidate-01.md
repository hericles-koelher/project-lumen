# Sleeping cat breathing — Candidate 01

Status: approved by the user on 2026-10-25 at 75% intensity; Godot integration complete. Combined in-game review was approved by the user on 2026-10-25.

## Artwork and motion

- Separate transparent sleeping-cat illustration based on the existing background cat. The generated candidate completes the silhouette cropped by the background's left edge; it is not a pixel-exact extraction.
- PNG: `assets/characters/candidates/sleeping_cat_candidate_01.png`, relative to the repository root; 1585 × 992 RGBA with real alpha.
- A native WebGL mesh gently lifts the back and torso using a smooth 4.8-second breathing cycle. The approved default intensity is 75%: maximum vertex displacement is 0.75% of the image height, approximately 7.4 source pixels; the visible torso moves less according to its location.
- The head, ears, paws, and lower tail are excluded from the breathing deformation. The approved ear twitch is layered separately in the same Godot shader.
- Controls allow pausing, comparing the static pose, and adjusting intensity. Godot preserves the approved 75% intensity and 4.8-second rhythm using the shared exported tuning Resource.
- The clean background plate removes the original painted cat before the separate sprite is placed, avoiding a doubled silhouette. The sprite uses source-image coordinates, sits at the original desk edge, and scales to 35% of its source size.
- The candidate is approved and integrated; final combined in-game review remains pending.

## Files and provenance

- Self-contained preview: `cat-breathing-candidate-01.html`, in this directory.
- Prompt: `cat-breathing-candidate-01.prompt.txt`, in this directory.
- Artwork rendered by built-in `image_gen.imagegen`, referencing `assets/backgrounds/quiet_ink_room_cozy.png`. Rendering model and effort were not exposed by the image tool.
- The browser mesh provides native procedural movement; it does not generate or repaint the texture. Godot uses a dense mesh and native shader on the unchanged transparent PNG.

## Godot integration and review

The `ambient_background.gd` controller uses the clean plate at the original 1586 × 992 background extent, placing the cat at source coordinate `(-210, 480)` with scale `0.35`. Its 192 × 128 mesh and shader apply the approved breathing lift while keeping the head and paws stationary. An isolated GPU Compatibility render showed the approved torso motion within the cat silhouette. Combined in-game review remains pending; see [`ANIMATION_IMPLEMENTATION.md`](../../ANIMATION_IMPLEMENTATION.md).
