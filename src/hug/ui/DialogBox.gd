extends TextureRect
class_name DialogBox

onready var text = $Text
onready var responseList = $ResponseList
var textResponse = preload("res://src/hug/ui/TextResponse.tscn")

# warning-ignore:unused_signal
signal dialog_started
# warning-ignore:unused_signal
signal dialog_ended

var lines_to_skip = 0
var responses = null

func _ready() -> void:
	hide()
	
func set_responses(new_responses) -> void:
	responses = new_responses
	
	var children = responseList.get_children()
	for child in children:
		responseList.remove_child(child)
	
	if responses == null:
		return

	var index = 0
	for response in responses:
		var new_button = textResponse.instance()
		new_button.text = response.text
		new_button.connect("pressed", response.obj, response.function, [index])
		new_button.connect("pressed", self, "any_response_pressed", [index])
		new_button.response_index = index
		responseList.add_child(new_button)
		index += 1

func show_dialog(new_text: Dictionary) -> void:
	text.text = new_text.text
	lines_to_skip = 0
	text.lines_skipped = lines_to_skip
	if new_text.has("responses"):
		set_responses(new_text.responses)
	else:
		set_responses(null)

	if visible:
		$AnimationPlayer.play("restart")
	else:
		$AnimationPlayer.play("appear")
		
func _physics_process(_delta: float) -> void:
	if visible:
		return
	
	if !HUG.text.is_queue_empty():
		load_next_text()

func _input(event) -> void:
	maybe_skip_text(event)
	maybe_focus_responses(event)
	
func responses_need_focus() -> bool:
	if responses == null:
		return false
	
	var children = responseList.get_children()
	for child in children:
		if child.has_focus():
			return false
	
	return true

func maybe_focus_responses(event) -> void:
	if !responses_need_focus():
		return
		
	# If the user pressed the accept button during the cooldown, reset the cooldown
	if event.is_action_pressed("ui_accept"):
		var timer = $SelectFirstResponseTimer
		if !timer.is_stopped():
			timer.start(0.5)
			return
	
	if (Input.is_action_just_released("ui_left") or
		Input.is_action_just_released("ui_right") or
		Input.is_action_just_released("ui_up") or
		Input.is_action_just_released("ui_down")):
		ensure_responses_have_focus()

func maybe_skip_text(event) -> void:
	if !event.is_action_pressed("ui_accept") and !event.is_action_pressed("mouse_left"):
		return

	match $AnimationPlayer.assigned_animation:
		"show_text":
			$AnimationPlayer.play("wait")
		"wait":
			lines_to_skip += 3
			if lines_to_skip < text.get_line_count():
				text.lines_skipped = lines_to_skip
				$AnimationPlayer.play("show_text")
			else:
				maybe_load_next_text()
	

func maybe_jump_to_wait() -> void:
	if text.text.length() < text.visible_characters:
		$AnimationPlayer.play("wait")

func load_next_text() -> void:
	show_dialog(HUG.text.pop_text())

func maybe_load_next_text() -> void:
	if responses != null:
		return
	
	if HUG.text.is_queue_empty():
		if visible:
			$AnimationPlayer.play("disappear")
		return

	load_next_text()

func any_response_pressed(_index: int) -> void:
	set_responses(null)
	maybe_load_next_text()

func ensure_responses_have_focus() -> void:
	if responses == null:
		return
	
	var children = responseList.get_children()
	var first_child = null
	for child in children:
		if first_child == null:
			first_child = child
		if child.has_focus():
			return

	if first_child != null:
		first_child.grab_focus()

func _on_AnimationPlayer_animation_started(anim_name: String) -> void:
	if anim_name != "wait":
		return
	
	$SelectFirstResponseTimer.start(0.5)

func _on_SelectFirstResponseTimer_timeout() -> void:
	ensure_responses_have_focus()

func set_window_skin(texture):
	$NinePatchRect.texture = texture

func set_window_skin_edge_size(size):
	var rect = $NinePatchRect
	rect.patch_margin_left = size
	rect.patch_margin_bottom = size
	rect.patch_margin_right = size
	rect.patch_margin_top = size

func set_waiting_arrow_texture(texture):
	$WaitingArrow.texture = texture

func _on_DialogBox_dialog_ended() -> void:
	HUG.text._on_dialog_ended()

func _on_DialogBox_dialog_started() -> void:
	if HUG.game_font != null:
		$Text.add_font_override("font", HUG.game_font)
	HUG.text._on_dialog_started()
