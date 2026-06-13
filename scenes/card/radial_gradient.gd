extends Control

@export var center_color: Color = Color(1.0, 0.0, 0.0, 1)
@export var radius_ratio: float = 0.6
@export var steps: int = 15
@export var fade_power: float = 1.5

const RING_SEGMENTS: int = 64


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var center := size * 0.5
	var max_radius := minf(size.x, size.y) * radius_ratio
	var step_count := maxi(steps, 1)

	for index in range(step_count - 1, -1, -1):
		var inner_ratio := float(index) / float(step_count)
		var outer_ratio := float(index + 1) / float(step_count)
		var color := center_color
		color.a *= pow(1.0 - inner_ratio, fade_power)

		if color.a <= 0.0:
			continue

		_draw_ring(center, max_radius * inner_ratio, max_radius * outer_ratio, color)


func _draw_ring(center: Vector2, inner_radius: float, outer_radius: float, color: Color) -> void:
	if inner_radius <= 0.0:
		draw_circle(center, outer_radius, color)
		return

	for segment in range(RING_SEGMENTS):
		var start_angle := TAU * float(segment) / float(RING_SEGMENTS)
		var end_angle := TAU * float(segment + 1) / float(RING_SEGMENTS)
		var start_direction := Vector2(cos(start_angle), sin(start_angle))
		var end_direction := Vector2(cos(end_angle), sin(end_angle))
		var points := PackedVector2Array(
			[
				center + start_direction * inner_radius,
				center + start_direction * outer_radius,
				center + end_direction * outer_radius,
				center + end_direction * inner_radius,
			]
		)

		draw_colored_polygon(points, color)
