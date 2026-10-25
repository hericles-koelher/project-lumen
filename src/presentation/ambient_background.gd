extends TextureRect
## Draws the room's clean plate and keeps its animated layers in source-image coordinates.
## Puzzle state and input are independent of these decorative motions.

## Clean room plate without the original painted cat or outdoor branches.
const CLEAN_PLATE = preload("res://assets/backgrounds/quiet_ink_room_animation_clean.png")
## Approved transparent character and branch artwork.
const CAT_TEXTURE = preload("res://assets/characters/candidates/sleeping_cat_candidate_01.png")
const FOLIAGE_TEXTURE = preload("res://assets/backgrounds/candidates/outdoor_leaves_candidate_01.png")
## Shared transparent light overlay and native deformation shaders.
const LAMP_HALO = preload("res://assets/fx/candidates/lamp_glow_candidate_01.png")
const CAT_SHADER = preload("res://src/presentation/shaders/sleeping_cat.gdshader")
const FOLIAGE_SHADER = preload("res://src/presentation/shaders/outdoor_foliage.gdshader")
## Background reference size and open-window rectangles excluding wood and sill.
const SOURCE_EXTENT := Vector2(1586.0, 992.0)
const WINDOW_PANES := [Rect2(354, 0, 978, 646), Rect2(1420, 0, 166, 451)]
## Every replaced outdoor branch has an independent breeze schedule.
const BRANCHES := [
	{"name": "LeftUpper", "rect": Rect2(220, -20, 280, 280), "flip": true, "pane": 0},
	{"name": "RightUpper", "rect": Rect2(1200, 150, 320, 320), "flip": false, "pane": 0},
	{"name": "RightSidePane", "rect": Rect2(1430, 30, 260, 260), "flip": false, "pane": 1},
	{"name": "LeftLower", "rect": Rect2(430, 500, 280, 280), "flip": false, "pane": 0},
	{"name": "RightLower", "rect": Rect2(1130, 515, 280, 280), "flip": false, "pane": 0},
]
## Signed ear-motion samples from the approved isolated-ear preview.
const EAR_KEYS := [Vector2(0, 0), Vector2(0.16, 1), Vector2(0.34, -0.24), Vector2(0.54, 0.30), Vector2(1, 0)]

## Shared Inspector-editable preset resource supplied by the main presentation.
var _tuning: Resource
## Scaled scene root, keeping all overlays aligned with the background cover crop.
var _source_canvas: Node2D
## Runtime materials and independent gesture state.
var _cat_material: ShaderMaterial
var _lamp: Sprite2D
var _foliage: Array[Dictionary] = []
var _elapsed := 0.0
var _ear_start_seconds := -1.0
var _next_ear_seconds := 2.5
## Cosmetic randomness never consumes procedural puzzle randomness.
var _cosmetic_random := RandomNumberGenerator.new()


## Stores the shared preset before or after the background enters the tree.
func configure(tuning: Resource) -> void:
	_tuning = tuning


## Builds one persistent layered scene behind every game screen.
func _ready() -> void:
	texture = CLEAN_PLATE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_cosmetic_random.randomize()
	_source_canvas = Node2D.new()
	_source_canvas.name = "AnimatedRoomLayers"
	add_child(_source_canvas)
	_create_foliage()
	_restore_indoor_occlusion()
	_create_cat()
	_create_lamp()
	resized.connect(_layout_layers)
	_layout_layers()
	_update_motion()


## Applies the exact cover transform used by the root TextureRect to all overlays.
func _layout_layers() -> void:
	if not is_instance_valid(_source_canvas):
		return
	var cover_scale := maxf(size.x / SOURCE_EXTENT.x, size.y / SOURCE_EXTENT.y)
	_source_canvas.scale = Vector2.ONE * cover_scale
	_source_canvas.position = (size - SOURCE_EXTENT * cover_scale) * 0.5


