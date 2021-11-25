extends Node
class_name GameActor

export(Texture) var texture = null
export(int) var h_frames = 12
export(int) var v_frames = 8
export(int) var sprite_index = 0

export(bool) var centered = true
export(Vector2) var offset = Vector2.ZERO
export(bool) var flip_h = false
export(bool) var flip_v = false

export(Vector2) var position = Vector2.ZERO
export(float) var rotation_degrees = 0
export(Vector2) var scale = Vector2.ONE

export(int, LAYERS_2D_PHYSICS) var collision_layer = 1
export(int, LAYERS_2D_PHYSICS) var collision_mask = 1
export(Shape2D) var shape = null
export(Vector2) var collision_position = Vector2.ZERO
export(int) var collision_rotation = 0
