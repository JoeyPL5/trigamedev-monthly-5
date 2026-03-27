extends Node

const DEFAULT_SQUEEZE_FACTOR : float = 3.0
const DEFAULT_SQUEEZE_RATIO : float = 0.4
# ease_ratio : 0 - 1.0 
const DEFAULT_EASE_DUR_RATIO : float = 0.2
const DEFAULT_PROGRESS_DUR_RATIO : float = 0.8
const DEFAULT_WIGGLE_RANGE : Vector2 = Vector2(0.2, 0.4)


var DEFAULT_ENTRANCE_ANIMATION_DUR: float:
	get: return 1.0 * Constants.SNAPPINESS
var DEFAULT_EXIT_ANIMATION_DUR: float:
	get: return DEFAULT_ENTRANCE_ANIMATION_DUR / 2.0
var DEFAULT_LONG_ENTRANCE_ANIMATION_DUR: float:
	get: return 2.0  * Constants.SNAPPINESS
var DEFAULT_LONG_EXIT_ANIMATION_DUR : float:
	get: return DEFAULT_LONG_ENTRANCE_ANIMATION_DUR / 2.0
var DEFAULT_FLASH_DURATION : float:
	get: return 0.5 * Constants.SNAPPINESS
var DEFAULT_WIGGLE_DURATION : float:
	get: return 1.0 * Constants.SNAPPINESS


# --------- SIMPLE ANIMATIONS -------------


func exit_fade_out(node : Node, duration : float = DEFAULT_EXIT_ANIMATION_DUR, final_modulate : Color = Color(Constants.INVIS)) -> Signal:
	return Animations.tween_modulate(node, node.modulate, final_modulate, duration)


func entrance_fade_in(node : Node, duration : float = DEFAULT_ENTRANCE_ANIMATION_DUR, final_a8 : int = Constants.MAX_A8) -> Signal:
	return tween_a8(node, 0, final_a8, duration)
	
	
func flash(node : Node, duration : float = DEFAULT_FLASH_DURATION, flash_color : Color = Constants.FLASH_WHITE) -> Signal:
	var partial_dur : float = duration * 0.5
	var starting_modulate : Color = node.modulate
	await Animations.tween_modulate(node, starting_modulate, flash_color, partial_dur)
	return Animations.tween_modulate(node, node.modulate, starting_modulate, partial_dur)
	
	
func wiggle(node : Node, wiggle_range : Vector2 = DEFAULT_WIGGLE_RANGE, duration : float = DEFAULT_WIGGLE_DURATION) -> Signal:
	return tween_wiggle_range(node, wiggle_range.x, wiggle_range.y, duration)

# --------- COMPLEX ANIMATIONS -------------


func entrance_h_first_scale(node : Node, duration : float = DEFAULT_LONG_ENTRANCE_ANIMATION_DUR, h_dur_ratio : float = DEFAULT_EASE_DUR_RATIO, v_dur_ratio : float = DEFAULT_PROGRESS_DUR_RATIO,\
		v_partial_scale_ratio : float = 0.6, starting_scale : Vector2 = Vector2.ZERO, final_scale : Vector2 = Vector2.ONE) -> Signal:
	var H_BONUS_WIDTH_FACTOR : float = 1.5
	node.pivot_offset = Vector2(node.size.x / 2.0, 0)
	await tween_scale_ease_in(node, starting_scale, Vector2(final_scale.x * H_BONUS_WIDTH_FACTOR, final_scale.y * v_partial_scale_ratio), duration * h_dur_ratio)
	return tween_scale_bounce(node, node.scale, final_scale - node.scale, duration * v_dur_ratio)


func entrance_ease_into_scale_bounce(node : Node, duration : float = DEFAULT_ENTRANCE_ANIMATION_DUR, ease_dur_ratio : float = DEFAULT_EASE_DUR_RATIO,\
		ease_scale_ratio : float = DEFAULT_PROGRESS_DUR_RATIO, starting_scale : Vector2 = Vector2.ZERO, scale_offset : Vector2 = Vector2.ONE) -> Signal:
	return await tween_scale_ease_into_bounce(node, ease_dur_ratio, ease_scale_ratio, starting_scale, scale_offset, duration)


