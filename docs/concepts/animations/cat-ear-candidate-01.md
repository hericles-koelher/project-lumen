# Sleeping cat ear twitch — Candidate 01

Status: corrected ear-only candidate approved by the user on 2026-10-25 at 150% intensity. Godot integration remains pending.

## Artwork and motion

- Reuse `assets/characters/candidates/sleeping_cat_candidate_01.png` without generating or repainting the approved cat illustration. No additional raster asset is needed for this candidate.
- Preserve the approved torso breathing: 75% intensity, a 4.8-second cycle, and maximum source displacement of 0.75% of image height.
- Twitch only the ear on the right side of the image. Its base blends smoothly into the stationary head; eyes, paws, and the other ear stay still.
- Correction after user review: replace the broad rectangular influence with three signed anatomical boundaries following the ear's upper edge, outer edge, and base. Blend inward from the root and keep the back, shoulder, and face outside the influence. The denser mesh limits deformation spill at the ear boundary. Verify the gesture with breathing disabled to distinguish torso breathing from unwanted ear deformation.
- Approved gesture: 0.62 seconds at 150% intensity, rotating the ear by approximately 9.45 degrees at peak, followed by a smaller return and settling motion. The reference amplitude at 100% is approximately 6.3 degrees.
- Schedule a new gesture 8–15 seconds after the previous gesture ends. The preview shows its first gesture after 2.5 seconds so it is easy to discover. The ear is not continuously looping or synchronized with breathing.
- The preview defaults to 150% ear intensity and provides Twitch now, pause/resume, a breathing toggle, and an ear-intensity slider. The breathing toggle isolates ear movement for inspection without changing the approved breathing preset.
- Godot intensity presets are exported in `src/presentation/animation_tuning.gd` and saved in `assets/animations/animation_tuning.tres`. Open the resource in the Inspector to edit the percentages. This prepares editor tuning; the running game will consume these values when the animations are integrated. Divide percentage values by 100 when applying their amplitude multipliers.
- Native WebGL vertex deformation animates the unchanged texture. A denser mesh than the breathing-only preview supports the smaller ear region. The final Godot mesh/shader and background layering remain pending.

## Files and provenance

- Self-contained preview: `cat-ear-candidate-01.html`, beside this document.
- Original cat artwork: built-in `image_gen.imagegen`, generated 2026-10-25; see [`cat-breathing-candidate-01.md`](cat-breathing-candidate-01.md) for its source and prompt.
- No new image generation was performed for the ear candidate; its motion is native procedural animation of the existing sprite.

## Review

The user approved the corrected ear-only deformation at 150% intensity. Preserve its appearance, quick return, and intermittent timing in Godot, with the same background alignment checks planned for breathing. Expose animation intensities through exported properties rather than hard-coded runtime constants.
