extends AudioStreamPlayer

# 临时音频播放节点的脚本


func _init() -> void:
	self.finished.connect(self._on_finished_play)


func _on_finished_play() -> void:
	#print("hit_sound_play: _on_finished_play")
	self.queue_free()
