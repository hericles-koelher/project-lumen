# Project Lumen — UI and Celebration Asset Brief

Status: the user selected B — Quiet Ink and warm sparkles; the generated art and reusable native Godot components are integrated. This document preserves the production brief and decisions. The final visual review of the delivered game remains open; see [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md).

Concept review: [`Soft Sage / Quiet Ink comparison`](concepts/ui_direction_comparison_v1.png) proposes two menu/button directions and small celebration alternatives. Generated with `image_gen.imagegen` on 2026-10-24; the tool did not expose its rendering model or effort. The user selected its Quiet Ink button/menu direction and Sparkles motif. This sheet is a mockup, not production exports. Decorative additions in the mockup are proposals, not new requirements; retain the approved sleeping cat, illustrated wordmark with hanging bulb, books, plants, and warm indoor lighting. The user explicitly requested restoring those details after the first integration review.

## Handoff to the producing model

Create a coordinated interface asset set for a small PC Akari puzzle game in Godot. The intended mood is simple, elegant, cute, calm, and welcoming. The user dislikes the current prominent white menu card and the current button treatment. Use the selected Quiet Ink composition and reusable button family.

The user approved Quiet Ink and sparkles and authorized implementation. The selected ink/navy surfaces, warm cream text, amber outline, freestanding composition, and finite light celebration are now implemented. Later requests refined the halo, circular mute button, and selected screen controls; their current appearance is documented in [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md). Game rules and board symbols remain independent.

The concept and state comparison have been reviewed. Deliver the selected reusable assets and integration specifications. Keep the decorative wordmark and interactive text separate from background illustrations. The implemented candidate is described in [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md).

## Approved direction and implementation

| Approved choice | Implemented candidate |
|---|---|
| B — Quiet Ink; no prominent white menu card | Freestanding controls over a warm illustrated room with sleeping cat; illustrated title and hanging bulb |
| Rounded dark buttons with restrained warm outlines | Native scalable surfaces with 40-pixel side padding, translucent dark fill, editable cream labels, warm ivory edges and soft amber hover/focus glow |
| Simple, elegant, cute, readable | Nunito retained; cream/amber interface colors over ink/navy; existing board palette retained |
| Simple ordinary transitions | 0.14-second page fade |
| Warm sparkles for victory | One 1.6-second textured burst, behind the panel and outside its readable action area |
| Centered victory panel over the solved board | Navy/amber surface, light dimmer, 0.22-second reveal; actions immediately available |

The integrated result still needs user visual and audio review. Confetti, a new soundtrack, remapping, and changes to board symbols are outside this selected direction.

## Screen coverage

| Screen | Required content and layout constraints |
|---|---|
| Main menu | Project title/identity; Start Game, Settings, Tutorial, Quit; a separate corner mute/unmute shortcut. |
| Start Game | Registered difficulties, currently Easy/Medium/Hard, plus Random Level at the same hierarchy; Back. Accommodate additional difficulties later. |
| Numbered levels | Level 1 through Level 10 for the chosen difficulty; Back. Use reusable tiles and separate text, rather than ten images with baked numbers. No locked/completed badges are required by the current scope. |
| Settings | Music volume control; windowed/fullscreen choice; Controls tab; Back. There is no separate effects-volume control and no remapping interface. |
| Controls reference | Clearly separated Keyboard / Mouse and Gamepad sections, with readable action labels and matching input glyphs. |
| Tutorial | Short pages with miniature illustrated boards and explanatory text inside one fixed-size card. Show page position, Next/Done, and Skip; omit Previous because the tutorial can be reopened from the main menu. |
| Gameplay | Preserve board readability at 5×5, 7×7, and 9×9; space for level/difficulty identity and action buttons. Remove the informational text beneath the board, leaving action buttons in that area. Random mode also needs New Random Level. |
| Numbered victory | Centered “Puzzle solved!” panel; Next Level, Restart, Exit to Menu. At the end of a difficulty, Next Level leads to the first level of the next registered difficulty; omit it only after the final level of the final difficulty. |
| Random victory | Same celebration family; New Random Level, Restart, and Exit to Menu. |

Layouts must support mouse, keyboard, and gamepad focus. Fullscreen/maximized backgrounds must cover the available area. Preserve content through resizing and aspect-ratio changes; do not bake screen coordinates into artwork.

## Functional constraints for the UI

