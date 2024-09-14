extends Polygon2D

# 临时Note显示节点的脚本

const CHART_FLOW_END_POSITION_PIXEL: float = 600.0

var idx: int
var note: Chart.Note
var note_initial_position: Vector2
var note_flow_info: Dictionary
## 是一个字典：{ "position": <Vector2>, "flow_speed_list": [<FlowSpeedList>], ... }
## 其中<FlowSpeedList>是一个流速与对应时间的列表，格式为[<FlowSpeedPixel>, <Time>]
## 如果类型是Hold，那么字典会多一个键值对，为 "hold_length": <HoldLength>
var note_types_node: Node2D

var out_of_screen_position_pixel: float  # = 700.0	此参数在绑定的是Hold时会改变

var is_paused: bool
var is_play_started: bool


func _init() -> void:
	self.visible = false
	self.is_paused = false
	self.is_play_started = false
	$"/root/GamePlayScene/Buttons/PauseButton".paused.connect(self._on_paused)
	$"/root/GamePlayScene/Buttons/PauseButton".continued.connect(self._on_continued)
	self.out_of_screen_position_pixel = 700.0
	self.note_types_node = $".."

	
#func _physics_process(_delta: float) -> void:
#	print("note_display: _process")
#	if self.is_play_started and not self.is_paused:
#		self.set_current_position()
#	if self.position.y >= self.out_of_screen_position_pixel:
#		self.queue_free()


func initial(_idx: int, _note: Chart.Note, _note_flow_info: Dictionary) -> void:
	self.idx = _idx
	self.note = _note
	self.note_flow_info = _note_flow_info
	self.position = _note_flow_info["position"]
	self.note_initial_position = self.position
	if self.note is Chart.HoldNote:
		self.polygon[0].y = -_note_flow_info["hold_length"]
		self.polygon[1].y = -_note_flow_info["hold_length"]
		self.out_of_screen_position_pixel += _note_flow_info["hold_length"]
	#print("initial: self.idx = ", self.idx, ", self.position = ", self.position)


func _on_paused() -> void:
	self.is_paused = true


func _on_continued() -> void:
	self.is_paused = false


func start_play() -> void:
	self.is_play_started = true
	self.visible = true


func set_current_position() -> void:
	var current_time_sec = self.note_types_node.current_chart_time_sec
	var note_move_distance: float = 0
	for i in range(len(self.note_flow_info["flow_speed_list"]) - 1):  # 寻找当前的音符时间在列表的哪个位置
		if (
			self.note_flow_info["flow_speed_list"][i][1] <= current_time_sec
			and current_time_sec < self.note_flow_info["flow_speed_list"][i + 1][1]
		):
			note_move_distance += (
				(current_time_sec - self.note_flow_info["flow_speed_list"][i][1])
				* self.note_flow_info["flow_speed_list"][i][0]
			)
			break
		note_move_distance += (
			self.note_flow_info["flow_speed_list"][i][0] 
			* (self.note_flow_info["flow_speed_list"][i + 1][1] - self.note_flow_info["flow_speed_list"][i][1])
		)
	self.position.y = self.note_initial_position.y + note_move_distance
