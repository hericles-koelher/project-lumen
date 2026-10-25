# Illuminated title startup — Candidate 01

Status: approved by the user on 2026-10-25; Godot integration complete. Combined in-game review was approved by the user on 2026-10-25.

## Artwork and motion

- Reuse the existing transparent `assets/branding/project_lumen_wordmark.png` unchanged, preserving its lettering, decorative marks, hanging bulb, and baked glow. No new rendered artwork is needed.
- Present the title against the unchanged current room background. Change only the title's light intensity; do not flash or deform the background.
- Approved sequence: three initial flickers with 150 ms intervals, followed immediately by a strong warm halo around the title lamp. The title and lamp stay steadily illuminated afterward; there is no middle pause or final blink group.
- Each flicker lasts 80 ms; the interval means the rest after a flicker ends and before the next begins. Initial flickers briefly brighten the dim title. Keep the silhouette visible, with an initial dim brightness of 22% at 100% intensity.
- The sequence is variable-driven rather than fixed keyframes. Three flickers, their 150 ms gaps, and the 60 ms settle bring the title to full brightness at 0.64 s. The halo fades in smoothly over 0.25 s, reaching full strength at 0.89 s.
- Flicker intensity scales the depth of the light variation, not timing or final brightness. Zero gives a steady title; the final steady appearance always matches the existing artwork. The preview supports a 0–200% range with a brightness floor of 8%.
- After the last flicker, grow and fade in the strong halo over the wordmark's lamp; keep it steady afterward. Reuse `assets/fx/candidates/lamp_glow_candidate_01.png`, centered at 78.5% / 43% within the wordmark and displayed at 32% of its width. The halo opacity is capped at 100%; at the approved 270% setting, its 20% base opacity reaches 54%. Scale the halo from 90% to 100% while revealing it. Do not animate the background or apply the added glow to the entire title.
- The preview provides Replay startup, pause/resume, original steady-title comparison, intensity sliders for flicker and halo, and numeric controls for initial blink count and gap. Timing changes replay automatically. Preview controls do not save edits into the Godot Resource; approved values are recorded there separately.
- `assets/animations/animation_tuning.tres` exports `title_startup_intensity_percent`, `title_lamp_halo_intensity_percent`, `title_initial_blink_count`, and `title_initial_blink_interval_ms`. Approved values: flicker 100%, halo 270% (0–300% range), initial count 3, initial interval 150 ms.

## Godot integration requirements

- Play this sequence once on the title's first visible main-menu appearance in each application run. If the first-launch tutorial appears first, wait until the title is visible rather than running the effect behind the tutorial.
- Keep the played flag outside the rebuilt menu controls so returning from Settings, a puzzle, or Tutorial does not replay it. Do not persist this flag across application launches.
- Finish with steady title illumination and a halo around its lamp. Do not delay button input or menu navigation; if the player leaves early, returning to the menu shows the settled title and halo.
- The full title participates, including its lamp; no global scene flicker, moving lettering, or unrelated decorative animation.
- Match the approved preview timing and intensity using the exported Resource. Keep gameplay and input logic independent from visual animation.
- The main controller retains the once-per-launch flag outside the rebuilt menu controls. A 140 ms startup delay allows the menu's existing entrance fade to finish; if the first-launch tutorial is shown first, the flag is not consumed until the title menu is opened.

## Files and provenance

- Self-contained preview: `title-startup-candidate-01.html`, beside this document.
- Native motion source: `title-startup-candidate-01.js`, beside this document. The preview builder embeds this code and reads its initial values from the Godot tuning Resource; image data is embedded without modifying the source textures.
- Native preview code animates brightness on the existing generated wordmark; it does not repaint or replace the texture.
- Original artwork provenance remains in `assets/ASSET_MANIFEST.md`. No image generation was performed for this motion candidate.

## Review

The user approved the flicker count, 150 ms rhythm, transition into steady illumination, and 270% lamp halo on 2026-10-25. Godot uses the existing wordmark and halo textures, starts only on the first menu appearance in an application run, and displays the settled title on later menu returns. The title overlay reads live intensity values from the shared Resource. Actual renders were checked at 1152 × 800, 1920 × 1080, and 2560 × 1080; input remains available during the animation. Combined in-game review remains pending; see [`ANIMATION_IMPLEMENTATION.md`](../../ANIMATION_IMPLEMENTATION.md).