- Random Level selects uniformly from every registered difficulty preset; adding a difficulty must not require redesigning the selection screen or changing fixed probability values.
- Restart preserves the current random difficulty, board, and seed, clearing only player moves. New Random Level draws a difficulty again and generates a board.
- Random seeds are hidden and held only for the active level session. Discard them on exit or replacement, with no seed history or seed-entry UI.
- Automatically save music volume, global mute, and display mode locally between launches. The music slider is the only volume setting; global mute silences music and effects and preserves their prior volumes.
- The Controls tab is a reference screen, not a control-remapping screen.
- During gameplay and victory, Exit to Menu, Escape, and gamepad B return to the main menu. Leaving any puzzle discards all player moves and its temporary random seed; sessions are never resumed. The current scope does not require level locks, completion tracking, scores, a seed browser, or an account/database interface.

## Asset and component deliverables

| ID | Deliverable | States / composition requirements |
|---|---|---|
| UI-01 | Menu background or revised background treatment | Full-screen scalable composition with safe space for title and controls. Supply optional foreground decoration as separate transparent layers. Reuse the current background only if it fits the approved redesign. |
| UI-02 | Title/identity treatment | Integrate the existing Project Lumen identity, or propose a revised treatment. A new application icon is not required. Keep title text editable. |
| UI-03 | Primary/secondary button family | Normal, hover, pressed, disabled, and keyboard/gamepad focus. Supply blank reusable surfaces or native Godot styling specifications, with text rendered separately. Focus may overlap hover or pressed states without hiding labels. |
| UI-04 | Compact icon-button family | Mute/unmute, Back, Restart, Quit, Next/Previous, and New Random Level if represented by icons. Icons can accompany text; they do not replace readable action labels where needed. Include focus/hover/pressed/disabled treatment. |
| UI-05 | Difficulty choice component | Reusable surface, optional difficulty accent/icon, label area, and focus/hover/pressed states. Support arbitrary registered difficulties; never bake the current three into a single image. |
| UI-06 | Numbered-level tile | Reusable tile with a separate number label and clear interaction states. Must fit ten entries without turning numbers into small or decorative text. |
| UI-07 | Settings tabs and selectors | Selected/unselected/focused tab treatment for settings and Controls; windowed/fullscreen selector with distinguishable selected state. |
| UI-08 | Music slider | Track, filled region, thumb, hover/focus/dragging states, and optional percentage placement. Native Godot shapes/styles are acceptable. |
| UI-09 | Audio status icons | Matched sound-on and muted symbols, legible at small sizes, consistent silhouettes and padding. Mute affects all audio and preserves existing volumes. |
| UI-10 | Input reference glyphs | Keyboard arrows, W/A/S/D, Space, X, Enter, Escape; mouse left/right buttons; gamepad D-pad, left stick, bottom/A, left/X, right/B. Provide neutral position cues alongside Xbox labels so generic controllers remain understandable. Keep text editable. |
| UI-11 | Tutorial composition | Page layout, navigation/page indicators, Skip treatment, and miniature board illustrations described below. Reuse board symbols where possible. |
| UI-12 | Victory surface and dimmer | A centered celebratory composition with a flexible action area and a separate dimming treatment. Show the solved board behind it. Match the new menu/button family without reintroducing the disliked white-card presentation as a default. |
| FX-01 | Warm victory sparkles | Approved light-themed sparkle pieces for a finite native animation. Transparent, isolated particle pieces or a small burst animation; no full-screen baked background. See motion specifications. |

## Tutorial illustration content

Use small, accurate Akari examples that match the actual board symbols and colors. Supply reusable diagram components or separate illustrations, not entire pages with embedded paragraphs.

- Goal and illumination: a bulb lights its own cell and travels orthogonally until a wall or board edge.
- Walls and clues: a numbered wall requires exactly that number of adjacent bulbs; only the four orthogonal neighbors count. Include a zero-clue example.
- Bulb conflict: two bulbs must not illuminate each other; show the violation using more than color alone.
- Player actions: place/remove a bulb; toggle X; bulb and X replace each other in one action.
- X as a player note: it is not a wall and does not block light or enforce a rule.
- Completion: all playable cells lit, no bulb conflicts, all numbered clues satisfied.

The tutorial appears automatically on the first launch, is marked as seen when opened, and is always accessible from the main menu. Skip returns to the main menu. These are implementation requirements that the composition must accommodate.

## Motion and celebration

### Confirmed behavior

Ordinary screen changes use simple transitions. Victory uses a finite warm sparkle animation, keeping the solved board and panel readable. Confetti is not selected.

### Production constraints and tuning

