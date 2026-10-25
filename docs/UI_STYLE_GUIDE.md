# Quiet Ink Interface

The user selected concept B — Quiet Ink and warm victory sparkles on 2026-10-24. This is the implementation reference for the resulting interface. The menu refinements and original animation set have completed user approval. The title startup now includes an additional requested fade-in adjustment awaiting review. The [2026-10-25 visual review](VISUAL_REVIEW.md) contains a later screen-by-screen assessment and proposed follow-ups.

## Composition and text

Menus float over a dark, calm central area of the illustrated evening background. `Visuals.page_surface()` supplies transparent padding without an enclosing white card. Keep interactive labels, level numbers, and buttons as native editable Godot controls. Nunito remains the body/interface font; warm cream labels have a small dark shadow. The decorative menu wordmark is a separate transparent image to preserve the hand-lettered title and hanging bulb from the approved concept, with an accessible Project Lumen name.

Settings keeps a fixed title, tab header, content viewport, and footer across Audio & Display and Controls. The large inset content viewport has the same dimensions for both tabs; overflowing tab content scrolls inside it while the title, tabs, and Back button stay fixed. Dedicated SVG chevrons and their LB/RB hints fit entirely inside the inner card's left and right horizontal boundaries, using symmetric insets. LB/RB appear directly below when a controller is connected. The arrows have no button frame. Clicking an arrow or tab, or pressing either shoulder, changes tabs. Opening a tab focuses it. Changing display mode updates only its button text and preserves the page, focus, and scroll position. The music slider is deliberately narrower than the Settings card. Each tutorial page focuses Next (Done on the final page), including when revisiting earlier pages. The Controls reference uses editable keycap labels, including Xbox names and neutral button positions. Board symbols, cell colors, the shared selection marker, and mouse cursors retain their approved behavior and resources.

The [approved Settings mockup](concepts/settings-approved-prototype.png) is the visual reference. At the base logical viewport, the Settings card is 940 × 641 pixels and its content frame is 888 × 388 pixels. Use a 40-pixel title, 27-pixel section headings, 20-pixel command labels, and 56-pixel reference rows. Separate the two device columns with a vertical rule; use amber heading rules and quiet row separators. Arrow/WASD keys are individual keycaps. D-pad and left-stick outlines accompany their labels, while A/X/B use colored circular badges and neutral position captions. The scrollbar reserves its width and becomes visible only when needed. Music volume and display mode follow the same heading/rule spacing. Preserve the existing illustrated background; the mockup's background is a visual concept rather than a replacement asset.

The Settings shell is created once per visit. Switching tabs replaces only the inner content and updates the existing tab highlights; the card, header, scroll container, and footer remain instantiated and opaque. The entrance fade runs when opening Settings from another screen. Selecting the active tab again preserves its content and scroll. Back, Escape, and B exit directly to the main menu from either tab.

## Reusable surfaces

`src/presentation/lumen_theme.gd` defines the reusable button family. Use it for main-menu actions, difficulty choices, level tiles, tabs, tutorial navigation, and gameplay/victory actions.

