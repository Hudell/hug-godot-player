extends Node
class_name GameText

signal dialog_started
signal dialog_ended
signal picked_response

var active = false
var text_queue = []
var responses = []

func is_queue_empty() -> bool:
	return text_queue.size() == 0

func is_busy() -> bool:
	if active:
		return true
	
	if !is_queue_empty():
		return true
	
	return false

func add(text: String) -> void:
	var item = {
		'text': text
	}
	
	if responses.size() > 0:
		item.responses = responses
		responses = []
	
	text_queue.append(item)
	
func clear_responses() -> void:
	responses.clear()

func add_response(text: String, obj: Object, function_name: String) -> void:
	responses.append({
		'text': text,
		'obj': obj,
		'function': function_name
	})

func apply_responses() -> void:
	if responses == null or responses.size() == 0:
		return

	var item = text_queue.pop_back()
	if item == null:
		return
	
	item.responses = responses
	text_queue.append(item)

func pop_text() -> Dictionary:
	return text_queue.pop_front()

func _on_dialog_started() -> void:
	active = true
	emit_signal("dialog_started")

func _on_dialog_ended() -> void:
	active = false
	emit_signal("dialog_ended")

func pick_response() -> void:
	emit_signal("picked_response")
