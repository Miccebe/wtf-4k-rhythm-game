extends Label

# 下面两个变量单位是秒
var time_current: float
var time_total: float


func _ready() -> void:
	PlayingChart.send_time_total.connect(self._on_get_time_total)	  ## 神秘现象之这里连不上信号，得去PlayingChart里连
	$"/root/GamePlayScene/ChartDisplay/NoteTypes".send_time_current.connect(self._on_get_time_current)
	self.time_current = 0.0
	self.time_total = 0.0


func _physics_process(_delta: float) -> void:
	ScoreStat.get_current_accuracy()
	self.text = ('Accuracy %.2f%%\nPerfect  %s\nGreat    %s\nEarly    %s\nLate     %s\nMiss     %s\n\nTime  %s/%s' % 
		[
			ScoreStat.accuracy * 100,
			ScoreStat.perfect_count,
			ScoreStat.great_count,
			ScoreStat.early_great_count,
			ScoreStat.late_great_count,
			ScoreStat.miss_count,
			get_formatted_time(self.time_current),
			get_formatted_time(self.time_total),
		]
	)


func get_formatted_time(_time: float) -> String:
	## 转化为hh:mm:ss.millisec的格式并返回
	var time_minus: String = "-" if _time < 0 else ""
	var time_hour: int = int(abs(_time)) / 3600
	var time_minute: int = int(abs(_time)) % 3600 / 60
	var time_second: int = int(abs(_time)) % 60
	var time_millisec: int = int(abs(_time) * 1000) % 1000
	if time_hour:
		return "%s%02d:%02d:%02d.%0-3d" % [time_minus, time_hour, time_minute, time_second, time_millisec]
	else:
		return "%s%02d:%02d.%0-3d" % [time_minus, time_minute, time_second, time_millisec]
	

func _on_get_time_total(_time_total: float) -> void:
	self.time_total = _time_total
	print("_on_get_time_total: self.time_total = ", self.time_total)


func _on_get_time_current(_time_current: float) -> void:
	self.time_current = _time_current
