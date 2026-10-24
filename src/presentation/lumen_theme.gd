extends RefCounted

const FONT = preload("res://assets/fonts/Nunito-Variable.ttf")
const INK := Color("192943")
const WALL := Color("31445d")
const CREAM := Color("f6efdf")
const SAGE := Color("91aa91")
const SUNLIGHT := Color("f5c85b")
const CORAL := Color("e98268")
const WARNING := Color("d9534f")


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


static func create_theme() -> Theme:
	var result := Theme.new()
	var body_font := FontVariation.new()
	body_font.base_font = FONT
	body_font.variation_opentype = {0x77676874: 500.0}
	result.default_font = body_font
	result.default_font_size = 20
	result.set_color("font_color", "Label", INK)
	result.set_color("font_color", "Button", INK)
	result.set_color("font_focus_color", "Button", INK)
	result.set_color("font_hover_color", "Button", INK)
	result.set_color("font_pressed_color", "Button", INK)
	result.set_color("font_hover_pressed_color", "Button", INK)
	result.set_color("font_disabled_color", "Button", Color("7e8790"))
	result.set_stylebox("normal", "Button", box(CREAM, 14, INK, 2))
	result.set_stylebox("hover", "Button", box(SUNLIGHT, 14, INK, 2))
	result.set_stylebox("pressed", "Button", box(SAGE, 14, INK, 2))
	result.set_stylebox("disabled", "Button", box(Color("dedbcf"), 14, Color("a5aaa5"), 1))
	result.set_stylebox("focus", "Button", box(Color.TRANSPARENT, 14, CORAL, 3))
	return result
