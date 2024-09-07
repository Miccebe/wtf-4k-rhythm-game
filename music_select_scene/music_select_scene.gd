extends Node2D


func _init() -> void:
	var data_json_file: FileAccess = FileAccess.open("res://data.json", FileAccess.READ_WRITE)
	var data_json_dict: Dictionary = JSON.parse_string(data_json_file.get_as_text())
	data_json_dict["game_open_count"] += 1
	data_json_file.seek(0)
	data_json_file.resize(0)
	data_json_file.store_string(JSON.stringify(data_json_dict, "\t"))
