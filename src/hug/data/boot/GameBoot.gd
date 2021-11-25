extends Node

export(String) var initial_map = ''
export(int) var initial_x = 0
export(int) var initial_y = 0
export(String) var initial_player_actor = ''

export(Texture) var window_skin = null
export(int) var window_skin_edge_size = 8
export(Texture) var window_arrow_texture = null

export(Font) var game_font = null

func _ready() -> void:
	HUG.set_player_actor_name(initial_player_actor)
	HUG.teleport_player(initial_map, initial_x, initial_y)
	HUG.set_window_skin(window_skin)
	HUG.set_window_skin_edge_size(window_skin_edge_size)
	HUG.set_waiting_arrow_texture(window_arrow_texture)
	HUG.set_game_font(game_font)
	move_to_first_scene()

func move_to_first_scene():
	HUG.push_scene("Title")
