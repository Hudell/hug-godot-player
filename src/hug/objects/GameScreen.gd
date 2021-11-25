extends Node
class_name GameScreen

signal fade_in
signal fade_out

func call_fade_in() -> void:
	emit_signal("fade_in")

func call_fade_out() -> void:
	emit_signal("fade_out")
