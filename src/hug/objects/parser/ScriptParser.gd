extends Node
class_name ScriptParser

enum WAIT_MODE {
	NONE,
	MESSAGE
}

const COMMANDS = {
	"message_header": "message_header",
	"message": "message",
	"response_list": "response_list",
	"teleport_player": "teleport_player",
	"response_match": "response_match",
	"no_response": "no_response",
	"loop": "loop",
	"repeat": "repeat",
	"break": "break",
	"return": "return",
	"label": "label",
	"jump_to_label": "jump_to_label",
	"fade_out": "fade_out",
	"fade_in": "fade_in"
}

var level = 0
var command_index = 0
var script_name = null
var commands = null
var wait_count = 0
var wait_mode = WAIT_MODE.NONE setget set_wait_mode
var responses = null

func _ready() -> void:
	pass

func initialize() -> void:
	clear_data()
	level = 0
	responses = {}

func clear_data() -> void:
	script_name = null
	commands = null
	command_index = 0
	wait_count = 0
	wait_mode = WAIT_MODE.NONE

func set_wait_mode(new_wait_mode) -> void:
	wait_mode = new_wait_mode

func inherit(old_parser) -> void:
	clear_data()
	commands = old_parser.commands
	script_name = old_parser.script_name
	command_index = old_parser.command_index
	wait_count = old_parser.wait_count
	wait_mode = old_parser.wait_mode
	level = old_parser.level
	responses = old_parser.responses

func setup(command_list, commands_script_name) -> void:
	clear_data()
	commands = command_list
	script_name = commands_script_name

func is_running() -> bool:
	return commands != null

func update() -> void:
	while is_running():
		if update_wait():
			break
		if execute_command():
			break

func update_wait() -> bool:
	return update_wait_count() or update_wait_mode()

func update_wait_count() -> bool:
	if wait_count > 0:
		wait_count -= 1
		return true

	return false

func update_wait_mode() -> bool:
	var waiting = false

	match wait_mode:
		WAIT_MODE.MESSAGE:
			waiting = HUG.text.is_busy()

	if !waiting:
		wait_mode = WAIT_MODE.NONE
	return waiting

func wait(duration: int) -> void:
	wait_count = duration

func execute_command() -> bool:
	var command = current_command()
	if !command:
		terminate()
		return true

	level = command.level
	var method_name = "command_" + str(command.name)
	if has_method(method_name) and !call(method_name, command.parameters):
		return false

	command_index += 1
	return true

func terminate() -> void:
	commands = null

func skip_branch() -> void:
	while ((command_index + 1) < commands.size() and commands[command_index + 1].level > level):
		command_index += 1

func current_command():
	if commands == null or command_index >= commands.size():
		return null
	return commands[command_index]

func next_command_name():
	var command = commands[command_index + 1]
	if command != null:
		return command.name

	return null

func command_message_header(_params):
	if HUG.text.is_busy():
		return false

	while (next_command_name() == COMMANDS.message):
		command_index += 1
		HUG.text.add(current_command().parameters[0])

	match next_command_name():
		COMMANDS.response_list:
			command_index += 1
			setup_responses(current_command().parameters)

	set_wait_mode(WAIT_MODE.MESSAGE)
	return true

func command_response_list(params):
	if HUG.text.active:
		return false

	if HUG.text.is_queue_empty():
		HUG.text.add("[Responses without a message has not been implemented yet]")

	setup_responses(params)
	set_wait_mode(WAIT_MODE.MESSAGE)
	return true

func setup_responses(params) -> void:
	var responses = params[0]

	HUG.text.clear_responses()
	for response in responses:
		HUG.text.add_response(response, self, "_on_response_picked")

	HUG.text.apply_responses()

func _on_response_picked(new_index: int) -> void:
	responses[level] = new_index

func command_teleport_player(params) -> bool:
	var map_name = params[0]
	var map_x = params[1]
	var map_y = params[2]

	HUG.teleport_player(map_name, map_x, map_y)

	return true

func command_response_match(params) -> bool:
	HUG.text.clear_responses()
	if !responses.has(level) or responses[level] != params[0]:
		skip_branch()

	return true

func command_no_response(_params) -> bool:
	HUG.text.clear_responses()
	if responses[level] >= 0:
		skip_branch()

	return true

func command_loop(_params) -> bool:
	return true

func command_repeat(_params) -> bool:
	command_index -= 1
	while current_command().level != level:
		command_index -= 1
	return true

func command_break(_params) -> bool:
	var loop_depth = 0
	while (command_index < commands.size() - 1):
		command_index += 1
		var command = current_command()
		if command.name == COMMANDS.loop:
			loop_depth += 1
		elif command.name == COMMANDS.repeat:
			if loop_depth > 0:
				loop_depth -= 1
			else:
				break
	return true

func command_return(_params) -> bool:
	command_index = commands.size()
	return true

func command_label(_params) -> bool:
	return true

func command_jump_to_label(params) -> bool:
	var label_name = params[0]
	for i in range(0, commands.size()):
		var command = commands[i]
		if command.name == COMMANDS.label and command.parameters[0] == label_name:
			jump_to(i)
			return false

	return true

func jump_to(new_index: int) -> void:
	var last_index = command_index
	var start_index = min(new_index, last_index)
	var end_index = max(new_index, last_index)
	var last_level = level
	for i in range(start_index, end_index):
		var new_level = commands[i].level
		if new_level != last_level:
			responses[last_level] = null
			last_level = new_level
	command_index = new_index

func command_fade_out(_params) -> bool:
	if HUG.text.is_busy():
		return false

	HUG.screen.call_fade_out()
	wait(120)
	return true

func command_fade_in(_params) -> bool:
	if HUG.text.is_busy():
		return false

	HUG.screen.call_fade_in()
	wait(120)
	return true


