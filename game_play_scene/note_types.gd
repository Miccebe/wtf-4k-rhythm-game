extends Node2D

## 播放谱面写这里，实际游玩的控制流写PlayingChart脚本里

const CHART_FLOW_DISTANCE_MIN_PIXEL: float = 700.0
const NOTE_START_POSITION: Dictionary = { 
	Chart.Track.TRACK_1: Vector2(380.0, 600.0),
	Chart.Track.TRACK_2: Vector2(440.0, 600.0),
	Chart.Track.TRACK_3: Vector2(500.0, 600.0),
	Chart.Track.TRACK_4: Vector2(560.0, 600.0),
}

enum SoundType {	# 这个枚举只用于二次处理sound_list，把里面重复的音效剔除
	NULL = -1,
	TAP = 0,
	CATCH = 1,
	HOLD = 0,
	HOLD_END = 0,
}

var basic_chart_flow_speed_pixel: float
var basic_bpm: float
var fall_time_min_sec: float
var chart_flow_speed_min_pixel: float

var note_flow_info_list: Array[Dictionary] = []
var note_flow_start_time: float = 0

var current_chart_time_sec: float
var current_chart_idx: int
var chart_generate_list: Array[Array] = []
# chart_generate_list存储谱面生成列表，每一项的格式为[<index>, <time>, <isGenerated>]
var chart_note_node_list: Array[Polygon2D] = []

var current_sound_time_sec: float
var current_sound_idx: int
var sound_list: Array[Array] = []
# sound_list存储音效播放列表，每一项的格式为[<SoundType>, <time>, <isGenerated>]

# 这三个参数只对谱面播放生效，对正解音没影响
var play_wait_time: float
var is_waiting: bool = false
var current_wait_time: float

var is_playing: bool = false

var note_display_script: Script = preload("res://game_play_scene/note_display.gd")
var hit_sound_play_script: Script = preload("res://game_play_scene/hit_sound_play.gd")
@onready var hit_sounds_node: Node = $"../HitSounds"

var is_paused: bool = false

signal send_time_current(_time_current: float)
signal test_label(_text: String)


func _ready() -> void:
	# 读取配置
	self.chart_flow_speed_min_pixel = self.get_flow_speed_pixel_from_settings(
		$"/root/GamePlayScene/Buttons/SettingsScene".get_node("Control/GameSettings/ChartFlowSpeed").value_min
	)


