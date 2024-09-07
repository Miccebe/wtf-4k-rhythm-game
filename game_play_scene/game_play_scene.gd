extends Node2D


func _init() -> void:
	pass
	
	
func _on_print_chart() -> void:
	print(PlayingChart.playing_chart)


func _on_print_exported_chart() -> void:
	print(PlayingChart.playing_chart.export_chart())