func entrance_h_wide_squeeze(node : Node, duration : float = DEFAULT_ENTRANCE_ANIMATION_DUR, starting_scale : Vector2 = Vector2.ZERO, final_scale : Vector2 = Vector2.ONE) -> Signal:
	return await h_wide_squeeze(node, starting_scale, final_scale, duration)
	
	
func entrance_v_wide_squeeze(node : Node, duration : float = DEFAULT_ENTRANCE_ANIMATION_DUR, starting_scale : Vector2 = Vector2.ZERO, final_scale : Vector2 = Vector2.ONE) -> Signal:
	return await v_wide_squeeze(node, starting_scale, final_scale, duration)


func h_wide_squeeze(node : Node, starting_scale : Vector2, final_scale : Vector2, duration : float = DEFAULT_ENTRANCE_ANIMATION_DUR, squeeze_factor : float = DEFAULT_SQUEEZE_FACTOR, squeeze_ratio : float = DEFAULT_SQUEEZE_RATIO) -> Signal:
	var recover_ratio : float = 1 - squeeze_ratio
	var squeeze_dur : float = duration * squeeze_ratio
	var recover_dur : float = duration * recover_ratio
	var scale_midpoint : Vector2 = starting_scale + ((final_scale - starting_scale) / Vector2(2.0, 2.0))
	var mid_target : Vector2 = Vector2(scale_midpoint.x * squeeze_factor, scale_midpoint.y / squeeze_factor)
	await tween_scale_ease_in(node, starting_scale, mid_target - starting_scale, squeeze_dur)
	return tween_scale(node, node.scale, final_scale - node.scale, recover_dur)
	
	
func v_wide_squeeze(node : Node, starting_scale : Vector2, final_scale : Vector2, duration : float = DEFAULT_ENTRANCE_ANIMATION_DUR, squeeze_factor : float = DEFAULT_SQUEEZE_FACTOR, squeeze_ratio : float = DEFAULT_SQUEEZE_RATIO) -> Signal:
	var recover_ratio : float = 1 - squeeze_ratio
	var squeeze_dur : float = duration * squeeze_ratio
	var recover_dur : float = duration * recover_ratio
	var scale_midpoint : Vector2 = starting_scale + ((final_scale - starting_scale) / Vector2(2.0, 2.0))
	var mid_target : Vector2 = Vector2(scale_midpoint.x / squeeze_factor, scale_midpoint.y * squeeze_factor)
	await tween_scale_ease_in(node, starting_scale, mid_target - starting_scale, squeeze_dur)
	return tween_scale(node, node.scale, final_scale - node.scale, recover_dur)


func clean_particle_emission(particle_emitter : GPUParticles2D) -> void:
	var new_particle_emitter : GPUParticles2D = particle_emitter.duplicate(false)
	particle_emitter.get_parent().add_child(new_particle_emitter)
	new_particle_emitter.one_shot = true
	new_particle_emitter.emitting = true
	await new_particle_emitter.finished
	new_particle_emitter.queue_free()

# ---------- ANIMATION COMPONENTS -----------

func tween_property(node : Node, property_name : String, final_val : Variant, duration : float) -> Signal:
	var tween : Tween = node.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, property_name, final_val, duration)
	return tween.finished
	
	
func tween_property_ease_in(node : Node, property_name : String, final_val : Variant, duration : float) -> Signal:
	var tween : Tween = node.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(node, property_name, final_val, duration)
	return tween.finished
	
	
func tween_property_ease_out(node : Node, property_name : String, final_val : Variant, duration : float) -> Signal:
	var tween : Tween = node.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, property_name, final_val, duration)
	return tween.finished
	
	
func tween_property_bounce(node : Node, property_name : String, final_val : Variant, duration : float) -> Signal:
	var tween : Tween = node.create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, property_name, final_val, duration)
	return tween.finished


func tween_animation(node : Node, ease_type : Tween.EaseType, transition : Tween.TransitionType,\
		 node_animation : Callable, starting_val : Variant, final_val : Variant, duration : float) -> Signal:
	var tween : Tween = node.create_tween()
	tween.set_parallel(true)
	tween.set_ease(ease_type)
	tween.set_trans(transition)
	tween.tween_method(node_animation, starting_val, final_val, duration)
	return tween.finished


