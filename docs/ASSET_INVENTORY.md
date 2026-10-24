# Prototype Asset Inventory

Status: initial asset set approved on 2026-10-24. In-game visual and audio integration, loop transition review, and tuning remain part of prototype implementation.

This inventory covers the approved prototype. An asset may be a reusable Godot theme, drawn shape, text element, or imported file; each visual state does not require a separate image. The user prefers generated images in a consistent style and describes the desired presentation as simple, elegant, and cute.

## Board visuals

| Item | Required appearance and states |
|---|---|
| Playable cell | Light base, readable border, yellow illuminated state |
| Wall | Dark base shared by numbered and unnumbered walls |
| Numbered clue | Readable digits 0–4 over the wall; normal and red exceeded-clue states |
| Bulb | Recognizable symbol; normal and red conflict states |
| No-bulb annotation | X overlay, readable on both illuminated and unilluminated cells |
| Board frame and grid | Consistent spacing and boundaries across 5×5, 7×7, and 9×9 boards |

Compose cell backgrounds, symbols, and warning styling so their combinations remain readable. A separate complete board image per difficulty is unnecessary.

## Interface visuals

| Item | Required appearance and states |
|---|---|
| Screen background | Simple shared background for menu and gameplay |
| Button theme | Shared normal, hover, pressed, and disabled appearances; readable labels |
| Typography | Font or built-in font configuration for title, buttons, difficulty labels, clues, and victory message |
| Project title | Text treatment for Project Lumen; a custom illustrated logo is unnecessary for the prototype |
| Gameplay labels | Current difficulty label and a short mouse-controls legend |
| Victory presentation | "Puzzle solved!" message and a panel or overlay that leaves Restart, Back to Menu, and Quit accessible |

Button labels: Easy, Medium, Hard, Restart, Back to Menu, and Quit. Reuse a single button theme rather than producing six separate button images. The controls legend explains existing actions; it does not provide puzzle hints.

## Expanded scope

On 2026-10-24, the user requested a comprehensive inventory including the previously optional application icon, cell hover feedback, sound effects, and background music. These are now part of asset planning. Acquisition methods and production specifications remain to be agreed. An inventory item may be a native Godot resource rather than an imported file.

## Shared visual resources

- A coordinated palette for backgrounds, panels, cells, walls, lighting, annotations, text, and warnings.
- A reusable Godot theme defining fonts, spacing, borders, corner radii, and control states.
- Typography styles for titles, buttons, clue digits, difficulty labels, instructions, and victory text; one legible font family may cover all roles.
- Consistent icon proportions, stroke weights, and padding.
- Editable source artwork and theme resources, plus exported files where required.

## Additional board states

- Mouse-hover outline for playable cells, compatible with bulbs, illumination, and X annotations.
- Custom mouse arrow cursor for general navigation and a matching pointing-hand cursor over clickable controls and playable cells. Use the hotspot at the cursor tip.
- A matching outlined hover frame for playable board cells; walls remain non-interactive and do not use the hover cursor.
- Conflict outlines or symbols that complement red coloring and remain readable without color alone.
- Board frame, gutters, and background separation for every difficulty.
- Composition references for empty, illuminated, bulb, conflicting bulb, X, illuminated X, wall, numbered wall, and exceeded-clue states.
- Readability checks at 5×5, 7×7, and 9×9 sizes. Reuse layered components rather than producing a complete image for every combination.

## Interface components and icons

- Main menu and gameplay backgrounds, sharing resources where practical.
- Difficulty-selection layout and gameplay header showing the active difficulty.
- Button styling for normal, hover, pressed, disabled, and focus states. Focus styling does not introduce keyboard board navigation into the prototype.
- Restart, Back to Menu, Quit, and victory icons, if used alongside text labels.
- Left- and right-mouse-button symbols and a short English controls legend.
- Victory panel and backdrop that preserve visibility of the solved board and its available actions.
- Consistent margins, alignment, and sizing across the menu, gameplay, and victory presentation.
- Standard system cursor as the baseline; assess a matching custom pointer during acquisition.

## Motion and visual feedback

- Brief bulb placement and removal transitions.
- Illumination updates and annotation appearance/removal feedback.
- Button hover and press feedback.
- Immediate conflict warning and correction feedback.
- Restrained victory reveal and simple screen transitions.

These can use native Godot animation or tweens; separate sprite sheets are not assumed. Effects must preserve immediate feedback, board readability, and responsive controls.

## Sound effects

First-pass synthesized WAV cues are in `../assets/audio/sfx/`; see the asset manifest for filenames and provenance.

| Event | Sound direction |
|---|---|
| Place bulb | Soft switch, click, or warm pluck |
| Remove bulb | Related but distinguishable softer click or lower pluck |
| Add X annotation | Quiet tick or tap |
| Remove X annotation | Subtle alternate tick or tap |
| Button hover | Very quiet cue; evaluate repetition fatigue |
| Button activation | Gentle confirmation click |
| Restart | Soft reset cue |
| Return to menu | Subtle transition cue, potentially shared with button activation |
| New rule violation | Restrained warning when a conflict or exceeded clue is introduced; do not loop while it remains |
| Puzzle solved | Brief, warm chime or musical phrase |

Reuse sounds or controlled variations where appropriate. Avoid duplicate clicks for one action and excessive layering when a bulb placement also triggers a warning.

## Background music

The user selected "Our Morning Coffee" by Turning_Pages for the prototype. Its source, license, and local file are recorded in [`../assets/ASSET_MANIFEST.md`](../assets/ASSET_MANIFEST.md). Verify the loop transition during in-game integration.

- Calm, relaxing lo-fi instrumental music suitable for concentration during a leisurely puzzle session.
- Gentle beats, warm chords, soft keys or guitar, and restrained bass. Avoid vocals, abrupt drops, aggressive percussion, and dramatic changes.
- At least one seamless loop reusable in the menu and gameplay; separate difficulty tracks are unnecessary.
- Keep vinyl noise or ambience subtle and avoid distracting clicks that resemble game feedback.
- Consistent perceived loudness, with sound effects remaining audible and comfortable.
- Clean loop boundaries and gentle fades. Moving between menu and gameplay should not cause abrupt cuts or unnecessary restarts.
- Agree on loop duration, acquisition source, license, and delivery formats before production. Preserve lossless or editable sources when available.

## Application identity

- Square application icon representing the light/puzzle concept and readable at small sizes.
- Editable icon master and exports suitable for the selected PC build targets.
- Title or wordmark consistent with the game's typography.
- Boot splash treatment using the same branding if adopted; a separate illustration is unnecessary.

## Asset manifest and delivery

- Track adopted assets and their provenance in [`../assets/ASSET_MANIFEST.md`](../assets/ASSET_MANIFEST.md).
- Record each adopted asset's ID, intended use, creator, source, license, attribution requirements, format, and production/acquisition status. Record provenance for generated assets too.
- Preserve supplied licenses and editable sources; distinguish third-party assets from first-party work.
- Organize resources by board, UI, fonts, branding, music, and sound effects as needed, with English names.
- Decide image dimensions, transparency, filtering, font sizes, and audio export settings during production.
- Review all board combinations and UI states at each difficulty and supported window size.
- Audition music loops and frequent effects together for clipping, fatigue, transitions, and relative volume.

## Production and review criteria

- Prefer reusable components and overlays over separate images for every combination.
- Keep symbols, digits, and annotations readable at the largest board size.
- Check overlapping states: illuminated annotation, conflicting bulb, and exceeded numbered wall.
- If external fonts, artwork, or audio are adopted, record source and license with the assets.
- Store first-party asset names and accompanying documentation in English.
