extends Node


var playing_chart: Chart = Chart.new()

## 实际游玩时的控制流写在这

func load_chart(_target_chart: BaseChartDirReference) -> Error:
	var history_playing_chart: Chart = self.playing_chart
	var loading_error: Error = self.playing_chart.load_chart_from_reference(_target_chart)
	if loading_error:
		print("Load Error: PlayingChart.playing_chart = ", self.playing_chart)
		self.playing_chart = history_playing_chart
		return loading_error
	return OK
