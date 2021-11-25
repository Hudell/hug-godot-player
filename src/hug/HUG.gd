extends Node

onready var text = GameText.new()
onready var screen = GameScreen.new()
onready var scenes = SceneManager.new()
onready var maps = MapManager.new()
onready var actors = ActorManager.new()

var player_scene = null setget set_player_scene
var player = null setget set_player
var player_actor_name = null setget set_player_actor_name

var _initialized = false setget set_nothing
var map_name = null setget set_nothing
var player_x = null setget set_nothing
var player_y = null setget set_nothing
var current_scene_name setget set_nothing

var game_font = null setget set_game_font
var window_skin = null setget set_window_skin
var window_skin_edge_size = 0 setget set_window_skin_edge_size
var waiting_arrow_texture = null setget set_waiting_arrow_texture

func _ready() -> void:
	pass

func initialize() -> void:
	pass

func push_scene(new_scene) -> void:
	_initialized = true
	current_scene_name = new_scene
	var scene_path = scenes.get_scene_path(new_scene)
	if (scene_path == null):
		scene_path = new_scene
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene(scene_path)

func set_player_scene(scene_path) -> void:
	player_scene = scene_path

func set_player(player_instance) -> void:
	player = player_instance

func set_player_actor_name(actor_name) -> void:
	player_actor_name = actor_name
	
	if _initialized == false:
		return
	
	if player == null:
		return
	
	player.set_actor_name(actor_name)

func set_nothing(_value) -> void:
	pass

func get_scene():
	return get_tree().current_scene

func teleport_player(new_map_name, x, y) -> void:
	map_name = new_map_name
	player_x = x
	player_y = y

	if _initialized == false:
		return
	
	var scene = get_scene()
	if scene != null and scene is SceneMap:
		player.position.x = 0
		player.position.y = 0
		scene.load_map(new_map_name)	
	
	if player != null:
		player.position.x = x
		player.position.y = y

func set_window_skin(texture):
	window_skin = texture

	var scene = get_scene()
	if scene != null and scene is SceneMap:
		scene.set_window_skin(texture)

func set_window_skin_edge_size(size):
	window_skin_edge_size = size

	var scene = get_scene()
	if scene != null and scene is SceneMap:
		scene.set_window_skin_edge_size(size)
	
func set_waiting_arrow_texture(texture):
	waiting_arrow_texture = texture

	var scene = get_scene()
	if scene != null and scene is SceneMap:
		scene.set_waiting_arrow_texture(texture)

func set_game_font(new_font):
	game_font = new_font