func _physics_process(delta: float) -> void:
	if self.is_paused:
		return
	
	# 处理Note下落
	self.chart_note_node_list = self.chart_note_node_list.filter(func(a): return a != null)
	for i in range(len(self.chart_note_node_list)):
		if self.chart_note_node_list[i].is_play_started and not self.chart_note_node_list[i].is_paused:
			self.chart_note_node_list[i].set_current_position()
		if self.chart_note_node_list[i].position.y >= self.chart_note_node_list[i].out_of_screen_position_pixel:
			self.chart_note_node_list[i].queue_free()
	
	if self.is_waiting and self.is_playing:		 # 如果仍在等待谱面播放
		self.current_wait_time += delta
		if self.current_wait_time >= self.play_wait_time:
			self.is_waiting = false
	if ( 	   # 如果等待谱面播放已结束
		not self.is_waiting and self.is_playing 
		and self.current_chart_idx <= len(self.chart_generate_list) - 2		# 保证下标还在正常的列表范围内
	):
		if (	# 如果当前索引的note还未生成，并且当前时间在索引的时间范围内
			not self.chart_generate_list[self.current_chart_idx][2] 
			and self.chart_generate_list[self.current_chart_idx][1] <= self.current_chart_time_sec
			and self.current_chart_time_sec < self.chart_generate_list[self.current_chart_idx + 1][1]
		):
			self.create_note_display(self.chart_generate_list[self.current_chart_idx][0])
			self.chart_generate_list[self.current_chart_idx][2] = true
		elif (   # 如果当前索引的note还未生成，并且当前时间不在索引的时间范围内
			not self.chart_generate_list[self.current_chart_idx][2] 
			and not (self.chart_generate_list[self.current_chart_idx][1] <= self.current_chart_time_sec
				and self.current_chart_time_sec < self.chart_generate_list[self.current_chart_idx + 1][1]
			)
		):
			for i in range(self.current_chart_idx - 1, -1, -1):	  # 往前查找到第一个已生成的note
				if not self.chart_generate_list[i][2]:   	# 如果查找到的note也还未生成
					self.create_note_display(self.chart_generate_list[i][0])
					self.chart_generate_list[i][2] = true
				elif (		# 如果查找到的note已生成，且在时间的索引范围内，则停止查找
					self.chart_generate_list[i][2]
					and self.chart_generate_list[i][1] <= self.current_chart_time_sec
					and self.current_chart_time_sec < self.chart_generate_list[i + 1][1]
				):
					break
			if self.chart_generate_list[self.current_chart_idx][1] < self.current_chart_time_sec:   # 往后查找之前，先确认当前时间有没有必要往后查找
				for i in range(self.current_chart_idx + 1, len(self.chart_generate_list) - 1):   # 往后查找到第一个在时间范围内的note
					if (	  # 如果查找到了在时间范围内的note，则停止查找，并且如果该位置note未生成，则生成note，并更新下标
						self.chart_generate_list[i][1] <= self.current_chart_time_sec
						and self.current_chart_time_sec < self.chart_generate_list[i + 1][1]
					):
						self.current_chart_idx = i
						if not self.chart_generate_list[i][2]:
							self.create_note_display(self.chart_generate_list[i][0])
							self.chart_generate_list[i][2] = true
						break
					elif self.chart_generate_list[i][2] == false:
						self.chart_generate_list[i][2] = true
						self.create_note_display(self.chart_generate_list[i][0])
					if i == len(self.chart_generate_list) - 2:	# 如果已经索引到列表尾了，就直接赋值
						self.current_chart_idx = i
						if not self.chart_generate_list[self.current_chart_idx][2]:
							self.create_note_display(self.chart_generate_list[self.current_chart_idx][0])
							self.chart_generate_list[self.current_chart_idx][2] = true
		elif (	  # 如果当前索引的note已生成，且当前时间不在索引的时间范围内
			self.chart_generate_list[self.current_chart_idx][2] 
			and not (self.chart_generate_list[self.current_chart_idx][1] <= self.current_chart_time_sec
				and self.current_chart_time_sec < self.chart_generate_list[self.current_chart_idx + 1][1]
			)
		):
			for i in range(self.current_chart_idx + 1, len(self.chart_generate_list) - 1):   # 往后查找到第一个在时间范围内的note
				if (
					self.chart_generate_list[i][1] <= self.current_chart_time_sec
					and self.current_chart_time_sec < self.chart_generate_list[i + 1][1]
				):
					self.current_chart_idx = i
					if not self.chart_generate_list[i][2]:
						self.create_note_display(self.chart_generate_list[i][0])
						self.chart_generate_list[i][2] = true
					break
				elif self.chart_generate_list[i][2] == false:
					self.chart_generate_list[i][2] = true
					self.create_note_display(self.chart_generate_list[i][0])
				if i == len(self.chart_generate_list) - 2:	# 如果已经索引到列表尾了，就直接赋值
					self.current_chart_idx = i
					if not self.chart_generate_list[self.current_chart_idx][2]:
						self.create_note_display(self.chart_generate_list[self.current_chart_idx][0])
						self.chart_generate_list[self.current_chart_idx][2] = true
		self.current_chart_time_sec += delta
	
	if (	    # 如果已开始播放正解音		下面的逻辑和上面完全一样
		self.is_playing
		and self.current_sound_idx <= len(self.sound_list) - 2	   # 保证下标位置在正常范围内
	):
		if (	# 如果当前索引的音效还未播放，并且当前时间在索引的时间范围内
			not self.sound_list[self.current_sound_idx][2] 
			and self.sound_list[self.current_sound_idx][1] <= self.current_sound_time_sec
			and self.current_sound_time_sec < self.sound_list[self.current_sound_idx + 1][1]
		):
			self.note_play_sound(self.sound_list[self.current_sound_idx][0])
			self.sound_list[self.current_sound_idx][2] = true
		elif (   # 如果当前索引的音效还未播放，并且当前时间不在索引的时间范围内
			not self.sound_list[self.current_sound_idx][2] 
			and not (self.sound_list[self.current_sound_idx][1] <= self.current_sound_time_sec
				and self.current_sound_time_sec < self.sound_list[self.current_sound_idx + 1][1]
			)
		):
			for i in range(self.current_sound_idx - 1, -1, -1):	  # 往前查找到第一个已播放的音效
				if not self.sound_list[i][2]:   	# 如果查找到的音效也还未播放
					self.note_play_sound(self.sound_list[i][0])
					self.sound_list[i][2] = true
				elif (		# 如果查找到的音效已播放，且在时间的索引范围内，则停止查找
					self.sound_list[i][2]
					and self.sound_list[i][1] <= self.current_sound_time_sec
					and self.current_sound_time_sec < self.sound_list[i + 1][1]
				):
					break
			if self.sound_list[self.current_sound_idx][1] < self.current_sound_time_sec:   # 往后查找之前，先确认当前时间有没有必要往后查找
				for i in range(self.current_sound_idx + 1, len(self.sound_list) - 1):   # 往后查找到第一个在时间范围内的音效
					if (	  # 如果查找到了在时间范围内的音效，则停止查找，并且如果该位置音效未播放，则播放音效，并更新下标
						self.sound_list[i][1] <= self.current_sound_time_sec
						and self.current_sound_time_sec < self.sound_list[i + 1][1]
					):
						self.current_sound_idx = i
						if not self.sound_list[i][2]:
							self.note_play_sound(self.sound_list[i][0])
							self.sound_list[i][2] = true
						break
					elif self.sound_list[i][2] == false:
						self.sound_list[i][2] = true
						self.note_play_sound(self.sound_list[i][0])
					if i == len(self.sound_list) - 2:	# 如果已经索引到列表尾了，就直接赋值
						self.current_sound_idx = i
						if not self.sound_list[self.current_sound_idx][2]:
							self.note_play_sound(self.sound_list[self.current_sound_idx][0])
							self.sound_list[self.current_sound_idx][2] = true
		elif (	  # 如果当前索引的音效已播放，且当前时间不在索引的时间范围内
			self.sound_list[self.current_sound_idx][2] 
			and not (self.sound_list[self.current_sound_idx][1] <= self.current_sound_time_sec
				and self.current_sound_time_sec < self.sound_list[self.current_sound_idx + 1][1]
			)
		):
			for i in range(self.current_sound_idx + 1, len(self.sound_list) - 1):   # 往后查找到第一个在时间范围内的音效
				if (
					self.sound_list[i][1] <= self.current_sound_time_sec
					and self.current_sound_time_sec < self.sound_list[i + 1][1]
				):
					self.current_sound_idx = i
					if not self.sound_list[i][2]:
						self.note_play_sound(self.sound_list[i][0])
						self.sound_list[i][2] = true
					break
				elif self.sound_list[i][2] == false:
					self.sound_list[i][2] = true
					self.note_play_sound(self.sound_list[i][0])
				if i == len(self.sound_list) - 2:	# 如果已经索引到列表尾了，就直接赋值
					self.current_sound_idx = i
					if not self.sound_list[self.current_sound_idx][2]:
						self.note_play_sound(self.sound_list[self.current_sound_idx][0])
						self.sound_list[self.current_sound_idx][2] = true
		self.current_sound_time_sec += delta
		self.send_time_current.emit(self.current_sound_time_sec)
		self.test_label.emit("current_chart_time_sec = \n%.3f\ncurrent_sound_time_sec = \n%.3f" % [self.current_chart_time_sec, self.current_sound_time_sec])
		
		

