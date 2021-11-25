extends Button
class_name TextResponse

export(int) var response_index = 0

func _ready() -> void:
	if HUG.game_font != null:
		add_font_override("font", HUG.game_font)
