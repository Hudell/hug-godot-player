extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed() -> void:
	HUG.push_scene("Map")

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