func tween_animation_offset(node : Node, ease_type : Tween.EaseType, transition : Tween.TransitionType,\
		 node_animation : Callable, starting_val : Variant, offset_val : Variant, duration : float) -> Signal:
	var tween : Tween = node.create_tween()
	tween.set_parallel(true)
	tween.set_ease(ease_type)
	tween.set_trans(transition)
	tween.tween_method(node_animation, starting_val, starting_val + offset_val, duration)
	return tween.finished
	
	
func tween_3d_rot_ease_in(node : Node3D, starting_rot : Vector3, offset_rot : Vector3, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN, Tween.TRANS_CIRC, node.set_global_rotation_degrees, starting_rot, offset_rot, duration)
	
	
func tween_3d_rot_ease_out(node : Node3D, starting_rot : Vector3, offset_rot : Vector3, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_CIRC, node.set_global_rotation_degrees, starting_rot, offset_rot, duration)


func tween_modulate(node : Node, starting_modulate : Color, final_modulate : Color, duration : float) -> Signal:
	return tween_animation(node, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR, node.set_modulate, starting_modulate, final_modulate, duration)


func tween_a8(node : Node, starting_a8 : int, a8_offset : int, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR, set_node_a8.bind(node), starting_a8, a8_offset, duration)
	
func tween_self_modulate_a8(node : Node, starting_a8 : int, a8_offset : int, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR, set_node_self_modulate_a8.bind(node), starting_a8, a8_offset, duration)
	

func tween_color_rect(rect : ColorRect, starting_color : Color, final_color : Color, duration : float) -> Signal:
	return tween_animation(rect, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR, rect.set_color, starting_color, final_color, duration)
	
	
func tween_stylebox_color(stylebox_owner : Control, starting_color : Color, final_color : Color, duration : float) -> Signal:
	var current_stylebox : StyleBoxFlat = stylebox_owner.get_theme_stylebox("panel")
	return tween_animation(stylebox_owner, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR,\
			tween_stylebox_bg_color.bind(stylebox_owner, current_stylebox), starting_color, final_color, duration)

# DO NOT USE! - USE ABOVE ^
func tween_stylebox_bg_color(color : Color, stylebox_owner : Control, current_stylebox : StyleBoxFlat) -> void:
	var new_bg_stylebox : StyleBoxFlat = current_stylebox.duplicate(false)
	new_bg_stylebox.bg_color = color
	stylebox_owner.add_theme_stylebox_override("panel", new_bg_stylebox)
	
	
func set_node_a8(a8 : int, node : Node) -> void:
	node.modulate.a8 = a8
	
	
func set_node_self_modulate_a8(a8 : int, node : Node) -> void:
	node.self_modulate.a8 = a8


func tween_position(node : Node, starting_posn : Vector2, posn_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_CUBIC, node.set_position, starting_posn, posn_offset, duration)
	
	
func tween_position_ease_in(node : Node, starting_posn : Vector2, posn_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN, Tween.TRANS_CUBIC, node.set_position, starting_posn, posn_offset, duration)	
	
	
func tween_position_ease_in_out(node : Node, starting_posn : Vector2, posn_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC, node.set_position, starting_posn, posn_offset, duration)	
	
	
func tween_position_back(node : Node, starting_posn : Vector2, posn_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN, Tween.TRANS_BACK, node.set_position, starting_posn, posn_offset, duration)
	
	
func tween_position_bounce(node : Node, starting_posn : Vector2, posn_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_ELASTIC, node.set_position, starting_posn, posn_offset, duration)
	
	
func tween_position_bounce_off(node : Node, starting_posn : Vector2, posn_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_BOUNCE, node.set_position, starting_posn, posn_offset, duration)
	
	
func tween_position_ease_into_bounce(node : Node, ease_dur_ratio : float, ease_position_ratio : float, starting_position : Vector2, position_offset : Vector2, duration : float) -> Signal:
	await tween_animation_offset(node, Tween.EASE_IN, Tween.TRANS_CUBIC, node.set_position, starting_position, position_offset * ease_position_ratio, duration * ease_dur_ratio)
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_ELASTIC, node.set_position, node.position, position_offset * (1 - ease_position_ratio), duration * (1 - ease_dur_ratio))


func tween_size(node : Node, starting_size : Vector2, size_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_CUBIC, node.set_size, starting_size, size_offset, duration)


