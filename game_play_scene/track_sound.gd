extends AudioStreamPlayer

var is_paused: bool
var track_sound_play_script: Script = preload("res://game_play_scene/hit_sound_play.gd")
@onready var hit_sound_node: Node = $".."


func _ready() -> void:
	is_paused = false


func _process(_delta: float) -> void:
	if is_paused:
		return

	if Input.is_action_just_pressed("track_1"):
		play_sound()
	if Input.is_action_just_pressed("track_2"):
		play_sound()
	if Input.is_action_just_pressed("track_3"):
		play_sound()
	if Input.is_action_just_pressed("track_4"):
		play_sound()


func _on_paused() -> void:
	is_paused = true


func _on_continued() -> void:
	is_paused = false
	

func play_sound() -> void:
	var self_node: AudioStreamPlayer = self
	var copy_node: AudioStreamPlayer = self_node.duplicate()
	self.hit_sound_node.add_child(copy_node)
	copy_node.set_script(self.track_sound_play_script)
	copy_node.play()
