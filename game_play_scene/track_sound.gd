extends AudioStreamPlayer

var is_paused: bool
var track_sound_play_script: Script = preload("res://game_play_scene/track_sound_play.gd")
@onready var hit_sound_node: Node = $".."

var is_track1_just_pressed: bool = false
var is_track2_just_pressed: bool = false
var is_track3_just_pressed: bool = false
var is_track4_just_pressed: bool = false


func _ready() -> void:
	is_paused = false


func _process(_delta: float) -> void:
	if is_paused:
		return
	if Input.is_action_pressed("track_1") and not self.is_track1_just_pressed:
		play_sound()
		self.is_track1_just_pressed = true
	elif not Input.is_action_pressed("track_1") and self.is_track1_just_pressed:
		self.is_track1_just_pressed = false
	if Input.is_action_pressed("track_2") and not self.is_track2_just_pressed:
		play_sound()
		self.is_track2_just_pressed = true
	elif not Input.is_action_pressed("track_2") and self.is_track2_just_pressed:
		self.is_track2_just_pressed = false
	if Input.is_action_pressed("track_3") and not self.is_track3_just_pressed:
		play_sound()
		self.is_track3_just_pressed = true
	elif not Input.is_action_pressed("track_3") and self.is_track3_just_pressed:
		self.is_track3_just_pressed = false
	if Input.is_action_pressed("track_4") and not self.is_track4_just_pressed:
		play_sound()
		self.is_track4_just_pressed = true
	elif not Input.is_action_pressed("track_4") and self.is_track4_just_pressed:
		self.is_track4_just_pressed = false


func _on_paused() -> void:
	is_paused = true


func _on_continued() -> void:
	is_paused = false
	

func play_sound() -> void:
	var self_node: AudioStreamPlayer = self
	var copy_node: AudioStreamPlayer = self_node.duplicate()
	hit_sound_node.add_child(copy_node)
	copy_node.play()
	copy_node.set_script(track_sound_play_script)