func tween_custom_minimum_size(node : Control, starting_size : Vector2, size_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_CUBIC, node.set_custom_minimum_size, starting_size, size_offset, duration)
	
	
func tween_custom_minimum_size_ease_in(node : Control, starting_size : Vector2, size_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN, Tween.TRANS_CUBIC, node.set_custom_minimum_size, starting_size, size_offset, duration)
	

func tween_custom_minimum_size_bounce(node : Control, starting_size : Vector2, size_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_ELASTIC, node.set_custom_minimum_size, starting_size, size_offset, duration)


func tween_scale(node : Node, starting_scale : Vector2, scale_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_CUBIC, node.set_scale, starting_scale, scale_offset, duration)
	
	
func tween_scale_ease_in(node : Node, starting_scale : Vector2, scale_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN, Tween.TRANS_CUBIC, node.set_scale, starting_scale, scale_offset, duration)
	

func tween_scale_ease_in_out(node : Node, starting_scale : Vector2, scale_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC, node.set_scale, starting_scale, scale_offset, duration)
	
	
func tween_scale_wiggle(node : Node, starting_scale : Vector2, scale_offset : Vector2, duration : float) -> Signal:
	await tween_scale_ease_in(node, starting_scale, scale_offset, duration * 0.2)
	return tween_scale_bounce(node, node.scale, starting_scale - node.scale, duration * 0.8)
	
	
func tween_font_color(node : RichTextLabel, font_color_key : String, starting_font_color : Color, final_font_color : Color, duration : float) -> Signal:
	return tween_animation(node, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR, set_label_font_color.bind(node, font_color_key), starting_font_color, final_font_color, duration)	
	

func tween_font_size(node : RichTextLabel, starting_font_size : int, font_size_offset : int, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_CUBIC, set_label_font_size.bind(node), starting_font_size, font_size_offset, duration)
	
	
func tween_font_size_bounce(node : RichTextLabel, starting_font_size : int, font_size_offset : int, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_ELASTIC, set_label_font_size.bind(node), starting_font_size, font_size_offset, duration)
	
	
func set_label_font_color(color : Color, label : RichTextLabel, font_color_key : String) -> void:
	label.add_theme_color_override(font_color_key, color)
	
	
func set_label_font_size(font_size : int, label : RichTextLabel) -> void:
	label.add_theme_font_size_override("normal_font_size", font_size)
	
	
func tween_shake_back_and_forth(node : CanvasItem, shake_radius : Vector2, frequency : int, duration : float) -> Signal:
	var base_position : Vector2 = node.position
	var starting_shake_radius : Vector2 = shake_radius
	for idx in range(frequency):
		var target_position : Vector2 = base_position + shake_radius
		var shake_animation_signal : Signal = tween_position(node, node.position, target_position - node.position, duration / float(frequency))
		shake_radius *= -1
		if shake_radius.x > 0 or shake_radius.y > 0:
			shake_radius -= starting_shake_radius / Vector2(float(frequency), float(frequency))
		else:
			shake_radius += starting_shake_radius / Vector2(float(frequency), float(frequency))
		if idx == frequency - 1:
			node.position = base_position
			return shake_animation_signal
		else:
			await shake_animation_signal
	return get_tree().process_frame # unreachable
	
	
func tween_random_shake_back_and_forth(node : CanvasItem, shake_radius : Vector2, frequency : int, duration : float) -> Signal:
	var starting_shake_radius : Vector2 = shake_radius
	for idx in range(frequency):
		var shake_animation_signal : Signal = tween_position(node, node.position, Vector2(\
				randf_range(0, shake_radius.x),\
				randf_range(0, shake_radius.y)), duration / float(frequency))
		shake_radius *= -1
		if shake_radius.x > 0 or shake_radius.y > 0:
			shake_radius -= starting_shake_radius / Vector2(float(frequency), float(frequency))
		else:
			shake_radius += starting_shake_radius / Vector2(float(frequency), float(frequency))
		if idx == frequency - 1:
			return shake_animation_signal
		else:
			await shake_animation_signal
	return get_tree().process_frame # unreachable	
	
	
func tween_random_shake(node : CanvasItem, shake_radius : Vector2, frequency : int, duration : float) -> Signal:
	for idx in range(frequency):
		var shake_animation_signal : Signal = tween_position(node, node.position, Vector2(\
				randf_range(shake_radius.x * -1.0, shake_radius.x),\
				randf_range(shake_radius.x* -1.0, shake_radius.y)), duration / float(frequency))
		if idx == frequency - 1:
			return shake_animation_signal
		else:
			await shake_animation_signal
	return get_tree().process_frame # unreachable
	
	