func start_playing_chart(_offset: float) -> void:
	## 这个_offset不计入note下落时间
	self.current_chart_time_sec = min(self.get_note_flow_start_time(), 0) + _offset
	self.current_chart_idx = 0
	self.current_sound_time_sec = min(self.get_note_flow_start_time(), 0)
	self.current_sound_idx = 0
	for i in range(len(PlayingChart.playing_chart.chart)):
		if PlayingChart.playing_chart.chart[i] is Chart.Note and PlayingChart.playing_chart.chart[i] is not Chart.EmptyNote:
			self.chart_generate_list.append([i, self.note_flow_info_list[i]["flow_speed_list"][0][1], false])
		# sound_list添加元素
		if PlayingChart.playing_chart.chart[i] is Chart.Note:
			if PlayingChart.playing_chart.chart[i] is Chart.HoldNote:
				self.sound_list.append(["Hold", PlayingChart.playing_chart.chart[i].note_judgement_time, false])
				self.sound_list.append(["HoldEnd", PlayingChart.playing_chart.chart[i].hold_end_judgement_time, false])
			elif PlayingChart.playing_chart.chart[i] is Chart.EachNote:
				for j in PlayingChart.playing_chart.chart[i].note_list:
					if j is Chart.HoldNote:
						self.sound_list.append(["Hold", j.note_judgement_time, false])
						self.sound_list.append(["HoldEnd", j.hold_end_judgement_time, false])
					else:
						self.sound_list.append([
							"Tap" if j is Chart.TapNote else "Catch",
							j.note_judgement_time,
							false,
						])
			elif PlayingChart.playing_chart.chart[i] is not Chart.EmptyNote:
				self.sound_list.append([
					"Tap" if PlayingChart.playing_chart.chart[i] is Chart.TapNote else "Catch",
					PlayingChart.playing_chart.chart[i].note_judgement_time,
					false,
				])
	self.sound_list.sort_custom(func(a, b): return a[1] < b[1])  # 基于第二项也就是正解时间升序排序
	# 把sound_list中时间相同、音效类型也相同的元素只保留一个
	var filtered_sound_list: Array[Array] = []
	var sound_string_to_sound_type = func(_sound_string: String) -> SoundType:
		if _sound_string == "Tap":
			return SoundType.TAP
		elif _sound_string == "Catch":
			return SoundType.CATCH
		elif _sound_string == "Hold":
			return SoundType.HOLD
		elif _sound_string == "HoldEnd":
			return SoundType.HOLD_END
		return SoundType.NULL
	for i in self.sound_list:
		var is_element_duplicated: bool = false
		for j in range(len(filtered_sound_list) - 1, -1, -1):
			if (
				sound_string_to_sound_type.call(filtered_sound_list[j][0]) == sound_string_to_sound_type.call(i[0])
				and is_equal_approx(filtered_sound_list[j][1], i[1])
			):
				is_element_duplicated = true
				break
		if not is_element_duplicated:
			filtered_sound_list.append(i)
	self.sound_list = filtered_sound_list
	self.chart_generate_list.append([null, INF, true])
	self.sound_list.append([null, INF, true])
	self.is_waiting = true
	self.is_playing = true
	LogScript.write_log(["Chart Generate List has generated: ", self.chart_generate_list])
	LogScript.write_log(["Sound List has generated: ", self.sound_list])