## Creates the approved branches inside clipped window panes, behind indoor objects.
func _create_foliage() -> void:
	var panes: Array[Control] = []
	for index in range(WINDOW_PANES.size()):
		var pane := Control.new()
		pane.name = "OutdoorPane%d" % index
		pane.position = WINDOW_PANES[index].position
		pane.size = WINDOW_PANES[index].size
		pane.clip_contents = true
		pane.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_source_canvas.add_child(pane)
		panes.append(pane)
	var leaf_mesh := _create_grid_mesh(FOLIAGE_TEXTURE.get_size(), 64, 64)
	for index in range(BRANCHES.size()):
		var specification: Dictionary = BRANCHES[index]
		var branch := MeshInstance2D.new()
		branch.name = specification.name
		branch.mesh = leaf_mesh
		branch.texture = FOLIAGE_TEXTURE
		branch.modulate = Color(0.65, 0.72, 0.9, 1.0)
		var material := ShaderMaterial.new()
		material.shader = FOLIAGE_SHADER
		branch.material = material
		var rect: Rect2 = specification.rect
		var pane_index: int = specification.pane
		branch.position = rect.position - WINDOW_PANES[pane_index].position
		branch.scale = rect.size / FOLIAGE_TEXTURE.get_size()
		if specification.flip:
			branch.position.x += rect.size.x
			branch.scale.x *= -1.0
		panes[pane_index].add_child(branch)
		_foliage.append({"material": material, "next": 2.0 + index * 0.8, "start": -1.0})


## Repaints fixed indoor silhouettes from the same plate over the outdoor layers.
## These source-aligned polygons make the foliage stay behind plants, lamp and books.
func _restore_indoor_occlusion() -> void:
	_add_foreground_patch("LeftIndoorPlant", PackedVector2Array([
		Vector2(0, 0), Vector2(285, 0), Vector2(300, 205), Vector2(370, 230),
		Vector2(375, 340), Vector2(430, 375), Vector2(432, 490), Vector2(475, 520),
		Vector2(488, 570), Vector2(545, 604), Vector2(575, 700), Vector2(550, 756), Vector2(0, 756),
	]))
	_add_foreground_patch("RightIndoorObjects", PackedVector2Array([
		Vector2(1505, 240), Vector2(1586, 235), Vector2(1586, 992), Vector2(1280, 992),
		Vector2(1280, 760), Vector2(1310, 680), Vector2(1305, 610), Vector2(1324, 550),
		Vector2(1420, 500), Vector2(1420, 450), Vector2(1485, 450), Vector2(1485, 350),
	]))


## Samples a fixed polygon from the identical background texture without repainting it.
func _add_foreground_patch(patch_name: String, points: PackedVector2Array) -> void:
	var patch := Polygon2D.new()
	patch.name = patch_name
	patch.polygon = points
	patch.uv = points
	patch.texture = CLEAN_PLATE
	_source_canvas.add_child(patch)


## Places the approved cat at the original desk edge with one dense deformable mesh.
func _create_cat() -> void:
	var cat := MeshInstance2D.new()
	cat.name = "SleepingCat"
	cat.texture = CAT_TEXTURE
	cat.mesh = _create_grid_mesh(CAT_TEXTURE.get_size(), 192, 128)
	cat.position = Vector2(-210, 480)
	cat.scale = Vector2.ONE * 0.35
	_cat_material = ShaderMaterial.new()
	_cat_material.shader = CAT_SHADER
	cat.material = _cat_material
	_source_canvas.add_child(cat)


## Adds a transparent warm overlay aligned with the room's existing globe lamp.
func _create_lamp() -> void:
	_lamp = Sprite2D.new()
	_lamp.name = "LampLight"
	_lamp.texture = LAMP_HALO
	_lamp.position = SOURCE_EXTENT * Vector2(0.876, 0.606)
	_lamp.scale = Vector2.ONE * (SOURCE_EXTENT.x * 0.22 / float(LAMP_HALO.get_width()))
	var light_material := CanvasItemMaterial.new()
	light_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lamp.material = light_material
	_source_canvas.add_child(_lamp)


