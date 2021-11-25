extends CanvasLayer

func fade_in() -> void:
	$AnimationPlayer.play("Fade In")

func fade_out() -> void:
	$AnimationPlayer.play("Fade Out")

func _ready() -> void:
	# warning-ignore:return_value_discarded
	HUG.screen.connect("fade_in", self, "fade_in")
	# warning-ignore:return_value_discarded
	HUG.screen.connect("fade_out", self, "fade_out")

func set_window_skin(texture):
	$Control/DialogBox.set_window_skin(texture)

func set_window_skin_edge_size(size):
	$Control/DialogBox.set_window_skin_edge_size(size)
	
func set_waiting_arrow_texture(texture):
	$Control/DialogBox.set_waiting_arrow_texture(texture)
