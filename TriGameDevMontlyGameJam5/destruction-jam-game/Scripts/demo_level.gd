extends Node2D

@export var min_idle_time: float = 3.0
@export var max_idle_time: float = 8.0
@export var patrol_speed: float = 50.0
@export var clock_tick_interval: float = 0.1
@export var clock_tick_minutes: int = 1.5
@export var end_hour: int = 17

var is_owner_patrolling: bool = false
var is_game_over: bool = false

var patrol_point_a: Vector2
var patrol_point_b: Vector2

@export var goodJob : Sprite2D 

# The Level is where we can call the clicking animations + progress animations
func _input(event):
	if is_game_over:
		return
	
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		if is_owner_patrolling and $Owner.is_facing_position($CatPlayer.position):
			_game_over()
		else:
			$CatPlayer.play_click_animation()
			SoundFX.play_random_scratch()
			$ProgressBarUI.add_progress(3)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	patrol_point_a = $PatrolPointA.global_position
	patrol_point_b = $PatrolPointB.global_position
	$Owner.global_position = patrol_point_a
	_patrol_loop()
	_clock_loop()
	goodJob.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _game_over() -> void:
	is_game_over = true
	$CatPlayer.stop_click_animation()
	await $Owner.catch_cat($CatPlayer.global_position)
	await $CaughtAnimation.play_caught()
	await Animations.tween_modulate($ScreenFade/ScreenFadeColorRect, Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1)
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()


func _round_complete() -> void:
	is_game_over = true
	$CatPlayer.stop_click_animation()
	$Owner.stop_all()
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()


func _clock_loop() -> void:
	while true:
		if is_game_over:
			break
		await get_tree().create_timer(clock_tick_interval).timeout
		if is_game_over:
			break
		$Clock.increment_time(0, clock_tick_minutes)
		await $Clock.update_time($Clock.hour, $Clock.minute)
		if $Clock.is_past(end_hour):
			_round_complete()
			break


func _patrol_loop() -> void:
	while true:
		if is_game_over:
			break
		await get_tree().create_timer(randf_range(min_idle_time, max_idle_time)).timeout
		
		$Owner.play_patrol_animation()
		is_owner_patrolling = true
		
		# Pick a random point along the patrol path to turn around at
		var turn_ratio: float = randf_range(0.3, 1.0)  # at least 30% of the way
		var turnaround_point: Vector2 = patrol_point_a.lerp(patrol_point_b, turn_ratio)
		
		var distance: float = $Owner.global_position.distance_to(turnaround_point)
		var duration: float = distance / patrol_speed
		
		await $Owner.move_to(turnaround_point, duration)
		
		var return_distance: float = turnaround_point.distance_to(patrol_point_a)
		var return_duration: float = return_distance / patrol_speed
		
		await $Owner.move_to(patrol_point_a, return_duration)
		
		$Owner.stop_patrol()
		is_owner_patrolling = false