func _on_chart_flow_speed_changed(changed_config: Settings) -> void:
	self.basic_chart_flow_speed_pixel = self.get_flow_speed_pixel_from_settings(changed_config.chart_flow_speed)
	print("_on_chart_flow_speed_changed: self.basic_chart_flow_speed_pixel = ", self.basic_chart_flow_speed_pixel)


func get_flow_speed_pixel_from_settings(_flow_speed: float) -> float:
	# 下面这个是流速(pixels/sec)计算公式，1.0 对应 50 pixels/sec，16.0 对应 2240 pixels/sec，大于16.0也就是Sonic速对应 10000 pixels/sec
	return 50.0 + (_flow_speed - 1.0) * 146.0 if _flow_speed <= 16.0 else 10000.0


func get_flow_speed_pixel_from_bpm(_bpm: float) -> float:
	return self.basic_chart_flow_speed_pixel * (_bpm / self.basic_bpm)


func initial_chart_from_playing_chart() -> void:
	# 计算最小下落时间
	self.chart_note_node_list = []
	var bpm_min: float = INF
	for i in PlayingChart.playing_chart.chart:
		if i is Chart.BPM:
			if i.bpm < bpm_min and i.bpm > 0:
				bpm_min = i.bpm
	# speed = chart_flow_speed_min_pixel * (bpm_min / basic_bpm)
	# time = CHART_FLOW_DISTANCE_MIN_PIXEL / speed
	self.fall_time_min_sec = self.CHART_FLOW_DISTANCE_MIN_PIXEL / (self.chart_flow_speed_min_pixel * (bpm_min / self.basic_bpm))
	print("fall_time_min_sec = ", self.fall_time_min_sec)
	for i in range(len(PlayingChart.playing_chart.chart)):
		self.note_flow_info_list.append(self.get_note_flow_info(i))
	LogScript.write_log(["Initialize in note_types.gd has completed, and Note Flow Info List has generated: ", self.note_flow_info_list])
	

