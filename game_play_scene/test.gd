extends Polygon2D

var movement_speed: float = 30.0
var test_start: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.test_start and self.position.y <= 700:
		self.position.y += self.movement_speed * delta
	if self.position.y > 700 and self.test_start:
		self.test_start = false
		self.position.y = 0


func _on_start_test() -> void:
	self.test_start = true
	self.position.y = 0
	self.movement_speed = float($"/root/GamePlayScene/Tests/LineEdit".text)
