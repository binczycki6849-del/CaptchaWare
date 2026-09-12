extends Node

class_name Microgame

export var microgame_data : MicrogameData = null

signal override_instruction_text
signal set_camera_shake(intensity, duration)
signal skip_timer
signal end_microgame
signal freeze_timer_signal

var is_intro = false
var skipped = false

var difficulty : int = 1

var current_game_speed = 0.0

var finished = false

var force_stopped = false

func stop_microgame() -> void:
	force_stopped = true

func force_end_mircogame() -> void:
	emit_signal("end_microgame")

func freeze_timer() -> void:
	emit_signal("freeze_timer_signal")

func get_file_list(path : String, file_type : String = ".png") -> Array:
	var directory = Directory.new()
	if directory.open(path) != OK:
		print_debug(error_string(FAILED))
		return []
	directory.list_dir_begin(true, true)
	var dir : Array = []
	var file_name = directory.get_next()
	while file_name != "":
		dir.append(file_name)
		file_name = directory.get_next()
	directory.list_dir_end()
	
	var dir_array : Array = []
	
	for file in dir:
		if !file.contains(file_type): continue
		dir_array.append(file)
	
	return dir_array

func get_json_data(path : String) -> Dictionary:
	var file = File.new()
	file.open(path + ".json", File.READ)
	var parse_result = parse_json(file.get_as_text())
	file.close()
	if typeof(parse_result) != TYPE_DICTIONARY:
		return {}
	return parse_result

func canSkip() -> bool:
	return isWinning()

func isWinning() -> bool:
	return finished

func on_transition_complete() -> void:
	pass