## Makes a shared indexed grid dense enough for the small approved deformations.
func _create_grid_mesh(extent: Vector2, columns: int, rows: int) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for row in range(rows + 1):
		for column in range(columns + 1):
			var uv := Vector2(float(column) / columns, float(row) / rows)
			vertices.append(Vector3(uv.x * extent.x, uv.y * extent.y, 0.0))
			uvs.append(uv)
	for row in range(rows):
		for column in range(columns):
			var top_left := row * (columns + 1) + column
			indices.append_array(PackedInt32Array([top_left, top_left + 1, top_left + columns + 1, top_left + 1, top_left + columns + 2, top_left + columns + 1]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


## Advances ambient time without changing the current screen or accepting input.
func _process(delta: float) -> void:
	_elapsed += minf(delta, 0.1)
	_update_motion()


## Applies live tuning and independently schedules the quiet decorative gestures.
func _update_motion() -> void:
	if _cat_material == null or _lamp == null:
		return
	var breath := (1.0 - cos(_elapsed / 4.8 * TAU)) * 0.5
	_cat_material.set_shader_parameter("breath_lift", 0.01 * _gain("cat_breathing_intensity_percent", 75.0) * breath)
	_cat_material.set_shader_parameter("ear_angle", _ear_angle())
	var glow_cycle := (1.0 - cos(_elapsed / 6.0 * TAU)) * 0.5
	_lamp.modulate.a = clampf(lerpf(0.04, 0.22, glow_cycle) * _gain("lamp_light_intensity_percent", 100.0), 0.0, 1.0)
	for branch in _foliage:
		_update_branch(branch)


## Interpolates the approved ear-only gesture and schedules an independent quiet rest.
func _ear_angle() -> float:
	if _ear_start_seconds < 0.0 and _elapsed >= _next_ear_seconds:
		_ear_start_seconds = _elapsed
	if _ear_start_seconds < 0.0:
		return 0.0
	var phase := (_elapsed - _ear_start_seconds) / 0.62
	if phase >= 1.0:
		_ear_start_seconds = -1.0
		_next_ear_seconds = _elapsed + _cosmetic_random.randf_range(8.0, 15.0)
		return 0.0
	for index in range(1, EAR_KEYS.size()):
		var next_key: Vector2 = EAR_KEYS[index]
		if phase <= next_key.x:
			var previous_key: Vector2 = EAR_KEYS[index - 1]
			var fraction := clampf((phase - previous_key.x) / (next_key.x - previous_key.x), 0.0, 1.0)
			fraction = fraction * fraction * (3.0 - 2.0 * fraction)
			return 0.11 * _gain("cat_ear_intensity_percent", 150.0) * lerpf(previous_key.y, next_key.y, fraction)
	return 0.0


## Runs one Inspector-timed breeze, then returns the branch to its exact resting pose.
func _update_branch(branch: Dictionary) -> void:
	if branch.start < 0.0 and _elapsed >= branch.next:
		branch.start = _elapsed
	var phase := 0.0
	var envelope := 0.0
	var sway := 0.0
	if branch.start >= 0.0:
		var duration := maxf(0.1, _seconds("outdoor_leaves_breeze_duration_seconds", 4.0))
		phase = (_elapsed - float(branch.start)) / duration
		if phase >= 1.0:
			branch.start = -1.0
			branch.next = _elapsed + _seconds("outdoor_leaves_rest_seconds", 4.0)
			phase = 0.0
		else:
			envelope = pow(sin(PI * phase), 2.0)
			sway = envelope * sin(phase * TAU)
	var gain := _gain("outdoor_leaves_intensity_percent", 100.0)
	var material: ShaderMaterial = branch.material
	material.set_shader_parameter("wind", 0.012 * gain * sway)
	material.set_shader_parameter("flutter", 0.002 * gain * envelope)
	material.set_shader_parameter("wind_phase", phase * TAU)


## Reads nonnegative Inspector timing values in seconds.
func _seconds(property_name: String, fallback: float) -> float:
	if _tuning == null:
		return fallback
	return maxf(0.0, float(_tuning.get(property_name)))


## Reads current Inspector percentages as amplitude multipliers.
func _gain(property_name: String, fallback: float) -> float:
	if _tuning == null:
		return fallback / 100.0
	return clampf(float(_tuning.get(property_name)) / 100.0, 0.0, 2.0)


## Returns visible motion values for isolated integration checks without moving the scene.
func get_motion_snapshot() -> Dictionary:
	var branches: Array[Dictionary] = []
	for branch in _foliage:
		var material: ShaderMaterial = branch.material
		branches.append({"wind": material.get_shader_parameter("wind"), "flutter": material.get_shader_parameter("flutter"), "next": branch.next, "start": branch.start})
	return {"elapsed": _elapsed, "breath_lift": _cat_material.get_shader_parameter("breath_lift"), "ear_angle": _cat_material.get_shader_parameter("ear_angle"), "lamp_alpha": _lamp.modulate.a, "branches": branches, "cover_scale": _source_canvas.scale, "cover_offset": _source_canvas.position}
