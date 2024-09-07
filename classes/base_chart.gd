class_name BaseChart


var chart: Chart
var music: AudioStreamMP3
var bg: ImageTexture


func load_base_chart(_chart_dir_reference: BaseChartDirReference) -> Error:
	var chart_file: FileAccess = FileAccess.open(_chart_dir_reference.chart_file_path, FileAccess.READ)
	var _chart: Chart = Chart.new()
	var try_error: Error = _chart.load_chart(chart_file.get_as_text())
	if try_error:
		return try_error
	else:
		self.chart = _chart
	self.music = load_music(_chart_dir_reference.music_file_path)
	var bg_file = Image.new()
	bg_file.load(_chart_dir_reference.bg_file_path)
	self.bg = ImageTexture.create_from_image(bg_file)
	return OK


static func load_music(_path: String) -> AudioStreamMP3:
	var _file = FileAccess.open(_path, FileAccess.READ)
	var _sound = AudioStreamMP3.new()
	_sound.data = _file.get_buffer(_file.get_length())
	return _sound


static func load_bg(_path: String) -> ImageTexture:
	var _file = Image.new()
	_file.load(_path)
	var _file_image_texture: ImageTexture = ImageTexture.create_from_image(_file)
	_file_image_texture.set_size_override(Vector2i(400, 400))
	return _file_image_texture
	
