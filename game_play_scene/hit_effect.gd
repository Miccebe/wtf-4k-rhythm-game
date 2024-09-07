extends Node2D


var is_paused: bool


func _ready() -> void:
	is_paused = false


func _process(_delta: float) -> void:
	if is_paused:
		return
	
	self.change_hit_effect_visible(1, Input.is_action_pressed("track_1"))
	self.change_hit_effect_visible(2, Input.is_action_pressed("track_2"))
	self.change_hit_effect_visible(3, Input.is_action_pressed("track_3"))
	self.change_hit_effect_visible(4, Input.is_action_pressed("track_4"))


func change_hit_effect_visible(track: int, _is_visible: bool) -> void:
	## track值为1~4
	var hit_effect: Sprite2D = get_child(track - 1)
	hit_effect.visible = _is_visible


func _on_paused() -> void:
	is_paused = true


func _on_continued() -> void:
	is_paused = false
