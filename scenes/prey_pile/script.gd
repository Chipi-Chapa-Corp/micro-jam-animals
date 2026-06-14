extends Control
class_name PreyPile

const SLIDE_DURATION: float = 0.28
const SLIDE_MARGIN: float = 24.0

@onready var shadow: Panel = $Shadow
@onready var face: Panel = $Face

var _base_shadow_position: Vector2 = Vector2.ZERO
var _base_face_position: Vector2 = Vector2.ZERO
var _is_drawing_cards: bool = false
var _pending_available: bool = true
var _slide_tween: Tween


func _ready() -> void:
	_base_shadow_position = shadow.position
	_base_face_position = face.position
	GameState.player_discards_count_changed.connect(_on_player_discards_count_changed)
	_pending_available = GameState.get_player_discards_count() > 0
	_set_available(_pending_available, false)


func get_draw_global_position() -> Vector2:
	return face.global_position


func begin_draw_animations() -> void:
	_is_drawing_cards = true


func end_draw_animations() -> void:
	_is_drawing_cards = false
	_set_available(_pending_available, true)


func _on_player_discards_count_changed(player_discards_count: int) -> void:
	_pending_available = player_discards_count > 0
	if _is_drawing_cards and not _pending_available:
		return

	_set_available(_pending_available, true)


func _set_available(is_available: bool, animate: bool) -> void:
	if _slide_tween:
		_slide_tween.kill()
		_slide_tween = null

	var target_offset := Vector2.ZERO
	if not is_available:
		target_offset = _get_offscreen_offset()

	var target_shadow_position := _base_shadow_position + target_offset
	var target_face_position := _base_face_position + target_offset

	if not animate:
		shadow.position = target_shadow_position
		face.position = target_face_position
		return

	_slide_tween = create_tween()
	_slide_tween.set_trans(Tween.TRANS_CUBIC)
	_slide_tween.set_ease(Tween.EASE_IN_OUT)
	_slide_tween.tween_property(shadow, "position", target_shadow_position, SLIDE_DURATION)
	_slide_tween.parallel().tween_property(face, "position", target_face_position, SLIDE_DURATION)


func _get_offscreen_offset() -> Vector2:
	var viewport_width := get_viewport_rect().size.x
	var offscreen_global_x := viewport_width + SLIDE_MARGIN
	return Vector2(offscreen_global_x - global_position.x, 0.0)
