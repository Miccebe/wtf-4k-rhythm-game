extends AudioStreamPlayer

var is_paused: bool
var track_sound_play_script: Script = preload("res://game_play_scene/track_sound_play.gd")
@onready var hit_sound_node: Node = $".."


func _ready() -> void:
	is_paused = false


func _process(delta: float) -> void:
	if is_paused:
		return
	
	if (
		Input.is_action_just_pressed("track_1") or Input.is_action_just_pressed("track_2")
		or Input.is_action_just_pressed("track_3") or Input.is_action_just_pressed("track_4")
	):
		play_sound()


func _on_pause_button_paused() -> void:
	is_paused = true


func _on_pause_button_continued() -> void:
	is_paused = false


func play_sound() -> void:
	var self_node: AudioStreamPlayer = self
	var copy_node: AudioStreamPlayer = self_node.duplicate()
	hit_sound_node.add_child(copy_node)
	copy_node.play()
	copy_node.set_script(track_sound_play_script)
	
