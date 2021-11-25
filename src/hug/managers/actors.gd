extends Node
class_name ActorManager

func get_scene_path(actor_name):
	return "res://src/actors/" + actor_name + ".tscn"
