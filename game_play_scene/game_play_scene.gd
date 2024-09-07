extends Node2D


func _init() -> void:
	pass


func _ready() -> void:
	PlayingChart.connect("chart_playing_started", $Background/ChartInfo/Music.play)


func _on_keybind_changed(changed_config: Settings) -> void:
	var input_event: InputEventKey = InputEventKey.new()
	input_event.keycode = changed_config.track1_key
	InputMap.action_erase_events("track_1")
	InputMap.action_add_event("track_1", input_event)
	input_event = InputEventKey.new()
	input_event.keycode = changed_config.track2_key
	InputMap.action_erase_events("track_2")
	InputMap.action_add_event("track_2", input_event)
	input_event = InputEventKey.new()
	input_event.keycode = changed_config.track3_key
	InputMap.action_erase_events("track_3")
	InputMap.action_add_event("track_3", input_event)
	input_event = InputEventKey.new()
	input_event.keycode = changed_config.track4_key
	InputMap.action_erase_events("track_4")
	InputMap.action_add_event("track_4", input_event)
	print("_on_keybind_changed: Keybind has changed to [%s, %s, %s, %s]" % [
		OS.get_keycode_string(changed_config.track1_key),
		OS.get_keycode_string(changed_config.track2_key),
		OS.get_keycode_string(changed_config.track3_key),
		OS.get_keycode_string(changed_config.track4_key),
	])