func tween_random_hard_shake(node : CanvasItem, shake_radius : Vector2, frequency : int, duration : float) -> Signal:
	for idx in range(frequency):
		var next_shake_timeout : Signal = get_tree().create_timer(duration / float(frequency)).timeout
		node.position += Vector2(randf_range(shake_radius.x * -1.0, shake_radius.x), randf_range(shake_radius.x * -1.0, shake_radius.x))
		if idx == frequency - 1:
			return next_shake_timeout
		else:
			await next_shake_timeout
	return get_tree().process_frame # unreachable
	
	
func tween_scale_pop(node : Node, scale_offset : Vector2, duration : float) -> Signal:
	var node_starting_scale : Vector2 = node.scale
	await tween_scale_ease_in(node, node_starting_scale, scale_offset, duration * 0.1)
	if node == null or !node.is_inside_tree():
		return await get_tree().process_frame
	return tween_scale_bounce(node, node.scale, node_starting_scale - node.scale, duration * 0.9)


func tween_scale_ease_into_bounce(node : Node, ease_dur_ratio : float, ease_scale_ratio : float, starting_scale : Vector2, scale_offset : Vector2, duration : float) -> Signal:
	await tween_animation_offset(node, Tween.EASE_IN, Tween.TRANS_CUBIC, node.set_scale, starting_scale, scale_offset * ease_scale_ratio, duration * ease_dur_ratio)
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_ELASTIC, node.set_scale, node.scale, scale_offset * (1 - ease_scale_ratio), duration * (1 - ease_dur_ratio))


func tween_scale_bounce(node : Node, starting_scale : Vector2, scale_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_ELASTIC, node.set_scale, starting_scale, scale_offset, duration)
	
	
func tween_scale_back(node : Node, starting_scale : Vector2, scale_offset : Vector2, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN, Tween.TRANS_BACK, node.set_scale, starting_scale, scale_offset, duration)
	
	
func tween_rot(node : Node, start_rot : float, rot_offset : float, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_CIRC, node.set_rotation, start_rot, rot_offset, duration)
	
	
func tween_rot_bounce(node : Node, start_rot : float, rot_offset : float, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_ELASTIC, node.set_rotation, start_rot, rot_offset, duration)
	
	
func tween_rot_ease_in_out(node : Node, start_rot : float, rot_offset : float, duration : float) -> Signal:
	return tween_animation_offset(node, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC, node.set_rotation, start_rot, rot_offset, duration)
	

func tween_shader_parameter(material : ShaderMaterial, parameter_name : String, starting_val : Variant, final_val : Variant, duration : float) -> Signal:
	return tween_animation(self, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR, self.set_shader_parameter_val.bind(material, parameter_name), starting_val, final_val, duration)
	

func tween_shader_parameter_ease_in(material : ShaderMaterial, parameter_name : String, starting_val : Variant, final_val : Variant, duration : float) -> Signal:
	return tween_animation(self, Tween.EASE_IN, Tween.TRANS_CUBIC, self.set_shader_parameter_val.bind(material, parameter_name), starting_val, final_val, duration)	
	
	
func set_shader_parameter_val(value : Variant, material : ShaderMaterial, parameter_name : String) -> void:
	material.set_shader_parameter(parameter_name, value)


func tween_wiggle_range(node : Node, min_ : float, max_ : float, duration : float) -> Signal:
	var rot = randf_range(min_, max_)
	return tween_wiggle(node, rot, duration)
	
	
func tween_wiggle(node : Node, rot : float, duration : float = DEFAULT_WIGGLE_DURATION) -> Signal:
	if randi_range(0, 1):
		rot *= -1
	return tween_animation_offset(node, Tween.EASE_OUT, Tween.TRANS_ELASTIC, node.set_rotation, rot, 0.0 - rot, duration)
	
	
func tween_volume(audio_player : AudioStreamPlayer2D, starting_volume : float, final_volume : float, duration : float) -> Signal:
	var set_volume : Callable = func(volume:float, audio:AudioStreamPlayer2D): audio.volume_db = volume
	return tween_animation(audio_player, Tween.EASE_IN, Tween.TRANS_LINEAR, set_volume.bind(audio_player), starting_volume, final_volume, duration)
