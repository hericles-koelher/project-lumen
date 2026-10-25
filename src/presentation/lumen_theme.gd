extends RefCounted
## Defines the shared visual palette, typography, and reusable control styles.

## The variable Nunito font used throughout the interface.
const FONT = preload("res://assets/fonts/Nunito-Variable.ttf")
## Dark foreground color used for text and board framing.
const INK := Color("192943")
## Base fill color for wall cells.
const WALL := Color("31445d")
## Light base fill color for playable cells and panels.
const CREAM := Color("f6efdf")
## Accent color used for pressed controls.
const SAGE := Color("91aa91")
## Fill color used for illuminated cells and hovered controls.
const SUNLIGHT := Color("f5c85b")
## Accent color used for keyboard focus.
const CORAL := Color("e98268")
## Color used for rule violations and warning indicators.
const WARNING := Color("d9534f")
## Primary warm text color for the dark Quiet Ink interface.
const UI_TEXT := Color("f6efdf")
## Secondary warm text color for supporting interface information.
const UI_MUTED := Color("c6c0b3")
## Restrained amber accent for outlines, highlights, and feedback.
const UI_ACCENT := Color("ffc04b")
## Muted peach edge used by unfocused controls.
const UI_EDGE := Color("d2ad8b")
## Horizontal interior padding for each side of a text button.
const BUTTON_PADDING := 40
## Vector atlas with dark glass and layered amber light; labels stay native.
const BUTTON_SURFACES = preload("res://assets/styles/quiet_ink_buttons.svg")


## Creates a rounded style box with the requested fill and optional border.
static func box(color: Color, radius: int = 14, border: Color = Color.TRANSPARENT, thickness: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.set_border_width_all(thickness)
	style.border_color = border
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


## Creates a transparent page style that adds breathing room without a visible card.
static func page_surface() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.set_content_margin(SIDE_LEFT, 28)
	style.set_content_margin(SIDE_RIGHT, 28)
	style.set_content_margin(SIDE_TOP, 22)
	style.set_content_margin(SIDE_BOTTOM, 22)
	return style


## Creates the dark, softly outlined glass surface for information-heavy screens.
static func content_card_surface(horizontal_padding: int = 34) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.12, 0.19, 0.88)
	style.set_corner_radius_all(22)
	style.set_border_width_all(2)
	style.border_color = Color(UI_EDGE, 0.88)
	style.set_content_margin(SIDE_LEFT, horizontal_padding)
	style.set_content_margin(SIDE_RIGHT, horizontal_padding)
	style.set_content_margin(SIDE_TOP, 28)
	style.set_content_margin(SIDE_BOTTOM, 28)
	return style


## Creates the more opaque Settings shell, proportioned to the approved mockup.
static func settings_card_surface() -> StyleBoxFlat:
	var style := content_card_surface(26)
	style.bg_color = Color(0.045, 0.10, 0.15, 0.95)
	style.border_color = Color(UI_EDGE, 0.96)
	style.shadow_color = Color(0.015, 0.025, 0.04, 0.45)
	style.shadow_size = 8
	style.set_content_margin(SIDE_TOP, 20)
	style.set_content_margin(SIDE_BOTTOM, 20)
	return style


## Frames the fixed Settings viewport while keeping its scrollbar near the edge.
static func settings_viewport_surface() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.055, 0.09, 0.30)
	style.set_corner_radius_all(12)
	style.set_border_width_all(1)
	style.border_color = Color(UI_EDGE, 0.30)
	style.set_content_margin(SIDE_LEFT, 12)
	style.set_content_margin(SIDE_RIGHT, 10)
	style.set_content_margin(SIDE_TOP, 12)
	style.set_content_margin(SIDE_BOTTOM, 12)
	return style


## Styles editable keyboard labels with the mockup's restrained amber keycap edge.
static func settings_keycap_surface(compact: bool = false) -> StyleBoxFlat:
	var style := box(Color(0.055, 0.10, 0.16, 0.80), 6, Color(UI_EDGE, 0.80), 1)
	style.content_margin_left = 4 if compact else 12
	style.content_margin_right = 4 if compact else 12
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


## Creates a thin Settings rule, using amber only beneath device-group headings.
static func settings_rule(vertical: bool = false, accent: bool = false) -> StyleBoxLine:
	var style := StyleBoxLine.new()
	style.vertical = vertical
	style.thickness = 1
	style.color = Color(UI_EDGE, 0.72 if accent else 0.24)
	return style