func get_note_flow_info(_idx: int) -> Dictionary:
	## 函数输入后会进行一次类型检查，如果检查到的类型不是Tap, Catch, Hold, Each，那么返回空字典
	## 返回这样一个字典：{ "position": <Vector2>, "flow_speed_list": [<FlowSpeedList>], ... }
	## 其中<FlowSpeedList>是一个流速与对应时间的列表，格式为[<FlowSpeedPixel>, <Time>]
	## 如果类型是Hold，那么字典会多一个键值对，为 "hold_length": <HoldLength>
	## 如果类型是Each，那么字典会多一个键值对，为 "hold_length_dict": { <index>: <HoldLength>, ... }
	## 且"position"的值会变成一个Vector2的列表

	var note_self: Chart.ChartElement = PlayingChart.playing_chart.chart[_idx]
	var note_flow_info: Dictionary = {}
	if note_self is not Chart.Note or note_self is Chart.EmptyNote:
		return note_flow_info
	var flow_speed_list: Array[Array] = []
	var _position = (		# 计算Note下落终点，便于后续基于下落终点计算起点
		self.NOTE_START_POSITION[note_self.track] if note_self is not Chart.EachNote
		else note_self.note_list.map(
			func(_note): return (
				self.NOTE_START_POSITION[_note.track]
			)
		)
	)
	var fall_time_sec: float = self.fall_time_min_sec
	var chart_slice: Array[Chart.ChartElement] = PlayingChart.playing_chart.chart.slice(0, _idx)
	chart_slice.reverse()
	for i in chart_slice:	 # 搜索Note下落到判定线之前的BPM变化
		fall_time_sec -= i.note_duration
		if i is Chart.BPM:
			if fall_time_sec <= 0:	  # 如果已经满足最小生成时间的高度
				flow_speed_list.append([
					self.get_flow_speed_pixel_from_bpm(i.bpm),
					note_self.note_judgement_time - self.fall_time_min_sec,
				])
				break
			elif i == chart_slice[-1]:	 # 如果已经遍历到列表尾（谱面元素列表头）了，fall_time_sec还大于0，此时就要基于basic_bpm计算了
				flow_speed_list.append([
					self.get_flow_speed_pixel_from_bpm(self.basic_bpm),
					note_self.note_judgement_time - self.fall_time_min_sec,	
				])
			else:
				flow_speed_list.append([
					self.get_flow_speed_pixel_from_bpm(i.bpm), 
					i.note_judgement_time,
				])
	flow_speed_list.reverse()     # 前面用的append，列表元素顺序和期望的是反过来的，所以要reverse一下
	var flow_speed_list_till_judgement_time: Array[Array] = flow_speed_list.duplicate()
	for i in PlayingChart.playing_chart.chart.slice(_idx + 1):	  # 额外计算Note已经下落到判定线下面时的流速变化，防止长Hold在变BPM时穿帮
		if i is Chart.BPM:
			flow_speed_list.append([
				self.get_flow_speed_pixel_from_bpm(i.bpm),
				i.note_judgement_time,
			])
	flow_speed_list.append([flow_speed_list[-1][0], INF])	 # 多一个流速与前一项相同，时间为INF的元素，让Note没有下落时间限制，同时防止下标越界
	note_flow_info["flow_speed_list"] = flow_speed_list

	# 计算Note下落起始坐标，也就是速度*时间
	flow_speed_list_till_judgement_time.append([flow_speed_list[-1][0], note_self.note_judgement_time])	   # 多一个无意义元素，防止遍历列表时下标越界
	for i in range(len(flow_speed_list_till_judgement_time) - 1):
		var move_distance: float = (
			(flow_speed_list_till_judgement_time[i + 1][1] - flow_speed_list_till_judgement_time[i][1]) 
			* flow_speed_list_till_judgement_time[i][0]
		)
		if note_self is not Chart.EachNote:
			_position.y -= move_distance
		else:
			var new_position: Array[Vector2]
			for j in _position:
				new_position.append(Vector2(j.x, j.y - move_distance))
			_position = new_position
	note_flow_info["position"] = _position

	var get_hold_length = func(_hold_note: Chart.HoldNote) -> float:	# 计算Hold长度
		const HOLD_LENGTH_MIN_PIXEL: float = 10.0

		var hold_length: float = 0.0
		var hold_duration: float = _hold_note.hold_duration
		var last_bpm_judgement_time: float = _hold_note.note_judgement_time
		var last_bpm: float
		for i in chart_slice:
			if i is Chart.BPM:
				last_bpm = i.bpm
				break
		for i in PlayingChart.playing_chart.chart.slice(_idx + 1):
			hold_duration -= i.note_duration
			if hold_duration <= 0.0:
				hold_length += (
					(_hold_note.hold_end_judgement_time - last_bpm_judgement_time)
					* self.get_flow_speed_pixel_from_bpm(last_bpm)
				)
				break
			if i is Chart.BPM:
				hold_length += (
					(i.note_judgement_time - last_bpm_judgement_time)
					* self.get_flow_speed_pixel_from_bpm(last_bpm)
				)
				last_bpm_judgement_time = i.note_judgement_time
				last_bpm = i.bpm
		if hold_duration > 0.0:
			hold_length += _hold_note.hold_duration * self.get_flow_speed_pixel_from_bpm(last_bpm)
		return max(hold_length, HOLD_LENGTH_MIN_PIXEL)

	if note_self is Chart.HoldNote:    # 如果类型是Hold
		note_flow_info["hold_length"] = get_hold_length.call(note_self)
	elif note_self is Chart.EachNote:  # 如果类型是Each
		var hold_length_dict = {}
		for i in range(len(note_self.note_list)):
			if note_self.note_list[i] is Chart.HoldNote:
				hold_length_dict[i] = get_hold_length.call(note_self.note_list[i])
		note_flow_info["hold_length_dict"] = hold_length_dict
	return note_flow_info


