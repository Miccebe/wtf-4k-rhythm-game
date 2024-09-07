extends Label

# 下面两个变量单位是秒
var time_current: float
var time_total: float


func _ready() -> void:
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
	var time_hour: int = int(_time) / 3600
	var time_minute: int = int(_time) % 3600 / 60
	var time_second: int = int(_time) % 60
	if time_hour:
		return "%02d:%02d:%02d" % [time_hour, time_minute, time_second]
	else:
		return "%02d:%02d" % [time_minute, time_second]
	

func _on_get_time_total(_time_total: float) -> void:
	self.time_total = _time_total


func _on_get_time_current(_time_current: float) -> void:
	self.time_current = _time_current
