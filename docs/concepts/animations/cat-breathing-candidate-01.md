# Sleeping cat breathing — Candidate 01

Status: approved by the user on 2026-10-25 at 75% intensity. Godot integration remains pending.

## Artwork and motion

- Separate transparent sleeping-cat illustration based on the existing background cat. The generated candidate completes the silhouette cropped by the background's left edge; it is not a pixel-exact extraction.
- PNG: `assets/characters/candidates/sleeping_cat_candidate_01.png`, relative to the repository root; 1585 × 992 RGBA with real alpha.
- A native WebGL mesh gently lifts the back and torso using a smooth 4.8-second breathing cycle. The approved default intensity is 75%: maximum vertex displacement is 0.75% of the image height, approximately 7.4 source pixels; the visible torso moves less according to its location.
- The head, ears, paws, and lower tail are excluded from the deformation. The ear twitch is a separate upcoming animation candidate.
- Controls allow pausing, comparing the static pose, and adjusting intensity. Preserve the approved 75% intensity and 4.8-second rhythm during Godot integration.
- Preview the isolated sprite on a dark surface to assess motion without covering the original cat with a second cat. Final background integration requires a clean background layer where the original cat was painted, plus placement and masking review.
- The candidate is approved; background preparation and Godot integration remain separate pending work.

## Files and provenance

- Self-contained preview: `cat-breathing-candidate-01.html`, in this directory.
- Prompt: `cat-breathing-candidate-01.prompt.txt`, in this directory.
- Artwork rendered by built-in `image_gen.imagegen`, referencing `assets/backgrounds/quiet_ink_room_cozy.png`. Rendering model and effort were not exposed by the image tool.
- The browser mesh provides native procedural movement; it does not generate or repaint the texture. The eventual Godot equivalent should use a suitable mesh or shader after motion approval.
