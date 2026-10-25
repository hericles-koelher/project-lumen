# Outdoor leaves — Candidate 01

Status: approved by the user on 2026-10-25 at 100% intensity. Godot integration remains pending.

## Artwork and motion

- Generate a separate dark outdoor branch inspired by the small foliage outside the upper-right window in the current background. This is a reconstructed candidate, not a pixel-exact cutout. Preserve the existing indoor plants.
- Texture: `assets/backgrounds/candidates/outdoor_leaves_candidate_01.png`, relative to the repository root; transparent 1254 × 1254 RGBA.
- Animate only the foliage layer. Keep the house, window, sky, and other background objects outside its deformation.
- Approved movement: one smooth four-second breeze with a small sway and a lighter secondary leaf movement. Fade movement in and out, return to the exact resting pose, then rest for 10–18 seconds before the next breeze.
- Anchor the lower stem; increase bending gradually toward the leaves. At 100% intensity the horizontal bend coefficient is 1.2% of image width (about 15 source pixels), with smaller vertical movement and flutter. The actual displacement depends on the vertex's distance from the stem root and the breeze envelope.
- Start the preview's first breeze after two seconds. Breeze now triggers another gesture immediately; pause, resting-pose comparison, and a percentage slider support review.
- Approved default intensity: 100%. The Godot Resource `assets/animations/animation_tuning.tres` exposes `outdoor_leaves_intensity_percent` via `@export`, with a 0–200% range. Animation integration must read this property.
- Preview the isolated layer on a neutral nighttime surface to assess its movement. Final integration still requires matching scale, placement, occlusion by the window frame, and any clean background layers needed to prevent duplicate static leaves.

## Files and provenance

- Self-contained animated preview: `outdoor-leaves-candidate-01.html`, beside this document.
- Full prompt: `outdoor-leaves-candidate-01.prompt.txt`, beside this document.
- Artwork rendered by built-in `image_gen.imagegen` on 2026-10-25 using `assets/backgrounds/quiet_ink_room_cozy.png` as the foliage/style reference. Rendering model and effort were not exposed.
- A native WebGL mesh animates the unchanged generated texture. No image generation is used to render animation frames.

## Review

The user approved this candidate at 100% intensity with two integration conditions: foliage must visibly belong outside the house, and any other outdoor branches must also animate. Keep all earlier approved presets: lamp 100%, breathing 75%, and ear 150%.

## Required integration checks

- Place all outdoor foliage behind the window frame and foreground indoor objects. Use separate layers or masks so branches cannot appear to pass through the house or over indoor furniture during motion.
- Inventory every visible outdoor branch in the final composition and give each one the approved intermittent motion. Avoid leaving duplicate painted branches stationary beneath their animated replacements.
- Use independent breeze scheduling per branch, retaining quiet rests so the foliage does not move in perfect synchronization.
- Check the full motion envelope, clipping, and occlusion in windowed and fullscreen layouts and at different aspect ratios. Keep foliage placement in the background's source-image coordinate system so the same cover/crop transform applies to the branches and window.
- Indoor plants are outside this approved outdoor-foliage scope.
