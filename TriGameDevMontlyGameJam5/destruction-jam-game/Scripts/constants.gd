extends Node


const VERSION : String = "0.0.0"

# TIMING
const ANIMATION_TICK_SPEED : float = 0.01
const SNAPPINESS : float = 1.0
var SHORT_WAIT : float:
	get: return SNAPPINESS * 0.1

# LIMITS
const MAX_A8 = 255
const MIN_A8 = 0

# COLORS
const WHITE : Color = Color(1.0, 1.0, 1.0)
const FLASH_WHITE : Color = Color(2.0, 2.0, 2.0)
const BLACK : Color = Color("#000000")
const INVIS : Color = Color("#ffffff00")

# -- COLOR PALETTES
# - ICYWITCH
const DARK_GREEN : Color = Color("#313638")
const DARK_BLUE : Color = Color("#32535f")
const BLUE : Color = Color("#0a777a")
const GREEN : Color = Color("#4aa881")
const LIGHT_BLUE : Color = Color("#73efe8")
const YELLOW : Color = Color("#ecf3b0")

# BBCODE
const WAVE_TEMPLATE : String = "[wave amp=20 freq=5 connected=0]%s[/wave]"
const WAVE2_TEMPLATE : String = "[wave amp=10 freq=5 connected=0]%s[/wave]"
const WAVE3_TEMPLATE : String = "[wave amp=20 freq=15 connected=1]%s[/wave]"
const BOLD_TEMPLATE : String = "[b]%s[/b]"
const ITALICS_TEMPLATE : String = "[i]%s[/i]"
const IMG_TEMPLATE : String = "[img]%s[/img]"
const SHAKE_TEMPLATE : String = "[shake rate=5 level=10]%s[/shake]"
const UNDERLINE_TEMPLATE : String = "[u]%s[/u]"
const COLOR_TEMPLATE : String = "[color=%s]%s[/color]"
