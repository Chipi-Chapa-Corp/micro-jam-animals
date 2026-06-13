extends Control
class_name CardScene

signal clicked(card_id: String)

@export var kind: String = "prey"
@export var suit: String = "air"
@export var value: int = 4

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
const SHAKE_OFFSET: Vector2 = Vector2(7.0, 0.0)
const SHAKE_DURATION: float = 0.035
const SUIT_WATER: String = "water"
const SUIT_LAND: String = "land"
const SUIT_AIR: String = "air"
const KIND_PREDATOR: String = "predator"
const WATER_COLOR: Color = Color(111.0 / 255.0, 111.0 / 255.0, 175.0 / 255.0)
const LAND_COLOR: Color = Color(126.0 / 255.0, 160.0 / 255.0, 118.0 / 255.0)
const AIR_COLOR: Color = Color(171.0 / 255.0, 177.0 / 255.0, 188.0 / 255.0)

var id: String:
	get:
		return get_card_id()

@onready var shadow: Panel = $Shadow
@onready var face: Panel = $Face
@onready var color_panel: Panel = $Face/Color
@onready var predator_gradient: Control = $Face/PredatorGradient
@onready var art: TextureRect = $Face/Art
@onready var bottom_art: TextureRect = $Face/BottomArt
@onready var top_value: Label = $Face/TopValue
@onready var top_suit: TextureRect = $Face/TopSuit
@onready var bottom_value: Label = $Face/BottomValue
@onready var bottom_suit: TextureRect = $Face/BottomSuit

var _base_shadow_position: Vector2 = Vector2.ZERO
var _base_face_position: Vector2 = Vector2.ZERO
var _hover_tween: Tween
var _shake_tween: Tween


func _ready() -> void:
	_base_shadow_position = shadow.position
	_base_face_position = face.position
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


func configure(next_kind: String, next_suit: String, next_value: int) -> void:
	kind = next_kind
	suit = next_suit
	value = next_value
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


func _refresh_art() -> void:
	if not is_node_ready():
		return

	var texture := load(_get_asset_path()) as Texture2D
	var suit_texture := load(_get_suit_asset_path()) as Texture2D
	art.texture = texture
	bottom_art.texture = texture
	top_suit.texture = suit_texture
	bottom_suit.texture = suit_texture
	top_value.text = _get_value_label()
	bottom_value.text = top_value.text
	_refresh_art_layout()
	_refresh_value_size()
	_refresh_predator_gradient()
	_refresh_suit_color()


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
	if value == 1:
		_set_control_anchors(art, Vector2(0.16, 0.24), Vector2(0.84, 0.76))
		art.rotation = 0.0
		bottom_art.visible = false
		_sync_pivots()
		return

	_set_control_anchors(art, Vector2(0.18, 0.24), Vector2(0.82, 0.46))
	art.rotation = 0.0
	bottom_art.visible = true
	_set_control_anchors(bottom_art, Vector2(0.18, 0.54), Vector2(0.82, 0.76))
	bottom_art.rotation = PI
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


func _set_control_anchors(control: Control, top_left: Vector2, bottom_right: Vector2) -> void:
	control.anchor_left = top_left.x
	control.anchor_top = top_left.y
	control.anchor_right = bottom_right.x
	control.anchor_bottom = bottom_right.y
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0


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


func _sync_pivots() -> void:
	face.pivot_offset = face.size * 0.5
	shadow.pivot_offset = shadow.size * 0.5
	art.pivot_offset = art.size * 0.5
	bottom_art.pivot_offset = bottom_art.size * 0.5


func _get_pickup_tilt_degrees() -> float:
	var card_width := maxf(size.x, 1.0)
	var local_mouse := get_local_mouse_position()
	var entry_side := signf((local_mouse.x / card_width) - 0.5)

	if is_zero_approx(entry_side):
		entry_side = -1.0

	return entry_side * PICKUP_TILT_DEGREES
