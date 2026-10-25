# Decorative lamp light — Candidate 01

Status: visual and motion candidate approved by the user on 2026-10-25; Godot integration complete. Combined in-game review was approved by the user on 2026-10-25.

## Visual and motion

- Preserve the existing background and lamp silhouette. Add only a transparent warm amber light overlay.
- Keep the existing steady lamp visible throughout the animation; do not switch it off or pulse the entire background.
- Approved preview timing: one smooth six-second cycle. Overlay opacity varies from 0.04 to 0.22 with eased transitions.
- Overlay center: approximately 87.6% across and 60.6% down the source background. Overlay width: 22% of the source image width, with the original square aspect preserved.
- In Godot, the overlay stays in the background's source-image coordinate system and uses the same cover/crop transform. Screen coordinates alone would drift when the aspect ratio changes.
- The accompanying HTML preview uses the real generated texture and unchanged background. It provides pause, intensity, and overlay-off comparison controls. Its CSS animation is a preview of the proposed timing, not the final Godot implementation.

## Files and provenance

- Generated source: `assets/fx/candidates/lamp_glow_candidate_01.png`, relative to the repository root. Transparent PNG, 1254 × 1254 RGBA.
- Preview: `lamp-light-candidate-01.html`, in this directory. Images are embedded so the preview is self-contained.
- Rendered with the built-in `image_gen.imagegen` tool, using `assets/backgrounds/quiet_ink_room_cozy.png` as a style and color reference. The image tool did not expose its rendering model or reasoning effort.
- Full generation prompt: `lamp-light-candidate-01.prompt.txt`, in this directory.

## Review

The user approved this preview's light variation. Godot uses the existing transparent halo as an additive overlay centered at the specified source-image position, with the approved six-second cycle and live Inspector intensity. Actual renders were checked across 1152 × 800, 1920 × 1080, and 2560 × 1080 layouts; the changed pixels remained localized around the lamp. The user approved the combined in-game presentation on 2026-10-25. See [`ANIMATION_IMPLEMENTATION.md`](../../ANIMATION_IMPLEMENTATION.md) for the full layer and validation notes.
