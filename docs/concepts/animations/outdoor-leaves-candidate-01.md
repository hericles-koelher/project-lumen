# Outdoor leaves — Candidate 01

Status: approved by the user on 2026-10-25 at 100% intensity; Godot integration complete. Combined in-game review was approved by the user on 2026-10-25.

## Artwork and motion

- Generate a separate dark outdoor branch inspired by the small foliage outside the upper-right window in the current background. This is a reconstructed candidate, not a pixel-exact cutout. Preserve the existing indoor plants.
- Texture: `assets/backgrounds/candidates/outdoor_leaves_candidate_01.png`, relative to the repository root; transparent 1254 × 1254 RGBA.
- Animate only the foliage layer. Keep the house, window, sky, and other background objects outside its deformation.
- Approved movement: one smooth four-second breeze with a small sway and a lighter secondary leaf movement. Fade movement in and out, return to the exact resting pose, then rest for four seconds before the next breeze. The original 10–18-second pause was shortened by the user during in-game review.
- Anchor the lower stem; increase bending gradually toward the leaves. At 100% intensity the horizontal bend coefficient is 1.2% of image width (about 15 source pixels), with smaller vertical movement and flutter. The actual displacement depends on the vertex's distance from the stem root and the breeze envelope.
- Start the preview's first breeze after two seconds. Breeze now triggers another gesture immediately; pause, resting-pose comparison, and a percentage slider support review.
- Approved default intensity: 100%. The Godot Resource `assets/animations/animation_tuning.tres` exposes `outdoor_leaves_intensity_percent` via `@export`, with a 0–200% range. The controller reads this value and passes the resulting wind and flutter amplitudes to the shader.
- The clean plate removes the original painted branches before the five replacement instances are drawn. Godot places each in the background's source coordinates and clips it to its open window pane; source-aligned indoor silhouettes cover the branches where foreground objects occlude them.

The current timing controls are exported as `outdoor_leaves_breeze_duration_seconds` and `outdoor_leaves_rest_seconds`, both set to 4 seconds under Outdoor Foliage in `animation_tuning.tres`. Each branch therefore starts a new cycle about every eight seconds, retaining its independent start offset. The current saved intensity override is 160%; the original approved motion reference remains 100%.

## Files and provenance

- Self-contained animated preview: `outdoor-leaves-candidate-01.html`, beside this document.
- Full prompt: `outdoor-leaves-candidate-01.prompt.txt`, beside this document.
- Artwork rendered by built-in `image_gen.imagegen` on 2026-10-25 using `assets/backgrounds/quiet_ink_room_cozy.png` as the foliage/style reference. Rendering model and effort were not exposed.
- A native WebGL mesh animates the unchanged generated texture. No image generation is used to render animation frames.

## Review

The user approved this candidate at 100% intensity with two integration conditions: foliage must visibly belong outside the house, and any other outdoor branches must also animate. All five visible outdoor branch positions are integrated with independent schedules. Keep all earlier approved presets: lamp 100%, breathing 75%, and ear 150%.

## Godot integration and validation

- Foliage is placed behind the window frame and foreground indoor objects. Clipped pane controls and source-aligned polygon overlays keep branches from crossing into indoor space.
- The five replaced branches are LeftUpper, RightUpper, RightSidePane, LeftLower, and RightLower. Each has its own start offset, four-second breeze, and fixed four-second rest; duplicate painted branches are removed from the clean plate.
- GPU Compatibility renders confirmed that the branches moved while their changed pixels stayed within the windowpane masks. Full menu captures were checked at 1152 × 800, 1920 × 1080, and 2560 × 1080. Combined in-game review was approved by the user on 2026-10-25.
- Indoor plants are outside this approved outdoor-foliage scope. See [`ANIMATION_IMPLEMENTATION.md`](../../ANIMATION_IMPLEMENTATION.md) for source coordinates, masks, and validation.
