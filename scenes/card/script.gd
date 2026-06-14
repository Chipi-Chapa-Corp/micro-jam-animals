extends Control
class_name CardScene

signal clicked(card_id: String)

@export var kind: String = "prey"
@export var suit: String = "air"
@export var value: int = 4
@export var art_scale: float = CARD_ART_SCALE
@export var art_rotation_degrees: float = 0.0

const HOVER_ELEVATION: Vector2 = Vector2(0.0, -7.0)
const HOVER_SCALE: Vector2 = Vector2(1.035, 1.035)
const HOVER_SHADOW_OFFSET: Vector2 = Vector2(0.0, 10.0)
const HOVER_SHADOW_SCALE: Vector2 = Vector2(1.055, 1.055)
const BASE_SHADOW_MODULATE: Color = Color(0.0, 0.0, 0.0, 0.0)
const HOVER_SHADOW_MODULATE: Color = Color(0.0, 0.0, 0.0, 0.24)
const PICKUP_TILT_DEGREES: float = 3.0
const PICKUP_DURATION: float = 0.08
const ALIGN_DURATION: float = 0.11
const LOWER_DURATION: float = 0.12
const HIGHLIGHT_DURATION: float = 0.1
const HIGHLIGHT_HOLD_DURATION: float = 0.12
const SHAKE_OFFSET: Vector2 = Vector2(7.0, 0.0)
const SHAKE_DURATION: float = 0.035
const FLIP_EDGE_SCALE_X: float = 0.18
const FLIP_ELEVATION: Vector2 = Vector2(0.0, -12.0)
const FLIP_SHADOW_OFFSET: Vector2 = Vector2(0.0, 15.0)
const FLIP_SHADOW_SCALE: Vector2 = Vector2(1.08, 1.08)
const FLIP_SHADOW_MODULATE: Color = Color(0.0, 0.0, 0.0, 0.28)
const FLIP_LIFT_DURATION: float = 0.14
const FLIP_LOWER_DURATION: float = 0.18
const SUIT_WATER: String = "water"
const SUIT_LAND: String = "land"
const SUIT_AIR: String = "air"
const KIND_PREDATOR: String = "predator"
const WATER_COLOR: Color = Color(111.0 / 255.0, 111.0 / 255.0, 175.0 / 255.0)
const LAND_COLOR: Color = Color(126.0 / 255.0, 160.0 / 255.0, 118.0 / 255.0)
const AIR_COLOR: Color = Color(171.0 / 255.0, 177.0 / 255.0, 188.0 / 255.0)
const CARD_ART_CENTER: Vector2 = Vector2(55.0, 77.0)
const CARD_ART_SIZE: Vector2 = Vector2(75.0, 80.0)
const CARD_ART_SCALE: float = 1.4
const HOLOGRAPHIC_SHADER: Shader = preload("res://scenes/card/holographic.gdshader")
const HOLOGRAPHIC_CARD_VALUES: Array[int] = [1, 11, 12, 13]

var id: String:
	get:
		return get_card_id()

@onready var shadow: Panel = $Shadow
@onready var face: Panel = $Face
@onready var back: TextureRect = $Back
@onready var color_panel: Panel = $Face/Color
@onready var predator_gradient: Control = $Face/PredatorGradient
@onready var art: TextureRect = $Face/Art
@onready var top_value: Label = $Face/TopValue
@onready var top_suit: TextureRect = $Face/TopSuit
@onready var bottom_value: Label = $Face/BottomValue
@onready var bottom_suit: TextureRect = $Face/BottomSuit

var _base_shadow_position: Vector2 = Vector2.ZERO
var _base_face_position: Vector2 = Vector2.ZERO
var _base_back_position: Vector2 = Vector2.ZERO
var _hover_tween: Tween
var _shake_tween: Tween
var _holographic_overlay: Panel


func _ready() -> void:
	_create_holographic_overlay()
	_base_shadow_position = shadow.position
	_base_face_position = face.position
	_base_back_position = back.position
	_sync_pivots()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_refresh_art()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_sync_pivots()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(id)
		accept_event()


func configure(
	next_kind: String,
	next_suit: String,
	next_value: int,
	next_art_scale: float = CARD_ART_SCALE,
	next_art_rotation_degrees: float = 0.0
) -> void:
	kind = next_kind
	suit = next_suit
	value = next_value
	art_scale = next_art_scale
	art_rotation_degrees = next_art_rotation_degrees
	_refresh_art()


func get_card_id() -> String:
	return "%s_%s_%s" % [kind, suit, value]