| State | Treatment |
|---|---|
| Default | Dark navy glass with 40% base alpha, subtle vertical shading, muted peach edge (#D2AD8B), fully opaque cream text |
| Hover | Amber ribbon with a bright thin core, soft light spreading inward/outward, and restrained warm illumination inside the dark glass |
| Pressed / selected | Amber ribbon with a reduced halo and subtle warm inner light; labels remain fully opaque cream |
| Keyboard / gamepad focus | Transparent luminous overlay preserving the underlying dark glass, with the same amber core and inward/outward halo |
| Disabled | Dark translucent glass, subdued gray border and readable muted text |

Each text button uses 40 logical pixels of interior padding on each side and the minimum width required by its editable label, centered within its parent rather than stretched across a page or row. Level tiles follow the same rule. Horizontal action rows, tabs, and level-grid columns use a shared 14-pixel logical gap. The icon-only mute shortcut has a square 48 × 48 logical-pixel hit area, circular outline, centered 24-pixel icon (explicit horizontal/vertical icon alignment and balanced SVG bounds), and eight-pixel interior margins; it does not inherit text-button padding.

`assets/styles/quiet_ink_buttons.svg` contains five vector states, stacked in 160 × 80 regions: normal, hover, pressed, disabled, and focus. A 16-pixel transparent gutter holds the halo outside each button's hit area. The outer light reaches up to 14 pixels and uses a slightly stronger falloff, while the core colors and glass opacity remain unchanged. `StyleBoxTexture` uses nine-slice margins of 40 pixels horizontally and 39 vertically, with 16-pixel draw expansion, to preserve rounded ends as labels change width. The glass base stays at 40% alpha; separate, subtle amber lighting adds the reference's illuminated interior. The luminous core grades from #FFD46C through #FFC04B to #F0A82D. Text and icons are separate native control content, so they remain fully opaque. `Visuals.content_card_surface()` provides a dark translucent navy surface with a soft warm outline for the tutorial and gameplay. The gameplay card uses 18-pixel horizontal padding to preserve board and action space; tutorial uses 34 pixels. Settings uses `settings_card_surface()` with 26-pixel horizontal padding and a more opaque navy fill for readability. The victory panel uses the same card family with a stronger amber edge over the dimmed board.

Selection pages leave a deliberate gap before Back: one button height on the difficulty page and half a button height on level selection and Settings.

## Raster artwork and scaling

| Resource | Source size | Use |
|---|---|---|
| `assets/backgrounds/quiet_ink_room_cozy.png` | 1586 × 992 RGB | Preserved approved source composition. |
| `assets/backgrounds/quiet_ink_room_animation_clean.png` | 1586 × 992 RGB | Runtime clean plate beneath the separate cat and outdoor foliage. Every layer shares the same cover crop, preserving aspect ratio. |
| `assets/branding/project_lumen_wordmark.png` | 1774 × 887 RGBA | Hand-lettered two-line title with hanging light bulb; preserve alpha and aspect ratio. |
| `assets/fx/victory_sparkle.png` | 1254 × 1254 RGBA | One four-point warm light sprite with transparent padding and real alpha. Preserve the alpha and scale down in Godot. |

These images were rendered by `image_gen.imagegen` for this project. The image service did not expose its underlying model or effort. Existing prototype artwork remains available as source history. See [`../assets/ASSET_MANIFEST.md`](../assets/ASSET_MANIFEST.md) for provenance.

The project uses `canvas_items` scaling with `window/stretch/aspect="expand"` and a base viewport of 1152 × 800. The logical drawing area expands with the window ratio, while the background uses aspect-preserving cover. This avoids pillarboxing at widescreen and ultrawide ratios. The earlier cooler `quiet_ink_room.png` remains as a superseded source candidate.

## Motion and input

The room now uses the approved lamp-glow cycle, torso breathing at 75%, ear-only twitch at 150%, and five independently scheduled outdoor branches with a 100% approved reference and a current user-tuned 160% intensity. Each breeze lasts four seconds, followed by a fixed four-second rest. The title now fades in over 0.4 seconds, holds for 0.3 seconds, then flickers three times with 150 ms gaps on its first menu appearance in each application run before keeping its 270% lamp halo. The fade and hold are Inspector-adjustable. Board bulbs use Soft pop plus Quick wave. Keep the central interface area clear and the outdoor layers behind the window and indoor silhouettes. See [`ANIMATION_IMPLEMENTATION.md`](ANIMATION_IMPLEMENTATION.md) for layer coordinates, timing, and Inspector tuning.

Ordinary page changes use a short 0.14-second fade. Victory reveals its panel over 0.22 seconds and creates one 1.6-second burst of 18 warm sparkles. The textured pieces scale, fade, and drift around the panel, behind its controls. No looping celebration, full-screen flash, or input delay is used.

The free mouse pointer hides after three seconds of mouse inactivity or immediately on keyboard/controller use, then returns on real mouse movement or a click. Focus changes and scene exit restore it. See [`INPUT_CONTROLS.md`](INPUT_CONTROLS.md) for drift filtering and cell-selection handoff.

`src/presentation/victory_sparkles.gd` accepts a parent-supplied texture, ignores mouse/focus input, and removes itself after its lifetime. Restart and page changes remove the complete victory overlay, including any remaining particles. Underlying board/actions stay outside the focus sequence while the victory panel is open.

## Review

Check the complete flow at the default 1152 × 800 viewport, maximized, and fullscreen: headings, all button states, slider/keycaps, tutorial text and diagrams, every board size, and victory controls. Pay particular attention to readable focus and quiet background detail. Physical Xbox and visual/audio feedback remain user-led checks.

Compare actual Godot renders against an approved mockup at the same resolution and tab state before presenting a visual implementation. On 2026-10-25, both Settings tabs were rendered at 1152 × 800, 1672 × 941 (the mockup's size), 1920 × 1080, and 1152 × 640. The updated Controls screenshot is in [`screenshots/settings-controls.png`](screenshots/settings-controls.png). The isolated flow runner also checks fixed geometry, arrow alignment, and actual overflow scrolling. These refinements have since completed user approval. The [latest visual review](VISUAL_REVIEW.md) adds 40 captures of every base-size screen and representative 1920 × 1080 and 1152 × 640 layouts, including both Settings tabs. It distinguishes concrete defects from optional refinements; its proposed follow-ups have not been implemented.
