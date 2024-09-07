class_name BaseChartDirReference

var chart_file_path: String = ""
var bg_file_path: String = ""
var music_file_path: String = ""

const CHART_FILE_NAME: String = "chart.txt"
const BG_FILE_NAME: String = "bg.png"
const MUSIC_FILE_NAME: String = "track.mp3"
const DEFAULT_BG_FILE_PATH: String = "res://images/default_bg.png"


func open(_chart_dir_path: String) -> Error:
	var chart_dir: DirAccess = DirAccess.open(_chart_dir_path)
	if chart_dir.get_open_error():
		return chart_dir.get_open_error()
	chart_dir.list_dir_begin()
	var file_name: String = chart_dir.get_next()
	while file_name:
		if not chart_dir.current_is_dir():
			match file_name:
				CHART_FILE_NAME:
					self.chart_file_path = "%s/%s" % [chart_dir.get_current_dir(), file_name]
				BG_FILE_NAME:
					self.bg_file_path = "%s/%s" % [chart_dir.get_current_dir(), file_name]
				MUSIC_FILE_NAME:
					self.music_file_path = "%s/%s" % [chart_dir.get_current_dir(), file_name]
		file_name = chart_dir.get_next()
	if not self.chart_file_path or not self.music_file_path:
		return ERR_FILE_NOT_FOUND
	if not self.bg_file_path:
		self.bg_file_path = self.DEFAULT_BG_FILE_PATH
	return OK


func get_basic_info() -> Dictionary:
	var chart_file: FileAccess = FileAccess.open(self.chart_file_path, FileAccess.READ)
	var basic_info: Dictionary = {
		"song_name": "",
		"composer": "",
		"chart_designer": "",
		"illustrator": "",
		"bpm": 0
	}
	if chart_file.eof_reached():
		return basic_info
	var new_line: String = chart_file.get_line().strip_edges()
	var basic_info_single_list: PackedStringArray
	while not chart_file.eof_reached():
		if new_line.is_empty():
			new_line = chart_file.get_line().strip_edges()
			continue
		if new_line[0] == '(':
			break
		if new_line[0] == '$':
			new_line = new_line.trim_prefix('$')
			basic_info_single_list = new_line.split('=', true, 1)
			basic_info_single_list[0] = basic_info_single_list[0].strip_edges()
			basic_info_single_list[1] = basic_info_single_list[1].strip_edges()
			print("basic_info_single_list = ", basic_info_single_list)
			if basic_info_single_list[0] in ["song_name", "composer", "chart_designer", "illustrator"]:
				basic_info[basic_info_single_list[0]] = basic_info_single_list[1]
		new_line = chart_file.get_line().strip_edges()
		print("new_line = \"" + new_line + "\"")
	if new_line[0] == '(':
		new_line = new_line.strip_escapes().replace(' ', '').trim_prefix('(').left(new_line.find(')'))
		basic_info["bpm"] = float(new_line)
	return basic_info


func get_bg() -> ImageTexture:
	var bg_file = Image.new()
	bg_file.load(self.bg_file_path)
	return ImageTexture.create_from_image(bg_file)


func get_music() -> AudioStreamMP3:
	return BaseChart.load_music(self.music_file_path)
	

func _to_string() -> String:
	return "BaseChartDirReference(%s)" % get_basic_info()["song_name"]
