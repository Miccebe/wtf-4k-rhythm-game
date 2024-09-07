class_name ChartLoader

var charts: Array[BaseChartDirReference] = []


func load_charts() -> void:
	charts = []
	var executable_path: String = OS.get_executable_path()
	executable_path = executable_path.left(executable_path.rfind("/") + 1)
	executable_path = "res://"		##### 这行记得注释掉
	var chart_dir: DirAccess = DirAccess.open("%slevels" % executable_path)
	if not chart_dir:
		chart_dir.make_dir("%slevels" % executable_path)
	chart_dir.list_dir_begin()
	var file_name: String = chart_dir.get_next()
	while file_name:
		if chart_dir.current_is_dir():
			var new_chart: BaseChartDirReference = BaseChartDirReference.new()
			if not new_chart.open("%s/%s" % [chart_dir.get_current_dir(), file_name]):
				charts.append(new_chart)
		file_name = chart_dir.get_next()


func _to_string() -> String:
	return str(self.charts)
