extends Node

signal chart_playing_started(_chart: Chart)


var playing_chart: Chart = Chart.new()
var chart_dir_reference: BaseChartDirReference

## 实际游玩时的控制流写在这

func load_chart(_target_chart: BaseChartDirReference) -> Error:
	self.chart_dir_reference = _target_chart
	var history_playing_chart: Chart = self.playing_chart
	var loading_error: Error = self.playing_chart.load_chart_from_reference(_target_chart)
	if loading_error:
		LogScript.write_log(["Load Error: PlayingChart.playing_chart = ", self.playing_chart])
		self.playing_chart = history_playing_chart
		return loading_error
	return OK


func play_chart() -> void:
	emit_signal("chart_playing_started", self.playing_chart)