- Use the short native Godot page fade; its current duration is 0.14 seconds. Separate animation frames are unnecessary.
- Victory currently uses a 0.22-second panel reveal and one 1.6-second sparkle burst. Avoid a continuous loop, flashing screen, camera shake, or effects that cover action labels. Tune after user review.
- Reuse the generated transparent four-point light texture at varied sizes and tints. Keep scale and palette coherent with Quiet Ink.
- If textures are supplied, use transparent PNGs with generous transparent padding, approximately 64–128 px per particle. An optional assembled burst sprite sheet may be provided if it improves the chosen effect; state frame size, order, frame rate, anchor, and duration.
- Native Godot particles/tweens can animate the delivered pieces. Supply an animation reference or timing notes so integration does not have to guess the intended result.
- Keep celebration rendering behind the panel actions or outside their readable area. It must not intercept input or delay button availability.
- Existing sound effects and lo-fi music can be reused. New audio is not required by this brief; music volume and global mute must apply consistently during victory.

## Technical delivery recommendations

These are proposed integration specifications, not additional approved gameplay features.

- Target Godot 4.7.2, Compatibility renderer, PC mouse/keyboard/gamepad. The current base viewport is 1152 × 800; provide composition references at this size and at 1920 × 1080. Fullscreen art must tolerate cropping and resizing.
- Suggested raster background master: at least 2560 × 1600, with a clearly documented content-safe area. A flexible layered source is preferable to a rigid single-screen composition.
- Supply transparent PNG for isolated raster assets, SVG for genuinely vector-authored assets, or native Godot theme/style specifications for simple surfaces. Do not rasterize editable text into buttons or export a bitmap wrapped inside SVG as vector artwork.
- For stretchable raster surfaces, specify nine-slice margins and minimum sizes. Decorative corners must not distort when a control grows to fit longer English labels or future difficulties.
- Keep a consistent coordinate system, visual bounds, padding, stroke width, and centering across each icon family. Inspect the centering of internal shapes as well as outer silhouettes.
- Supply separate named files or a clearly indexed atlas. If using an atlas, include exact regions; do not return only a contact sheet intended for manual cropping.
- Use descriptive English snake_case filenames. Include a manifest mapping each file to its ID, purpose, states, source, and attribution/license information. Preserve editable masters if available.
- Include a palette/font/spacing sheet and a state-comparison sheet. At least one focused button must be shown over the actual background so text contrast can be judged.

## Existing references and reuse boundaries

The following are local references for consistency, not assets the producing model must copy unchanged:

- [`../assets/backgrounds/menu_concept.png`](../assets/backgrounds/menu_concept.png): current illustrated background.
- [`../assets/branding/project_lumen_icon_concept.png`](../assets/branding/project_lumen_icon_concept.png): current project icon concept.
- [`../assets/styles/PALETTE.md`](../assets/styles/PALETTE.md): current cream, ink, sage, sunlight, and coral palette with Nunito typography.
- [`../assets/icons/`](../assets/icons/): existing bulb, X, cursors, centered shared cell selector, and action icons.
- [`../assets/fonts/Nunito-Variable.ttf`](../assets/fonts/Nunito-Variable.ttf): existing font; keep its license if reused.
- [`../assets/ASSET_MANIFEST.md`](../assets/ASSET_MANIFEST.md): existing provenance and audio sources.
- [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md): authoritative current input behavior.
- [`REFINEMENT_PLAN.md`](REFINEMENT_PLAN.md): implementation packages, dependencies, and user review checkpoints.
- [`../TASKS.md`](../TASKS.md): agreed upcoming flow, preferences, and remaining tasks.

Board symbols, rules, generated puzzles, the recently corrected shared cell selector, and cursor behavior are not automatically part of the menu redesign. Propose any change to these separately. Preserve existing assets until replacements are reviewed.

## Review and acceptance

1. Present proposed menu/button directions and an overview of the chosen celebration alternatives before bulk production.
2. Obtain the user's visual choice, then produce one consistent asset family.
3. Deliver screen mockups, component/state sheets, reusable exports, editable sources where available, and the manifest.
4. Check readable text on every button state, keyboard/gamepad focus, centered icons, safe resizing, and unobstructed victory actions.
5. Keep art production and Godot integration distinct in the handoff: mockups are references, not ready-made interactive screens.

## Copyable request for another model

> Use this document as the UI/asset production brief for Project Lumen, a small Godot Akari game. Use the approved B — Quiet Ink composition and button family, replacing the prominent white menu card. Use warm sparkles for the victory celebration. Respect the confirmed screen flow and component inventory, keep labels separate from artwork, and distinguish your visual proposals from already approved requirements. Use the selected concept and current implementation guide as references; consult the user before introducing a new direction. Do not change game rules or implement unrelated features.