## Creates the dark, softly outlined surface used by the victory panel.
static func victory_surface() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style = content_card_surface()
	style.bg_color = Color(0.07, 0.12, 0.19, 0.96)
	style.set_corner_radius_all(24)
	style.border_color = UI_ACCENT
	style.set_content_margin(SIDE_LEFT, 38)
	style.set_content_margin(SIDE_RIGHT, 38)
	style.set_content_margin(SIDE_TOP, 30)
	style.set_content_margin(SIDE_BOTTOM, 30)
	return style


## Creates a stretchable atlas state; its halo extends beyond the hit area.
## State rows are normal, hover, pressed, disabled, and transparent focus.
static func button_surface(state_row: int, icon_only: bool = false) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = BUTTON_SURFACES
	style.region_rect = Rect2(0, state_row * 80, 160, 80)
	style.texture_margin_left = 40
	style.texture_margin_right = 40
	style.texture_margin_top = 39
	style.texture_margin_bottom = 39
	style.set_expand_margin_all(16)
	style.content_margin_left = 8 if icon_only else BUTTON_PADDING
	style.content_margin_right = 8 if icon_only else BUTTON_PADDING
	style.content_margin_top = 8 if icon_only else 10
	style.content_margin_bottom = 8 if icon_only else 10
	return style


## Builds the shared Godot theme from the project palette and font.
static func create_theme() -> Theme:
	var result := Theme.new()
	var body_font := FontVariation.new()
	body_font.base_font = FONT
	body_font.variation_opentype = {0x77676874: 500.0}
	result.default_font = body_font
	result.default_font_size = 20
	result.set_color("font_color", "Label", UI_TEXT)
	result.set_color("font_color", "Button", UI_TEXT)
	result.set_color("font_focus_color", "Button", UI_TEXT)
	result.set_color("font_hover_color", "Button", UI_TEXT)
	result.set_color("font_pressed_color", "Button", UI_TEXT)
	result.set_color("font_hover_pressed_color", "Button", UI_TEXT)
	result.set_color("font_disabled_color", "Button", UI_MUTED)
	result.set_type_variation("IconButton", "Button")
	var states := {"normal": 0, "hover": 1, "pressed": 2, "hover_pressed": 2, "disabled": 3, "focus": 4}
	for state in states:
		result.set_stylebox(state, "Button", button_surface(states[state]))
		result.set_stylebox(state, "IconButton", button_surface(states[state], true))
	var slider_track := StyleBoxFlat.new()
	slider_track.bg_color = Color("111e31")
	slider_track.set_corner_radius_all(7)
	slider_track.set_border_width_all(1)
	slider_track.border_color = Color("556176")
	var slider_fill := StyleBoxFlat.new()
	slider_fill.bg_color = Color("c3a05f")
	slider_fill.set_corner_radius_all(7)
	var slider_fill_highlight := StyleBoxFlat.new()
	slider_fill_highlight.bg_color = UI_ACCENT
	slider_fill_highlight.set_corner_radius_all(7)
	for slider_type in ["HSlider", "VSlider"]:
		result.set_stylebox("slider", slider_type, slider_track)
		result.set_stylebox("grabber_area", slider_type, slider_fill)
		result.set_stylebox("grabber_area_highlight", slider_type, slider_fill_highlight)
	var scrollbar_track := StyleBoxFlat.new()
	scrollbar_track.bg_color = Color(0.28, 0.34, 0.39, 0.72)
	scrollbar_track.set_corner_radius_all(5)
	scrollbar_track.content_margin_left = 5
	scrollbar_track.content_margin_right = 5
	var scrollbar_thumb := StyleBoxFlat.new()
	scrollbar_thumb.bg_color = Color("d2ad8b")
	scrollbar_thumb.set_corner_radius_all(5)
	var scrollbar_thumb_highlight := StyleBoxFlat.new()
	scrollbar_thumb_highlight.bg_color = UI_ACCENT
	scrollbar_thumb_highlight.set_corner_radius_all(5)
	result.set_stylebox("scroll", "VScrollBar", scrollbar_track)
	result.set_stylebox("grabber", "VScrollBar", scrollbar_thumb)
	result.set_stylebox("grabber_highlight", "VScrollBar", scrollbar_thumb_highlight)
	result.set_stylebox("grabber_pressed", "VScrollBar", scrollbar_thumb_highlight)
	result.set_constant("scrollbar_size", "VScrollBar", 8)
	result.set_constant("grabber_min_size", "VScrollBar", 28)
	return result
