extends Node

## 实际游玩时的控制流写在这，播放谱面写NoteTypes节点里

const CHART_FADE_OUT_TIME_SEC: float = 5.0

enum KeyCondition {
	DOWN = 1,
	RELEASE = 0,
}

enum PressCondition {
	NONE = 0,
    HOLDING = 1,
	JUST_PRESSED = 2,
	JUST_RELEASED = 3,
}

var is_entered_game_play_scene: bool = false

var playing_chart: Chart = Chart.new()
var chart_dir_reference: BaseChartDirReference
var combo: int = 0
var note_types_node: Node2D
var music_node: AudioStreamPlayer
var global_music_offset: float = 0
var global_display_offset: float = 0
var chart_music_offset: float = 0
var user_music_offset: float = 0	# 这个设置还没做，先放着，默认为0

var is_paused: bool = false

var track1_press_previous: KeyCondition = KeyCondition.RELEASE
var track2_press_previous: KeyCondition = KeyCondition.RELEASE
var track3_press_previous: KeyCondition = KeyCondition.RELEASE
var track4_press_previous: KeyCondition = KeyCondition.RELEASE

signal send_time_total(_time_total: float)


func _physics_process(delta: float) -> void:
	if not is_entered_game_play_scene or is_paused:
		return
	
	# 检测按键输入
	var track1_press: bool = self.get_key_condition(Chart.Track.TRACK_1)
	var track2_press: bool = self.get_key_condition(Chart.Track.TRACK_2)
	var track3_press: bool = self.get_key_condition(Chart.Track.TRACK_3)
	var track4_press: bool = self.get_key_condition(Chart.Track.TRACK_4)


	



func get_key_condition(_track: Chart.Track) -> KeyCondition:
	if Input.is_action_pressed("track_%s" % _track):
		return KeyCondition.DOWN
	else:
		return KeyCondition.RELEASE


func get_press_condition(_track: Chart.Track, _current_condition: KeyCondition) -> PressCondition:
	var previous_condition: KeyCondition = (
		self.track1_press_previous if _track == Chart.Track.TRACK_1
		else self.track2_press_previous if _track == Chart.Track.TRACK_2
		else self.track3_press_previous if _track == Chart.Track.TRACK_3
		else self.track4_press_previous
    )
	if previous_condition == KeyCondition.DOWN and _current_condition == KeyCondition.RELEASE:
		return PressCondition.JUST_RELEASED
	elif previous_condition == KeyCondition.RELEASE and _current_condition == KeyCondition.DOWN:
		return PressCondition.JUST_PRESSED
	elif previous_condition == KeyCondition.RELEASE and _current_condition == KeyCondition.RELEASE:
		return PressCondition.NONE
	else:  # previous_condition == KeyCondition.DOWN and _current_condition == KeyCondition.DOWN
		return PressCondition.HOLDING


func enter_game_play_scene() -> void:
	self.is_entered_game_play_scene = true
	self.note_types_node = $"/root/GamePlayScene/ChartDisplay/NoteTypes"
	self.music_node = $"/root/GamePlayScene/Background/ChartInfo/Music"
	var pause_button_node: Button = $"/root/GamePlayScene/Buttons/PauseButton"
	pause_button_node.paused.connect(self._on_paused)
	pause_button_node.continued.connect(self._on_continued)
	self.initial_chart()


func load_chart(_target_chart: BaseChartDirReference) -> Error:
	var history_chart_dir_reference: BaseChartDirReference = self.chart_dir_reference
	var history_playing_chart: Chart = self.playing_chart
	self.chart_dir_reference = _target_chart
	var loading_error: Error = self.playing_chart.load_chart_from_reference(_target_chart)
	if loading_error:
		LogScript.write_log(["Load Error: PlayingChart.playing_chart = ", self.playing_chart])
		self.playing_chart = history_playing_chart
		self.chart_dir_reference = history_chart_dir_reference
		return loading_error
	self.chart_music_offset = self.chart_dir_reference.get_basic_info()["offset"] / 1000.0
	return OK


func initial_chart() -> void:
	note_types_node.basic_bpm = self.chart_dir_reference.get_basic_info()["bpm"]
	note_types_node.initial_chart_from_playing_chart()
	self.send_time_total.emit(self.playing_chart.chart[-1].note_judgement_time + self.CHART_FADE_OUT_TIME_SEC)


func play_chart() -> void:
	var total_offset: Array[float] = self.get_total_offset()
	music_node.start_playing(total_offset[0] - min(note_types_node.get_note_flow_start_time(), 0))
	note_types_node.start_playing_chart(total_offset[1])


func change_combo(_operation: String = "add") -> void:
	if _operation == "add":
		self.combo += 1
	elif _operation == "clear":
		self.combo = 0
	$"/root/GamePlayScene/Texts/ComboText".text = (
		"Combo\n%s" % self.combo if self.combo >= 2
		else ""
	)


func _on_offset_changed(changed_config: Settings) -> void:
	self.global_music_offset = changed_config.music_offset / 1000.0
	self.global_display_offset = changed_config.display_offset / 1000.0
	print("_on_offset_changed: self.global_music_offset = ", self.global_music_offset, 
		", self.global_display_offset = ", self.global_display_offset)


func get_total_offset() -> Array[float]:
	#	有4个延迟参数：
	#		全局音频延迟 global_music_offset
	#		全局画面延迟 global_display_offset
	#			仅影响谱面播放的延迟
	#			不影响正解音播放的延迟
	#		谱面内置音频延迟 chart_music_offset
	#		用户设定音频延迟 user_music_offset
	#	计算方法：
	#		1.把所有音频延迟加起来，得到一个总音频延迟
	#		2.如果仍存在负延迟，则把所有延迟加上这个负延迟的绝对值，得到修正后的全非负延迟
	#		3.传递参数，总音频延迟传递到音乐播放节点，全局画面延迟传递到谱面播放节点
	var total_music_offset: float = self.global_music_offset + self.chart_music_offset + self.user_music_offset
	var total_display_offset: float = self.global_display_offset
	if total_music_offset < 0:
		total_display_offset += abs(total_music_offset)
		total_music_offset = 0
	elif total_display_offset < 0:
		total_music_offset += abs(total_display_offset)
		total_display_offset = 0
	print("calc_offset: total_music_offset = ", total_music_offset, ", total_display_offset = ", total_display_offset)
	return [total_music_offset, total_display_offset]


func _on_paused() -> void:
	self.is_paused = true


func _on_continued() -> void:
	self.is_paused = false
