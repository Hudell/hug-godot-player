extends Node2D
class_name SceneMap

onready var y_sort = $YSort
onready var map_holder = $MapHolder
onready var camera = $Camera2D

var initialized = false
var is_ready = false
var auto_initialize = false

func _ready() -> void:
	is_ready = true
	if auto_initialize:
		initialize()
	
func load_initial_player() -> void:
	if y_sort.get_child_count() > 0:
		var player_instance = y_sort.get_child(0)
		HUG.set_player(player_instance)
		return
	
	var player_scene = HUG.player_scene
	if (player_scene == null):
		player_scene = "res://src/hug/objects/GamePlayer.tscn"
	
	var loaded_scene = load(player_scene)
	var game_player = loaded_scene.instance()
	game_player.set_camera_path("../../../Camera2D")
	y_sort.add_child(game_player)

	if HUG.player_x != null and HUG.player_y != null:
		game_player.position.x = HUG.player_x
		game_player.position.y = HUG.player_y
	
	game_player.update_direction(Vector2.DOWN)
	
	HUG.set_player(game_player)

func load_player() -> void:
	pass

func load_map(map_name) -> void:
	var map_path = HUG.maps.get_scene_path(map_name)
	var map_class = load(map_path)
	var map_instance = map_class.instance()

	while map_holder.get_child_count() > 0:
		var old_map = map_holder.get_child(0)
		map_holder.remove_child(old_map)

		old_map.clear_map()
	
	map_holder.add_child(map_instance)
	
	camera.limit_right = map_instance.width
	camera.limit_bottom = map_instance.height	

func load_window_skin():
	set_window_skin(HUG.window_skin)
	set_window_skin_edge_size(HUG.window_skin_edge_size)
	set_waiting_arrow_texture(HUG.waiting_arrow_texture)
	
func set_window_skin(texture):
	$MapUI.set_window_skin(texture)

func set_window_skin_edge_size(size):
	$MapUI.set_window_skin_edge_size(size)
	
func set_waiting_arrow_texture(texture):
	$MapUI.set_waiting_arrow_texture(texture)

func initialize():
	if initialized:
		return
	
	load_initial_player()
	load_window_skin()
	if HUG.map_name:
		load_map(HUG.map_name)
	initialized = true

func _on_SceneMap_tree_entered() -> void:
	if is_ready:
		initialize()
	else:
		auto_initialize = true
