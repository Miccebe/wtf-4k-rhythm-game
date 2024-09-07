extends Button
class_name Settings

var settings_path_string: String = "%s/settings.ini" % OS.get_executable_path()
# 延迟设定
var music_offset: int = 0
var input_offset: int = 0
var chart_flow_speed: float = 7.0
# 流速为 1.0 ~ 12.0, 7.5是用的最舒服的流速, 大于12.0为Sonic速
# 键位设定
var track1_key: Key = KEY_D
var track2_key: Key = KEY_F
var track3_key: Key = KEY_J
var track4_key: Key = KEY_K
# 音量设定
var music_volume: int = 100
var se_volume: int = 100
var correct_volume: int = 100


func _init() -> void:
	self.settings_path_string = "res://settings.ini"		##### 记得注释掉
	var data_json_file: FileAccess = FileAccess.open("res://data.json", FileAccess.READ)
	var data_json_dict: Dictionary = JSON.parse_string(data_json_file.get_as_text())
	if data_json_dict and data_json_dict["game_open_count"] <= 1:
		self.save_config()
	else:
		self.load_config()
	

func save_config() -> void:
	var settings_file: ConfigFile = ConfigFile.new()
	settings_file.set_value("game_settings", "music_offset", self.music_offset)
	settings_file.set_value("game_settings", "input_offset", self.input_offset)
	settings_file.set_value("game_settings", "chart_flow_speed", self.chart_flow_speed)
	settings_file.set_value("game_settings", "track1_key", self.track1_key)
	settings_file.set_value("game_settings", "track2_key", self.track2_key)
	settings_file.set_value("game_settings", "track3_key", self.track3_key)
	settings_file.set_value("game_settings", "track4_key", self.track4_key)
	settings_file.set_value("volume_settings", "music_volume", self.music_volume)
	settings_file.set_value("volume_settings", "se_volume", self.se_volume)
	settings_file.set_value("volume_settings", "correct_volume", self.correct_volume)
	settings_file.save(self.settings_path_string)


func load_config() -> void:
	var settings_file: ConfigFile = ConfigFile.new()
	if settings_file.load(self.settings_path_string):
		var new_settings_file: FileAccess = FileAccess.open(settings_path_string, FileAccess.WRITE)
		new_settings_file.close()
		settings_file.load(self.settings_path_string)
	self.music_offset = settings_file.get_value("game_settings", "music_offset", 0)
	self.input_offset = settings_file.get_value("game_settings", "input_offset", 0)
	self.chart_flow_speed = settings_file.get_value("game_settings", "chart_flow_speed", 7.5)
	self.track1_key = settings_file.get_value("game_settings", "track1_key", KEY_D)
	self.track2_key = settings_file.get_value("game_settings", "track2_key", KEY_F)
	self.track3_key = settings_file.get_value("game_settings", "track3_key", KEY_J)
	self.track4_key = settings_file.get_value("game_settings", "track4_key", KEY_K)
	self.music_volume = settings_file.get_value("volume_settings", "music_volume", 100)
	self.se_volume = settings_file.get_value("volume_settings", "se_volume", 100)
	self.correct_volume = settings_file.get_value("volume_settings", "correct_volume", 100)
