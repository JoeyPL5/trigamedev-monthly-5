extends Node2D

signal patrol_started
signal patrol_ended

var _move_tween: Tween

func _ready() -> void:
	play_idle_animation()

func is_facing_position(target_pos: Vector2) -> bool:
	if $AnimatedSprite2D.flip_h:
		return target_pos.x >  position.x
	else:
		return target_pos.x < position.x

func play_idle_animation() -> void:
	$AnimatedSprite2D.play("idle")

func play_patrol_animation() -> void:
	$AnimatedSprite2D.play("patrol")
	patrol_started.emit()

func move_to(target: Vector2, duration: float) -> void:
	$AnimatedSprite2D.flip_h = target.x > position.x
	_move_tween = create_tween()
	_move_tween.set_trans(Tween.TRANS_LINEAR)
	_move_tween.tween_property(self, "position", target, duration)
	await _move_tween.finished

func stop_patrol() -> void:
	play_idle_animation()
	patrol_ended.emit()

func stop_all() -> void:
	if _move_tween:
		_move_tween.kill()
	$AnimatedSprite2D.stop()

func catch_cat(cat_position: Vector2) -> void:
	if _move_tween:
		_move_tween.kill()
	var distance: float = position.distance_to(cat_position)
	var rush_speed: float = 800.0
	var duration: float = distance / rush_speed
	$AnimatedSprite2D.flip_h = cat_position.x > position.x
	$AnimatedSprite2D.play("patrol")
	_move_tween = create_tween()
	_move_tween.set_trans(Tween.TRANS_CUBIC)
	_move_tween.set_ease(Tween.EASE_IN)
	_move_tween.tween_property(self, "position", cat_position, duration)
	await _move_tween.finished
	$AnimatedSprite2D.stop()