func shake_feedback() -> void:
	if _shake_tween:
		_shake_tween.kill()

	var face_start_position := _base_face_position
	var shadow_start_position := _base_shadow_position
	face.position = face_start_position
	shadow.position = shadow_start_position

	_shake_tween = create_tween()
	_shake_tween.set_trans(Tween.TRANS_SINE)
	_shake_tween.set_ease(Tween.EASE_IN_OUT)
	_shake_tween.tween_property(face, "position", face_start_position - SHAKE_OFFSET, SHAKE_DURATION)
	_shake_tween.parallel().tween_property(
		shadow, "position", shadow_start_position - SHAKE_OFFSET, SHAKE_DURATION
	)
	_shake_tween.tween_property(face, "position", face_start_position + SHAKE_OFFSET, SHAKE_DURATION)
	_shake_tween.parallel().tween_property(
		shadow, "position", shadow_start_position + SHAKE_OFFSET, SHAKE_DURATION
	)
	_shake_tween.tween_property(face, "position", face_start_position, SHAKE_DURATION)
	_shake_tween.parallel().tween_property(shadow, "position", shadow_start_position, SHAKE_DURATION)


func pulse_highlight(hold_duration: float = HIGHLIGHT_HOLD_DURATION) -> void:
	if _hover_tween:
		_hover_tween.kill()
	if _shake_tween:
		_shake_tween.kill()

	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_SINE)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(face, "position", _base_face_position + HOVER_ELEVATION, HIGHLIGHT_DURATION)
	_hover_tween.parallel().tween_property(face, "scale", HOVER_SCALE, HIGHLIGHT_DURATION)
	_hover_tween.parallel().tween_property(
		shadow, "position", _base_shadow_position + HOVER_SHADOW_OFFSET, HIGHLIGHT_DURATION
	)
	_hover_tween.parallel().tween_property(shadow, "scale", HOVER_SHADOW_SCALE, HIGHLIGHT_DURATION)
	_hover_tween.parallel().tween_property(shadow, "modulate", HOVER_SHADOW_MODULATE, HIGHLIGHT_DURATION)
	await _hover_tween.finished

	if hold_duration > 0.0:
		await get_tree().create_timer(hold_duration).timeout

	_tween_lower()
	await _hover_tween.finished


func tween_discard_to(
	target_global_position: Vector2, target_z_index: int, move_duration: float, flip_duration: float
) -> Tween:
	if _hover_tween:
		_hover_tween.kill()
	if _shake_tween:
		_shake_tween.kill()

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot_offset = size * 0.5
	z_index = target_z_index
	face.rotation_degrees = 0.0
	_reset_flip_elevation()
	_show_front()

	var target_modulate := modulate
	target_modulate.a = 0.0
	var edge_scale := Vector2(FLIP_EDGE_SCALE_X, 1.0)

	AudioManager.play_card_taken()
	var move_tween := create_tween()
	move_tween.set_trans(Tween.TRANS_CUBIC)
	move_tween.set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(self, "global_position", target_global_position, move_duration)

	var fade_tween := create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.tween_interval(move_duration * 0.55)
	fade_tween.tween_property(self, "modulate", target_modulate, move_duration * 0.45)

	var flip_tween := create_tween()
	flip_tween.set_trans(Tween.TRANS_SINE)
	flip_tween.set_ease(Tween.EASE_IN_OUT)
	flip_tween.tween_property(face, "scale", edge_scale, flip_duration * 0.44)
	flip_tween.tween_callback(Callable(self, "_show_back"))
	flip_tween.tween_property(back, "scale", Vector2.ONE, flip_duration * 0.56)
	_tween_flip_elevation(move_duration)

	return move_tween


func prepare_draw_from_pile(target_z_index: int) -> void:
	if _hover_tween:
		_hover_tween.kill()
	if _shake_tween:
		_shake_tween.kill()

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot_offset = size * 0.5
	z_index = target_z_index
	rotation_degrees = 0.0
	face.rotation_degrees = 0.0
	_reset_flip_elevation()
	modulate = Color.WHITE
	_show_back()
	back.scale = Vector2.ONE
	face.scale = Vector2(-FLIP_EDGE_SCALE_X, 1.0)


