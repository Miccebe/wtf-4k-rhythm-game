extends Control

func _ready() -> void:
	$Button2.connect("pressed", PlayingChart.play_chart)


func _on_export_chart_button_pressed() -> void:
	var param_list: PackedStringArray = $TextEdit.text.split(",");
	var param_formatted: bool = true if param_list[0] == "true" else false
	var param_line_sep_note_time: String = param_list[1]
	var output_file: FileAccess = FileAccess.open("res://chart_output.txt", FileAccess.WRITE)
	output_file.store_string(PlayingChart.playing_chart.export_chart(param_formatted, param_line_sep_note_time))
	output_file.close()
