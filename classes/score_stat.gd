extends Node

var perfect_count: int = 0
var early_great_count: int = 0
var late_great_count: int = 0
var great_count: int = 0
var miss_count: int = 0

var accuracy: float = 1
#var note_count: int = 0

# perfect得到100%分数
# great得到50%分数
# miss得到0%分数
const PERFECT_SCORE: float = 1
const GREAT_SCORE: float = 0.5
const MISS_SCORE: float = 0


func _process(_delta: float) -> void:
	self.great_count = self.late_great_count + self.early_great_count


func get_current_accuracy() -> void:
	var current_note_count: int = perfect_count + great_count + miss_count
	if current_note_count == 0:
		accuracy = 1
	else:
		accuracy = (perfect_count * PERFECT_SCORE + great_count * GREAT_SCORE + miss_count * MISS_SCORE) / ((perfect_count + great_count + miss_count) * PERFECT_SCORE)
