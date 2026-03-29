extends Node2D

@export var radius: float = 120.0
@export var color: Color = Color(1, 0, 0, 0.3)

var start_angle: float = 0.0
var end_angle: float = 0.0


func update_shading(start_rot: float, current_rot: float) -> void:
	start_angle = start_rot - PI / 2.0
	end_angle = current_rot - PI / 2.0
	queue_redraw()


func _draw() -> void:
	var angle_range: float = end_angle - start_angle
	if angle_range < 0:
		angle_range += TAU
	if angle_range < 0.01:
		return
	var arc_points: int = 64
	var points: PackedVector2Array = [Vector2.ZERO]
	for i in range(arc_points + 1):
		var angle: float = start_angle + (angle_range * i / arc_points)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	draw_polygon(points, [color])
