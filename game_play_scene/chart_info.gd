extends Node2D


func _ready() -> void:
	if $"/root/GamePlayScene".testing:
		PlayingChart.chart_dir_reference = BaseChartDirReference.new()
		PlayingChart.chart_dir_reference.bg_file_path = "res://levels/vertex/bg.png"
		PlayingChart.chart_dir_reference.chart_file_path = "res://levels/vertex/chart.txt"
		PlayingChart.chart_dir_reference.music_file_path = "res://levels/vertex/track.mp3"
	var basic_info: Dictionary = PlayingChart.chart_dir_reference.get_basic_info()
	var bg: ImageTexture = PlayingChart.chart_dir_reference.get_bg()
	var music: AudioStreamMP3 = PlayingChart.chart_dir_reference.get_music()
	$BasicInfo.text = (
		"Title: %s\nComposer: %s\nIllustrator: %s\nChart Designer: %s\nBPM: %.2f" %
		[
			basic_info["song_name"],
			basic_info["composer"],
			basic_info["illustrator"],
			basic_info["chart_designer"],
			basic_info["bpm"],
		]
	)
	$Bg.texture = bg
	$Music.stream = music
