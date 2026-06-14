extends Control
class_name DiscardPile

signal clicked
signal hover_changed(is_hovered: bool)

const SLIDE_DURATION: float = 0.28
const SLIDE_MARGIN: float = 24.0

@onready var shadow: Control = $Shadow
@onready var face: Control = $Face
@onready var label: Label = $Face/Label

var _base_shadow_position: Vector2 = Vector2.ZERO
var _base_face_position: Vector2 = Vector2.ZERO
var _is_available: bool = true
var _slide_tween: Tween


func _ready() -> void:
	_base_shadow_position = shadow.position
	_base_face_position = face.position
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	GameState.player_discards_count_changed.connect(_on_player_discards_count_changed)
	var player_discards_count := GameState.get_player_discards_count()
	_refresh_label(player_discards_count)
	_set_available(player_discards_count > 0, false)


func get_drop_global_position() -> Vector2:
	return global_position


func slide_in_for_round_reset() -> bool:
	if _is_at_available_position():
		return false

	_slide_to_offset(Vector2.ZERO, true)
	return true


func _gui_input(event: InputEvent) -> void:
	if not _is_available:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit()
		accept_event()


func _on_mouse_entered() -> void:
	if not _is_available:
		return

	hover_changed.emit(true)


func _on_mouse_exited() -> void:
	hover_changed.emit(false)


func _on_player_discards_count_changed(player_discards_count: int) -> void:
	_refresh_label(player_discards_count)
	_set_available(player_discards_count > 0, true)


func _set_available(is_available: bool, animate: bool) -> void:
	if _is_available == is_available and animate:
		return

	_is_available = is_available
	mouse_filter = Control.MOUSE_FILTER_STOP if _is_available else Control.MOUSE_FILTER_IGNORE
	if not _is_available:
		hover_changed.emit(false)

	var target_offset := Vector2.ZERO
	if not _is_available:
		target_offset = _get_offscreen_offset()

	_slide_to_offset(target_offset, animate)


func _refresh_label(player_discards_count: int) -> void:
	label.text = "Discard x%s" % player_discards_count


func _slide_to_offset(target_offset: Vector2, animate: bool) -> void:
	if _slide_tween:
		_slide_tween.kill()
		_slide_tween = null

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


func _is_at_available_position() -> bool:
	return (
		(shadow.position - _base_shadow_position).length_squared() < 0.01
		and (face.position - _base_face_position).length_squared() < 0.01
	)


func _get_offscreen_offset() -> Vector2:
	var viewport_width := get_viewport_rect().size.x
	var offscreen_global_x := viewport_width + SLIDE_MARGIN
	return Vector2(offscreen_global_x - global_position.x, 0.0)
