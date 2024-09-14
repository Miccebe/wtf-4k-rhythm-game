class_name BaseChartDirReference

var chart_file_path: String = ""
var bg_file_path: String = ""
var music_file_path: String = ""

const CHART_FILE_NAME: String = "chart.txt"
const BG_FILE_NAME: String = "bg.png"
const MUSIC_FILE_NAME: String = "track.mp3"
const DEFAULT_BG_FILE_PATH: String = "res://images/default_bg.png"

const DEFAULT_SONG_NAME: String = "Unnamed Song"
const DEFAULT_COMPOSER: String = "Unknown Composer"
const DEFAULT_ILLUSTRATOR: String = ""
const DEFAULT_CHART_DESIGNER: String = ""
const DEFAULT_PREVIEW_CLIP: String = "0:00-0:30"


func open(_chart_dir_path: String) -> Error:
	var chart_dir: DirAccess = DirAccess.open(_chart_dir_path)
	if DirAccess.get_open_error():
		return DirAccess.get_open_error()
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
	#LogScript.write_log(["BaseChartDirReference load complete: ", self._to_string()])
	return OK


func get_basic_info() -> Dictionary:
	var chart_file: FileAccess = FileAccess.open(self.chart_file_path, FileAccess.READ)
	var basic_info: Dictionary = {
		"song_name": self.DEFAULT_SONG_NAME,
		"composer": self.DEFAULT_COMPOSER,
		"chart_designer": self.DEFAULT_CHART_DESIGNER,
		"illustrator": self.DEFAULT_ILLUSTRATOR,
		"preview_clip": self.DEFAULT_PREVIEW_CLIP,
		"offset": 0.0,
		"bpm": 0.0,
	}
	if chart_file.eof_reached():
		return basic_info
	var new_line: String = chart_file.get_line().strip_edges()
	var basic_info_single_list: PackedStringArray
	var is_bpm_read: bool = false
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
			if basic_info_single_list[0] in ["song_name", "composer", "chart_designer", "illustrator", "preview_clip"]:
				basic_info[basic_info_single_list[0]] = basic_info_single_list[1]
			elif basic_info_single_list[0] in ["offset", "bpm"]:
				if basic_info_single_list[0] == "bpm":
					is_bpm_read = true
				basic_info[basic_info_single_list[0]] = float(basic_info_single_list[1])
		new_line = chart_file.get_line().strip_edges()
	if new_line[0] == '(' and not is_bpm_read:
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
