extends Node
class_name SaveSystem

const _SAVE_PATH = "user://"

var save_paths : Dictionary = {}

func save(file_name : String, data_dictionary : Dictionary) -> void:
	var file = File.new()
	file.open(_SAVE_PATH + file_name, File.WRITE)
	file.store_var(data_dictionary)
	file.close()
	
	if !save_paths.has(file_name):
		save_paths[file_name] = data_dictionary

func load_data(file_name : String, data_dictionary : Dictionary = {}) -> Dictionary:
	var file = File.new()
	
	if !save_paths.has(file_name):
		save_paths[file_name] = data_dictionary
	
	if !file.file_exists(_SAVE_PATH + file_name):
		if data_dictionary.is_empty():
			return {}
		
		file.open(_SAVE_PATH + file_name, File.WRITE)
		file.store_var(data_dictionary)
		file.close()
		return data_dictionary
	
	file.open(_SAVE_PATH + file_name, File.READ)
	var loaded_save : Dictionary = file.get_var()
	var cur_save = data_dictionary
	
	for key in data_dictionary:
		if loaded_save.has(key):
			cur_save[key] = loaded_save[key]
	
	file.close()
	var write_file = File.new()
	write_file.open(_SAVE_PATH + file_name, File.WRITE)
	write_file.store_var(cur_save)
	write_file.close()
	
	return cur_save

func _notification(what: int) -> void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST: return
	save_all_paths()

func save_all_paths() -> void:
	for i in save_paths:
		var file = File.new()
		file.open(_SAVE_PATH + i, File.WRITE)
		file.store_var(save_paths[i])
		file.close()
