extends Area2D
class_name ParentMouseAreaRect

# -- HOW TO USE --
# call update_shape to update area
# Parent must have size, scale, position (Control) 
# Parent must have mouse_entered and mouse_exited

signal update_shape
signal entrance_complete
signal on_click

enum MOUSE_HOVER_ANIMATIONS { BOUNCE, CUBIC }
enum ENTRANCE_ANIMATIONS { CUBIC_GROW, BOUNCE_GROW, FLIPS, FULL_SCREEN_H_SQUEEZE, BOUNCE, FADE, H_GROW }
enum EXIT_ANIMATIONS { CUBIC_SHRINK }
enum ON_CLICK_ANIMATIONS { SHRINK }

@export var mouse_hover_animation_type : MOUSE_HOVER_ANIMATIONS
@export var entrance_animation_type : ENTRANCE_ANIMATIONS
@export var exit_animation_type : EXIT_ANIMATIONS
@export var on_click_animation_type : ON_CLICK_ANIMATIONS
@export var animation_slowdown_factor : float = 1.0
@export var disable_parent_animations : bool = false
@export var hover_grow : Vector2 = Vector2(0.2, 0.2)
@export var COLLISION_FORGIVENESS_FACTOR := Vector2(1.1, 1.1)

@onready var collision : CollisionShape2D = get_node("MouseCollisionShape")


const FLIP_STARTING_SCALE := Vector2(1.0, 0)

var animation_dur : float:
	get: return Constants.SNAPPINESS * 0.5 * animation_slowdown_factor
var exit_animation_dur : float:
	get: return animation_dur * 0.5
var current_base_scale : Vector2 
var is_mouse_hovered : bool = false

func _ready() -> void:
	update_shape.connect(_on_update_shape)
	_on_update_shape()
	if !self.get_parent().is_node_ready():
		await self.get_parent().ready
	if !disable_parent_animations:
		await entrance_animation()


func entrance_animation() -> void:
	if disable_parent_animations:
		return
	match self.entrance_animation_type:
		ENTRANCE_ANIMATIONS.FLIPS:
			var starting_scale : Vector2 = FLIP_STARTING_SCALE * current_base_scale
			await Animations.tween_scale(self.get_parent(), starting_scale, current_base_scale - starting_scale, animation_dur)
		ENTRANCE_ANIMATIONS.FULL_SCREEN_H_SQUEEZE:
			var starting_scale : Vector2 = Vector2(get_viewport_rect().size.x / self.get_parent().size.x, 0)
			var partial_dur : float = animation_dur
			var ease_dur_ratio : float = 0.3
			var ease_scale_ratio : float = 0.8
			await Animations.tween_scale_ease_in(self.get_parent(), starting_scale, Vector2(get_viewport_rect().size.x / self.get_parent().size.x / -1.0, current_base_scale.y), partial_dur)
			await Animations.tween_scale_ease_into_bounce(self.get_parent(), ease_dur_ratio, ease_scale_ratio, self.get_parent().scale, current_base_scale - self.get_parent().scale, partial_dur)
		ENTRANCE_ANIMATIONS.CUBIC_GROW:
			await Animations.tween_scale(self.get_parent(), Vector2.ZERO, current_base_scale, animation_dur)
		ENTRANCE_ANIMATIONS.BOUNCE_GROW:
			const BOUNCE_DUR_FACTOR : float = 2.0
			await Animations.tween_scale_bounce(self.get_parent(), Vector2.ZERO, current_base_scale, animation_dur * BOUNCE_DUR_FACTOR)
		ENTRANCE_ANIMATIONS.FADE:
			await Animations.tween_a8(self.get_parent(), 0, Constants.MAX_A8, animation_dur)
		ENTRANCE_ANIMATIONS.H_GROW:
			await Animations.entrance_ease_into_scale_bounce(self.get_parent(), Animations.DEFAULT_LONG_ENTRANCE_ANIMATION_DUR, Animations.DEFAULT_EASE_DUR_RATIO, Animations.DEFAULT_PROGRESS_DUR_RATIO, Vector2.DOWN, Vector2.RIGHT)
	self.emit_signal("entrance_complete")
	
	
func exit_animation() -> void:
	if disable_parent_animations:
		return
	match self.exit_animation_type:
		EXIT_ANIMATIONS.CUBIC_SHRINK:
			await Animations.tween_scale(self.get_parent(), self.get_parent().scale, Vector2.ZERO - self.get_parent().scale, exit_animation_dur)


func on_click_animation() -> void:
	if disable_parent_animations:
		return
	animate_click()
	
	
func animate_click() -> void:
	match self.on_click_animation_type:
		ON_CLICK_ANIMATIONS.SHRINK:
			var WIGGLE_RANGE := Vector2(0.1, 0.5)
			Animations.tween_wiggle_range(self.get_parent(), WIGGLE_RANGE.x, WIGGLE_RANGE.y, animation_dur)
			var partial_dur : float = animation_dur * 0.5
			if (round(Time.get_ticks_msec()) % 2) == 0:
				await Animations.h_wide_squeeze(self.get_parent(), self.get_parent().scale, Vector2.ZERO, partial_dur, randf_range(1.5, 3.0), randf_range(0.3, 0.5))
			else:
				await Animations.v_wide_squeeze(self.get_parent(), self.get_parent().scale, Vector2.ZERO, partial_dur, randf_range(1.5, 3.0), randf_range(0.3, 0.5))
			await Animations.tween_scale(self.get_parent(), self.get_parent().scale, current_base_scale - self.get_parent().scale, partial_dur)
	
	
func _on_update_shape() -> void:
	self.position = self.get_parent().size / 2.0
	collision.shape.size = self.get_parent().size * self.get_parent().scale * COLLISION_FORGIVENESS_FACTOR
	current_base_scale = self.get_parent().scale


func _on_mouse_entered() -> void:
	self.get_parent().emit_signal("mouse_entered")
	if disable_parent_animations:
		return
	var offset : Vector2 = (current_base_scale + hover_grow) - self.get_parent().scale
	self.is_mouse_hovered = true
	match self.mouse_hover_animation_type:
		MOUSE_HOVER_ANIMATIONS.BOUNCE:
			await Animations.tween_scale_bounce(self.get_parent(), self.get_parent().scale, offset, animation_dur)
		MOUSE_HOVER_ANIMATIONS.CUBIC:
			await Animations.tween_scale(self.get_parent(), self.get_parent().scale, offset, animation_dur)


func _on_mouse_exited() -> void:
	self.get_parent().emit_signal("mouse_exited")
	if disable_parent_animations:
		return
	var offset : Vector2 = current_base_scale - self.get_parent().scale
	self.is_mouse_hovered = false
	match mouse_hover_animation_type:
		MOUSE_HOVER_ANIMATIONS.BOUNCE:
			await Animations.tween_scale_bounce(self.get_parent(), self.get_parent().scale, offset, animation_dur)
		MOUSE_HOVER_ANIMATIONS.CUBIC:
			await Animations.tween_scale(self.get_parent(), self.get_parent().scale, offset, animation_dur)
	

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if !self.is_mouse_hovered:
			return
		self.emit_signal("on_click")
		on_click_animation()
		get_tree().get_root().set_input_as_handled()
		