func tween_draw_to(
	target_global_position: Vector2,
	target_rotation_degrees: float,
	target_z_index: int,
	move_duration: float,
	flip_duration: float
) -> Tween:
	if _hover_tween:
		_hover_tween.kill()
	if _shake_tween:
		_shake_tween.kill()

	prepare_draw_from_pile(target_z_index)

	AudioManager.play_card_taken()
	var move_tween := create_tween()
	move_tween.set_trans(Tween.TRANS_CUBIC)
	move_tween.set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(self, "global_position", target_global_position, move_duration)
	move_tween.parallel().tween_property(
		self, "rotation_degrees", target_rotation_degrees, move_duration
	)

	var flip_tween := create_tween()
	flip_tween.set_trans(Tween.TRANS_SINE)
	flip_tween.set_ease(Tween.EASE_IN_OUT)
	flip_tween.tween_property(back, "scale", Vector2(-FLIP_EDGE_SCALE_X, 1.0), flip_duration * 0.44)
	flip_tween.tween_callback(Callable(self, "_show_front_from_draw"))
	flip_tween.tween_property(face, "scale", Vector2.ONE, flip_duration * 0.56)
	_tween_flip_elevation(move_duration)

	return move_tween


func _refresh_art() -> void:
	if not is_node_ready():
		return

	var texture := load(_get_asset_path()) as Texture2D
	var suit_texture := load(_get_suit_asset_path()) as Texture2D
	art.texture = texture
	top_suit.texture = suit_texture
	bottom_suit.texture = suit_texture
	top_value.text = _get_value_label()
	bottom_value.text = top_value.text
	_refresh_art_layout()
	_refresh_value_size()
	_refresh_predator_gradient()
	_refresh_suit_color()
	_refresh_holographic_overlay()


func _get_asset_path() -> String:
	return "res://assets/%s.png" % get_card_id()


func _get_suit_asset_path() -> String:
	return "res://assets/%s.png" % suit


func _get_value_label() -> String:
	match value:
		1:
			return "A"
		11:
			return "J"
		12:
			return "Q"
		13:
			return "K"
		_:
			return str(value)


func _refresh_suit_color() -> void:
	var style := color_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if not style:
		return

	var next_style := style.duplicate() as StyleBoxFlat
	next_style.bg_color = _get_suit_color()
	color_panel.add_theme_stylebox_override("panel", next_style)


func _refresh_art_layout() -> void:
	_set_control_rect(art, CARD_ART_CENTER, CARD_ART_SIZE, art_scale)
	art.rotation_degrees = art_rotation_degrees
	_sync_pivots()


func _refresh_value_size() -> void:
	var font_size := 18
	if top_value.text.length() > 1:
		font_size = 16

	top_value.add_theme_font_size_override("font_size", font_size)
	bottom_value.add_theme_font_size_override("font_size", font_size)


func _refresh_predator_gradient() -> void:
	predator_gradient.visible = kind == KIND_PREDATOR
	if predator_gradient.visible:
		predator_gradient.queue_redraw()


func _refresh_holographic_overlay() -> void:
	if not _holographic_overlay:
		return

	_holographic_overlay.visible = HOLOGRAPHIC_CARD_VALUES.has(value)


func _create_holographic_overlay() -> void:
	_holographic_overlay = Panel.new()
	_holographic_overlay.name = "HolographicOverlay"
	_holographic_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_holographic_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_holographic_overlay.offset_left = 0.0
	_holographic_overlay.offset_top = 0.0
	_holographic_overlay.offset_right = 0.0
	_holographic_overlay.offset_bottom = 0.0
	_holographic_overlay.add_theme_stylebox_override("panel", _create_holographic_style())
	_holographic_overlay.material = _create_holographic_material()
	color_panel.add_child(_holographic_overlay)


func _create_holographic_style() -> StyleBoxFlat:
	var style := color_panel.get_theme_stylebox("panel") as StyleBoxFlat
	var holographic_style := StyleBoxFlat.new()
	if style:
		holographic_style = style.duplicate() as StyleBoxFlat
	holographic_style.bg_color = Color.WHITE
	return holographic_style


func _create_holographic_material() -> ShaderMaterial:
	var shader_material := ShaderMaterial.new()
	shader_material.shader = HOLOGRAPHIC_SHADER
	return shader_material


func _get_suit_color() -> Color:
	match suit:
		SUIT_WATER:
			return WATER_COLOR
		SUIT_LAND:
			return LAND_COLOR
		SUIT_AIR:
			return AIR_COLOR
		_:
			return AIR_COLOR


func _set_control_rect(control: Control, center: Vector2, base_size: Vector2, scale_value: float) -> void:
	var next_size := base_size * scale_value
	var top_left := center - (next_size * 0.5)

	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.offset_left = top_left.x
	control.offset_top = top_left.y
	control.offset_right = top_left.x + next_size.x
	control.offset_bottom = top_left.y + next_size.y


func _on_mouse_entered() -> void:
	_tween_pickup()


func _on_mouse_exited() -> void:
	_tween_lower()


