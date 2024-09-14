extends Node2D

var is_basic_info_available: bool = false

const NO_MORE_CHARTS = "没有更多谱面啦！"
const NO_CHART_DETECTED = "似乎还没有导入任何谱面呢！"
const NO_CHART_SELECTED = "似乎还没有选择任何谱面呢！"


func _ready() -> void:
	if not self.is_basic_info_available:
		self.set_unavailable(self.NO_CHART_DETECTED)


func _on_item_selected(idx: int) -> void:
	print("_on_item_selected runned")
	var songs_list: Array[BaseChartDirReference] = $"../SongsListContent".songs_list.charts
	if idx == len(songs_list):
		self.is_basic_info_available = false
		if len(songs_list) == 0:
			self.set_unavailable(NO_CHART_DETECTED)
		else:
			self.set_unavailable(NO_MORE_CHARTS)
		return
	else:
		self.is_basic_info_available = true	
	var song_selected: BaseChartDirReference = songs_list[idx]
	var basic_info: Dictionary = song_selected.get_basic_info()
	print("_on_item_selected: basic_info = ", basic_info)
	var bg: ImageTexture = song_selected.get_bg()
	var music: AudioStreamMP3 = song_selected.get_music()
	var info_text: String = (
		"Title: %s\nComposer: %s\nIllustrator: %s\nChart Designer: %s\nBPM: %s" %
		[
			basic_info["song_name"],
			basic_info["composer"],
			basic_info["illustrator"],
			basic_info["chart_designer"],
			(
				str(int(basic_info["bpm"])) if basic_info["bpm"] == int(basic_info["bpm"]) 
				else "%.2f" % basic_info["bpm"]
			),
		]
	)
	$BasicInfo.text = info_text
	$Bg.texture = bg
	$Music.stream = music
	$Music.set_preview_clip(basic_info["preview_clip"])
	$Music.time_after_fading_out = 0
	$Music.is_fading_out = false
	$"../StartGameButton".emit_signal("enable")


#func _on_item_unselected(_at_position: Vector2, _mouse_button_index: int) -> void:
	#LogScript.write_log(["_on_item_unselected runned"])
	#self.is_basic_info_available = false
	#self.set_unavailable(NO_CHART_SELECTED)


func set_unavailable(unavailable_info: String) -> void:
	$BasicInfo.text = unavailable_info
	$Bg.texture = BaseChart.load_bg(BaseChartDirReference.DEFAULT_BG_FILE_PATH)
	$Music.stop()
	$"../StartGameButton".emit_signal("disable")
	
