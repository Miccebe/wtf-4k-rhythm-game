extends AudioStreamPlayer

var has_played: bool


func _ready() -> void:
	self.has_played = false


func _process(_delta: float) -> void:
	if self.has_played and not self.playing:
		self.queue_free()