func _tween_pickup() -> void:
	if _hover_tween:
		_hover_tween.kill()

	var pickup_tilt_degrees := _get_pickup_tilt_degrees()
	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_SINE)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(face, "position", _base_face_position + HOVER_ELEVATION, PICKUP_DURATION)
	_hover_tween.parallel().tween_property(face, "scale", HOVER_SCALE, PICKUP_DURATION)
	_hover_tween.parallel().tween_property(face, "rotation_degrees", pickup_tilt_degrees, PICKUP_DURATION)
	_hover_tween.parallel().tween_property(
		shadow, "position", _base_shadow_position + HOVER_SHADOW_OFFSET, PICKUP_DURATION
	)
	_hover_tween.parallel().tween_property(shadow, "scale", HOVER_SHADOW_SCALE, PICKUP_DURATION)
	_hover_tween.parallel().tween_property(shadow, "modulate", HOVER_SHADOW_MODULATE, PICKUP_DURATION)
	_hover_tween.tween_property(face, "rotation_degrees", 0.0, ALIGN_DURATION)


func _tween_lower() -> void:
	if _hover_tween:
		_hover_tween.kill()

	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_SINE)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(face, "position", _base_face_position, LOWER_DURATION)
	_hover_tween.parallel().tween_property(face, "scale", Vector2.ONE, LOWER_DURATION)
	_hover_tween.parallel().tween_property(face, "rotation_degrees", 0.0, LOWER_DURATION)
	_hover_tween.parallel().tween_property(shadow, "position", _base_shadow_position, LOWER_DURATION)
	_hover_tween.parallel().tween_property(shadow, "scale", Vector2.ONE, LOWER_DURATION)
	_hover_tween.parallel().tween_property(shadow, "modulate", BASE_SHADOW_MODULATE, LOWER_DURATION)


func _reset_flip_elevation() -> void:
	face.position = _base_face_position
	back.position = _base_back_position
	shadow.position = _base_shadow_position
	shadow.scale = Vector2.ONE
	shadow.modulate = BASE_SHADOW_MODULATE


func _tween_flip_elevation(move_duration: float) -> Tween:
	var lift_duration := minf(FLIP_LIFT_DURATION, move_duration * 0.4)
	var lower_duration := minf(FLIP_LOWER_DURATION, move_duration * 0.45)
	var hold_duration := maxf(move_duration - lift_duration - lower_duration, 0.0)

	var elevation_tween := create_tween()
	elevation_tween.set_trans(Tween.TRANS_SINE)
	elevation_tween.set_ease(Tween.EASE_IN_OUT)
	elevation_tween.tween_property(face, "position", _base_face_position + FLIP_ELEVATION, lift_duration)
	elevation_tween.parallel().tween_property(
		back, "position", _base_back_position + FLIP_ELEVATION, lift_duration
	)
	elevation_tween.parallel().tween_property(
		shadow, "position", _base_shadow_position + FLIP_SHADOW_OFFSET, lift_duration
	)
	elevation_tween.parallel().tween_property(shadow, "scale", FLIP_SHADOW_SCALE, lift_duration)
	elevation_tween.parallel().tween_property(
		shadow, "modulate", FLIP_SHADOW_MODULATE, lift_duration
	)
	if hold_duration > 0.0:
		elevation_tween.tween_interval(hold_duration)
	elevation_tween.tween_property(face, "position", _base_face_position, lower_duration)
	elevation_tween.parallel().tween_property(back, "position", _base_back_position, lower_duration)
	elevation_tween.parallel().tween_property(shadow, "position", _base_shadow_position, lower_duration)
	elevation_tween.parallel().tween_property(shadow, "scale", Vector2.ONE, lower_duration)
	elevation_tween.parallel().tween_property(
		shadow, "modulate", BASE_SHADOW_MODULATE, lower_duration
	)

	return elevation_tween


func _sync_pivots() -> void:
	face.pivot_offset = face.size * 0.5
	back.pivot_offset = back.size * 0.5
	shadow.pivot_offset = shadow.size * 0.5
	art.pivot_offset = art.size * 0.5


func _show_front() -> void:
	face.visible = true
	face.scale = Vector2.ONE
	back.visible = false
	back.scale = Vector2(FLIP_EDGE_SCALE_X, 1.0)


func _show_back() -> void:
	face.visible = false
	back.visible = true


func _show_front_from_draw() -> void:
	face.visible = true
	face.scale = Vector2(-FLIP_EDGE_SCALE_X, 1.0)
	back.visible = false


func _get_pickup_tilt_degrees() -> float:
	var card_width := maxf(size.x, 1.0)
	var local_mouse := get_local_mouse_position()
	var entry_side := signf((local_mouse.x / card_width) - 0.5)

	if is_zero_approx(entry_side):
		entry_side = -1.0

	return entry_side * PICKUP_TILT_DEGREES
