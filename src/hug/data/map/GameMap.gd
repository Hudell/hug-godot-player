extends StaticBody2D
class_name GameMap

export(int) var width = 1280
export(int) var height = 768

var map_id = 'unknown'

func set_nothing(_value):
	pass

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func setup(new_map_id):
	map_id = new_map_id

func clear_map():
	queue_free()
