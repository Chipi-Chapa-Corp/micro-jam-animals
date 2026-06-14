extends Control

@export var background_offset: Vector2 = Vector2(6.0, 3.5)
@export var foreground_offset: Vector2 = Vector2(13.5, 8.0)
@export var follow_speed: float = 4.0

@onready var fill_layer: TextureRect = $Fill
@onready var background_layer: TextureRect = $Background
@onready var foreground_layer: TextureRect = $Foreground

var _current_cursor_offset: Vector2 = Vector2.ZERO
var _target_cursor_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_target_cursor_offset()
	_position_layers()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_position_layers()


func _process(delta: float) -> void:
	_update_target_cursor_offset()
	var weight := 1.0 - exp(-follow_speed * delta)
	_current_cursor_offset = _current_cursor_offset.lerp(_target_cursor_offset, weight)
	_position_layers()


func _update_target_cursor_offset() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		_target_cursor_offset = Vector2.ZERO
		return

	var mouse_position := get_viewport().get_mouse_position()
	_target_cursor_offset = Vector2(
		clampf((mouse_position.x / viewport_size.x) * 2.0 - 1.0, -1.0, 1.0),
		clampf((mouse_position.y / viewport_size.y) * 2.0 - 1.0, -1.0, 1.0)
	)


func _position_layers() -> void:
	_position_layer(fill_layer, Vector2.ZERO)
	_position_layer(background_layer, background_offset)
	_position_layer(foreground_layer, foreground_offset)


func _position_layer(layer: TextureRect, max_offset: Vector2) -> void:
	if layer == null or layer.texture == null:
		return

	var view_size := size
	if view_size.x <= 0.0 or view_size.y <= 0.0:
		view_size = get_viewport_rect().size

	var texture_size := layer.texture.get_size()
	var required_size := view_size + max_offset * 2.0
	var image_scale := maxf(
		required_size.x / texture_size.x,
		required_size.y / texture_size.y
	)
	var layer_size := texture_size * image_scale
	var parallax_offset := Vector2(
		- _current_cursor_offset.x * max_offset.x,
		- _current_cursor_offset.y * max_offset.y
	)

	layer.size = layer_size
	layer.position = (view_size - layer_size) * 0.5 + parallax_offset
