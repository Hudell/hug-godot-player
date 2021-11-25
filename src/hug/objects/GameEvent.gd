extends Area2D
class_name GameEvent

signal activated

func activate() -> void:
	emit_signal("activated")
