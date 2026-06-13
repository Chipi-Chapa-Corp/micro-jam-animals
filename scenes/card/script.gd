extends Control
class_name CardScene

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

var id: String:
	get:
		return get_card_id()

@onready var shadow: TextureRect = $Shadow
@onready var art: TextureRect = $Art

var _base_shadow_position: Vector2 = Vector2.ZERO
var _base_art_position: Vector2 = Vector2.ZERO
var _hover_tween: Tween


func _ready() -> void:
	_base_shadow_position = shadow.position
	_base_art_position = art.position
	_sync_pivots()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_refresh_art()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_sync_pivots()


func configure(next_kind: String, next_suit: String, next_value: int) -> void:
	kind = next_kind
	suit = next_suit
	value = next_value
	_refresh_art()


func get_card_id() -> String:
	return "%s_%s_%s" % [kind, suit, value]


func _refresh_art() -> void:
	if not is_node_ready():
		return

	var texture := load(_get_asset_path()) as Texture2D
	art.texture = texture
	shadow.texture = texture


func _get_asset_path() -> String:
	# return "res://assets/%s.png" % get_card_id()
	return "res://assets/prey_%s_%s.png" % [suit, value]


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
	_hover_tween.tween_property(art, "position", _base_art_position + HOVER_ELEVATION, PICKUP_DURATION)
	_hover_tween.parallel().tween_property(art, "scale", HOVER_SCALE, PICKUP_DURATION)
	_hover_tween.parallel().tween_property(art, "rotation_degrees", pickup_tilt_degrees, PICKUP_DURATION)
	_hover_tween.parallel().tween_property(
		shadow, "position", _base_shadow_position + HOVER_SHADOW_OFFSET, PICKUP_DURATION
	)
	_hover_tween.parallel().tween_property(shadow, "scale", HOVER_SHADOW_SCALE, PICKUP_DURATION)
	_hover_tween.parallel().tween_property(shadow, "modulate", HOVER_SHADOW_MODULATE, PICKUP_DURATION)
	_hover_tween.tween_property(art, "rotation_degrees", 0.0, ALIGN_DURATION)


func _tween_lower() -> void:
	if _hover_tween:
		_hover_tween.kill()

	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_SINE)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(art, "position", _base_art_position, LOWER_DURATION)
	_hover_tween.parallel().tween_property(art, "scale", Vector2.ONE, LOWER_DURATION)
	_hover_tween.parallel().tween_property(art, "rotation_degrees", 0.0, LOWER_DURATION)
	_hover_tween.parallel().tween_property(shadow, "position", _base_shadow_position, LOWER_DURATION)
	_hover_tween.parallel().tween_property(shadow, "scale", Vector2.ONE, LOWER_DURATION)
	_hover_tween.parallel().tween_property(shadow, "modulate", BASE_SHADOW_MODULATE, LOWER_DURATION)


func _sync_pivots() -> void:
	art.pivot_offset = art.size * 0.5
	shadow.pivot_offset = shadow.size * 0.5


func _get_pickup_tilt_degrees() -> float:
	var card_width := maxf(size.x, 1.0)
	var local_mouse := get_local_mouse_position()
	var entry_side := signf((local_mouse.x / card_width) - 0.5)

	if is_zero_approx(entry_side):
		entry_side = -1.0

	return entry_side * PICKUP_TILT_DEGREES
