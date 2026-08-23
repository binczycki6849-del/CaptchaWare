extends Node

class_name Microgame

export var microgame_data : Resource = null

signal override_instruction_text(big, small)
signal set_camera_shake(intensity, duration)
signal skip_timer
signal end_microgame
signal freeze_timer_signal

var is_intro := false
var skipped := false

var difficulty : int = 1

var current_game_speed : = 0.0

var finished := false

var force_stopped := false

func stop_microgame() -> void:
	force_stopped = true

func force_end_mircogame() -> void:
	emit_signal("end_microgame")

func freeze_timer() -> void:
	emit_signal("freeze_timer_signal")

func get_file_list(path, file_type = ".png"):
	var results = []
	var dir = Directory.new()
	if dir.open(path) != OK:
		print_debug(error_string(FAILED))
		return results
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name != "":
		if file_type in file_name:
			results.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return results

func get_json_data(path):
	var file = File.new()
	if file.open(path + ".json", File.READ) != OK:
		return {}
	var parsed = JSON.parse(file.get_as_text())
	file.close()
	if parsed.error == OK:
		return parsed.result
	return {}

func canSkip() -> bool:
	return isWinning()

func isWinning() -> bool:
	return finished

func on_transition_complete() -> void:
	pass
