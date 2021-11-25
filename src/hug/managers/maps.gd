extends Node
class_name MapManager

func _ready() -> void:
	pass # Replace with function body.

func get_scene_path(map_name):
	return "res://src/maps/" + map_name + ".tscn"
