extends Control
class_name Clock

const MAX_HOURS : int = 12
const MAX_MINUTES : int = 60
const ROT_PER_HOUR : float = TAU / MAX_HOURS

@export var hour_hand : Panel
@export var minute_hand : Panel
@export var hour : int = 0
@export var minute : int = 0
@export var update_speed : float = 0.2

#
#func _ready() -> void:
	## TESTING
	#while true:
		#SoundFX.play_sound_effect(SoundFX.placeholder)
		#increment_time(randi_range(0, 3), randi_range(0, 30))
		#print("hour: %s, minute: %s" % [str(hour), str(minute)])
		#await update_time(hour, minute)


func increment_time(hours : int, minutes : int) -> void:
	var carried_hours : int = (self.minute + minutes) / MAX_MINUTES
	self.minute = (self.minute + minutes) % MAX_MINUTES
	self.hour = (self.hour + hours + carried_hours) % MAX_HOURS


func update_time(hour_ : int, minutes : int) -> void:
	var new_hour_rot : float = get_hour_hand_rot(hour_, minutes)
	var new_minutes_rot : float = get_minute_hand_rot(minutes)
	Animations.tween_rot(hour_hand, hour_hand.rotation, shortest_rot(hour_hand.rotation, new_hour_rot), update_speed)
	await Animations.tween_rot(minute_hand, minute_hand.rotation, shortest_rot(minute_hand.rotation, new_minutes_rot), update_speed)
	

func shortest_rot(from: float, to: float) -> float:
	return fposmod(to - from + PI, TAU) - PI	
	
	
func get_hour_hand_rot(hour_ : int, minutes : int) -> float:
	var minutes_ratio : float = float(minutes % MAX_MINUTES) / float(MAX_MINUTES)
	return (ROT_PER_HOUR * float(hour_ % MAX_HOURS)) + (minutes_ratio * ROT_PER_HOUR)
	
	
func get_minute_hand_rot(minutes : int) -> float:
	return (TAU / MAX_MINUTES) * float(minutes)