func get_each_note_flow_info(_note_flow_info: Dictionary, _idx: int) -> Dictionary:
	## 为Each的指定Note单独返回一个note_flow_info
	if _note_flow_info["hold_length_dict"].has(_idx):
		return {
			"position": _note_flow_info["position"][_idx],
			"flow_speed_list": _note_flow_info["flow_speed_list"],
			"hold_length": _note_flow_info["hold_length_dict"][_idx],
		}
	else:
		return {
			"position": _note_flow_info["position"][_idx],
			"flow_speed_list": _note_flow_info["flow_speed_list"],
		}


func get_note_flow_start_time() -> float:
	for i in self.note_flow_info_list:
		if i.has("flow_speed_list"):
			return i["flow_speed_list"][0][1]
	return 0.0


func create_note_display(_idx: int) -> void:
	var _note: Chart.ChartElement = PlayingChart.playing_chart.chart[_idx]
	var _note_flow_info: Dictionary = self.note_flow_info_list[_idx]
	LogScript.write_log(["Created note: ", _note, ", note flow info: ", _note_flow_info, ", index: ", _idx, ", current chart time: ", self.current_chart_time_sec])
	if _note is Chart.EmptyNote:
		return
	elif _note is not Chart.EachNote:
		var note_type: String
		if _note is Chart.TapNote:
			note_type = "Tap"
		elif _note is Chart.CatchNote:
			note_type = "Catch"
		elif _note is Chart.HoldNote:
			note_type = "Hold"
		var template_node: Polygon2D = get_node("Track%s/%sDisplay" % [_note.track, note_type])
		var copy_node: Polygon2D = template_node.duplicate()
		self.add_child(copy_node)
		copy_node.set_script(note_display_script)
		copy_node.initial(_idx, _note, _note_flow_info)
		copy_node.start_play()
		self.chart_note_node_list.append(copy_node)
	elif _note is Chart.EachNote:
		for i in range(len(_note.note_list)):
			var note_type: String
			if _note.note_list[i] is Chart.TapNote:
				note_type = "Tap"
			elif _note.note_list[i] is Chart.CatchNote:
				note_type = "Catch"
			elif _note.note_list[i] is Chart.HoldNote:
				note_type = "Hold"
			var template_node: Polygon2D = get_node("Track%s/%sDisplay" % [_note.note_list[i].track, note_type])
			var copy_node: Polygon2D = template_node.duplicate()
			self.add_child(copy_node)
			copy_node.set_script(self.note_display_script)
			copy_node.initial(_idx, _note.note_list[i], self.get_each_note_flow_info(_note_flow_info, i))
			copy_node.start_play()
			self.chart_note_node_list.append(copy_node)


func note_play_sound(_type: String) -> void:
	# _type参数只能是"Tap"/"Catch"/"Hold"/"HoldEnd"
	LogScript.write_log(["Played sound, type: ", _type,", current chart time: ", self.current_chart_time_sec])
	var template_node: AudioStreamPlayer = get_node("../HitSounds/%s" % _type)
	var copy_node: AudioStreamPlayer = template_node.duplicate()
	self.hit_sounds_node.add_child(copy_node)
	copy_node.set_script(self.hit_sound_play_script)
	copy_node.play()


func _on_paused() -> void:
	self.is_paused = true


func _on_continued() -> void:
	self.is_paused = false
