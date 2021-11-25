extends Sprite
class_name ActorSprite

export(int) var sprite_index = 0
const movement_frames = 3

var loaded_actor_name = null
var loaded_direction = null
var loaded_frame_index = null

func load_from_actor(actor, actor_name):
	loaded_actor_name = actor_name
	texture = actor.texture
	hframes = actor.h_frames
	vframes = actor.v_frames
	sprite_index = actor.sprite_index
	centered = actor.centered
	offset = actor.offset
	flip_h = actor.flip_h
	flip_v = actor.flip_v
	position = actor.position
	rotation_degrees = actor.rotation_degrees
	scale = actor.scale
	
	if loaded_direction != null and loaded_frame_index != null:
		set_sprite_frame(loaded_direction, loaded_frame_index)

func set_sprite_frame_rpg_maker_single_char(direction: String, index: int) -> void:
	match direction:
		'Down':
			frame = index
		'Left':
			frame = index + 3
		'Right':
			frame = index + 6
		'Up':
			frame = index + 9

func set_sprite_frame_rpg_maker_8_char(direction: String, index: int) -> void:
	var row = 0
	var top_row = 0
	if sprite_index >= 4:
		top_row = 4
	
	match direction:
		'Down':
			row = top_row + 0
		'Left':
			row = top_row + 1
		'Right':
			row = top_row + 2
		'Up':
			row = top_row + 3

	var col = (sprite_index % 4) * movement_frames + index
	frame = row * hframes + col

func set_sprite_frame_strip(direction: String, index: int) -> void:
	set_sprite_frame_rpg_maker_single_char(direction, index)

func set_sprite_frame(direction: String, index: int) -> void:
	loaded_direction = direction
	loaded_frame_index = index
	
	if hframes == 3 and vframes == 4:
		set_sprite_frame_rpg_maker_single_char(direction, index)
		return
	
	if hframes == 12 and vframes == 8:
		set_sprite_frame_rpg_maker_8_char(direction, index)
		return
	
	set_sprite_frame_strip(direction, index)
