extends Node
class_name SceneManager

func _ready() -> void:
	pass # Replace with function body.

func get_scene_path(scene_name):
	match scene_name:
		"Title":
			return "res://src/hug/scenes/title/SceneTitle.tscn"
		"Map":
			return "res://src/hug/scenes/map/SceneMap.tscn"
	
	return null
