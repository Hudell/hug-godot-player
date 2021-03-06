extends KinematicBody2D

onready var sprite_holder = $SpriteHolder
onready var interactionRay = $InteractionRayCast
onready var animation_tree = $AnimationTree
onready var animation_state = $AnimationTree.get("parameters/playback")
onready var collision_shape = $CollisionShape2D

enum {
	MOVE,
	WAITING,
	DEAD
}

const MAX_SPEED = 300.0
const MAX_WALK_SPEED = 200.0
const MIN_MOVING_SPEED = 10
const GRAVITY = 400.0
const UP = Vector2.UP
const JUMP_STRENGTH = 400

var state = MOVE
var velocity = Vector2.ZERO
var gravity_velocity = Vector2.ZERO
var jump_velocity = Vector2.ZERO
var jump_timeout = 0.0
var is_running = false
var loaded_actor_name = null
var loaded_actor_data = false
var actor_instance = null setget set_nothing
var direction = null setget set_direction
var is_platforming = false setget set_nothing

func _ready() -> void:
	animation_tree.active = true

func set_nothing(_value):
	pass

func set_direction(value):
	update_direction(value)

func _physics_process(delta: float) -> void:
	maybe_update_actor()

	if HUG.text.active:
		return
	
	match state:
		MOVE:
			move_state(delta)
		DEAD:
			pass

func move_state(delta: float) -> void:
	if jump_timeout > 0:
		jump_timeout = max(0, jump_timeout - delta)

	move_by_input(delta)
	update_move_animation()
	move()
	
	check_interactions()
	
func check_interactions() -> void:
	if !Input.is_action_just_pressed("interact"):
		return
		
	interactionRay.enabled = true
	interactionRay.force_raycast_update()
	_check_interactions()
	interactionRay.enabled = false

func _check_interactions() -> void:
	if !interactionRay.is_colliding():
		return

	var collider = interactionRay.get_collider()
	if collider != null and collider is GameEvent:
		collider.activate()
	
func get_max_speed() -> float:
	if is_running:
		return MAX_SPEED
	
	return MAX_WALK_SPEED

func apply_move_vector(move_vector: Vector2, _delta: float) -> void:
	if move_vector == Vector2.ZERO:
		velocity = Vector2.ZERO
		return
	
	update_direction(move_vector)
	velocity = move_vector * get_max_speed()

func update_direction(vector: Vector2) -> void:
	direction = vector
	animation_tree.set("parameters/Idle/blend_position", vector)
	animation_tree.set("parameters/Walk/blend_position", vector)
	
	interactionRay.cast_to = vector * 50

func start_walking() -> void:
	travel("Walk")

func stop_moving() -> void:
	travel("Idle")

func get_speed() -> float:
	if is_platforming:
		return abs(velocity.x)

	return max(abs(velocity.x), abs(velocity.y))

func update_move_animation_platforming() -> void:
	if velocity.x == 0:
		stop_moving()
		return
		
	var speed = get_speed()
	if speed < MIN_MOVING_SPEED:
		stop_moving()
		return
		
	start_walking()

func update_move_animation() -> void:
	if is_platforming:
		update_move_animation_platforming()
		return

	if velocity == Vector2.ZERO:
		stop_moving()
		return
		
	var speed = get_speed()

	if speed < MIN_MOVING_SPEED:
		stop_moving()
		return
		
	start_walking()

func move() -> void:
	if is_platforming:
		if jump_velocity != Vector2.ZERO:
			jump_velocity = move_and_slide(jump_velocity, UP)
			if jump_velocity.y + GRAVITY > 0:
				jump_timeout = 0
				jump_velocity = Vector2.ZERO
			elif jump_timeout == 0:
				jump_velocity.y = min(0, jump_velocity.y + 10)
		elif !is_on_floor():
			gravity_velocity = Vector2.DOWN * GRAVITY
	else:
		gravity_velocity = Vector2.ZERO
	
	velocity = move_and_slide(velocity, UP)
	gravity_velocity = move_and_slide(gravity_velocity, UP)

func mark_as_dead() -> void:
	state = DEAD
	visible = false
#	queue_free()

func move_by_input(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if is_platforming:
		if is_on_floor() and Input.is_action_just_pressed("ui_up"):
			jump_velocity.y = -JUMP_STRENGTH
			jump_timeout = 0.4
	else:
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	is_running = Input.is_action_pressed("run")
	apply_move_vector(input_vector, delta)

func set_camera_path(camera_path: NodePath) -> void:
	$RemoteTransform2D.remote_path = camera_path

func get_sprite():
	return sprite_holder.get_child(0)

func travel(new_animation):
	animation_state.travel(new_animation)

func set_sprite_frame(frame_direction: String, index: int) -> void:
	var sprite = get_sprite()
	if sprite is ActorSprite:
		sprite.set_sprite_frame(frame_direction, index)

func set_actor_name(actor_name):
	loaded_actor_name = actor_name
	loaded_actor_data = false
	if actor_name == null:
		return

	var actor_path = HUG.actors.get_scene_path(actor_name)
	var actor_class = load(actor_path)
	actor_instance = actor_class.instance()
	
	apply_loaded_actor_data()

func apply_loaded_actor_data():
	if actor_instance == null:
		return
	
	is_platforming = actor_instance is GamePlatformActor
	
	var sprite = get_sprite()
	if sprite == null:
		return
	if !(sprite is ActorSprite):
		return

	sprite.load_from_actor(actor_instance, loaded_actor_name)
	load_actor_collision(actor_instance)
	loaded_actor_data = true
	
#	update_direction(direction)

func load_actor_collision(new_actor_instance):
	collision_layer = new_actor_instance.collision_layer
	collision_mask = new_actor_instance.collision_mask

	collision_shape.shape = new_actor_instance.shape
	collision_shape.position = new_actor_instance.collision_position
	collision_shape.rotation_degrees = new_actor_instance.collision_rotation

func maybe_update_actor():
	var new_name = HUG.player_actor_name
	
	if loaded_actor_name != new_name:
		set_actor_name(new_name)
		return
