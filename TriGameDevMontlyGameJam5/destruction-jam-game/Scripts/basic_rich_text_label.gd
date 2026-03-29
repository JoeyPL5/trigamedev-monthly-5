extends RichTextLabel


enum WAVE_TYPE { NONE, WAVE1, WAVE2, WAVE3}
enum SHAKE_TYPE { NONE, SHAKE1 }


@export var wave_type : WAVE_TYPE = WAVE_TYPE.NONE
@export var shake_type : SHAKE_TYPE = SHAKE_TYPE.NONE
@export var has_shadow : bool = false
@export var shadow_color : Color = Constants.INVIS
@export var text_color : Color 


func _ready() -> void:
	format()
	
	
func format() -> void:
	match shake_type:
		SHAKE_TYPE.SHAKE1:
			self.text = Constants.SHAKE_TEMPLATE % self.text
		_:
			pass
	match wave_type:
		WAVE_TYPE.WAVE1:
			self.text = Constants.WAVE_TEMPLATE % self.text
		WAVE_TYPE.WAVE2:
			self.text = Constants.WAVE2_TEMPLATE % self.text
		WAVE_TYPE.WAVE3:
			self.text = Constants.WAVE3_TEMPLATE % self.text
		_:
			pass
	self.add_theme_color_override("default_color", text_color)
	if has_shadow:
		self.add_theme_color_override("font_shadow", shadow_color)
