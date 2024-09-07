extends Node


func _init() -> void:
	var copy_file: DirAccess = DirAccess.open("res://logs")
	if DirAccess.get_open_error():
		DirAccess.make_dir_absolute("res://logs")
		copy_file = DirAccess.open("res://logs")
	copy_file.copy("res://logs/latest.log", "res://logs/log_%s.log" % Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_"))
	var log_file = FileAccess.open("res://logs/latest.log", FileAccess.WRITE)
	log_file.resize(0)
	log_file.close()
	var data_json_file: FileAccess = FileAccess.open("res://data.json", FileAccess.READ)
	var data_json_dict: Dictionary = JSON.parse_string(data_json_file.get_as_text())
	self.write_log(["New log started, open game count: ", data_json_dict["game_open_count"]])
	
	
func write_log(content: Array, do_print: bool = false) -> void:
	var log_file = FileAccess.open("res://logs/latest.log", FileAccess.READ_WRITE)
	var stored_string = "[%s] %s" % [Time.get_datetime_string_from_system(false, true), "".join(content)]
	if log_file:
		log_file.seek_end()
		log_file.store_string(stored_string + "\n")
		log_file.close()
	else:
		print("Open log file failed.")
	if do_print:
		print(stored_string)
