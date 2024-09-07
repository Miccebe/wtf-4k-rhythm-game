extends Label

enum TextType {
	EMPTY = 0,
	PERFECT = 1,
	EARLY_GREAT = 2,
	LATE_GREAT = 3,
	MISS = 4,
}

@export var text_type: TextType = TextType.EMPTY
@export var text_display_time_max: float = 3.0

var current_display_text_type: TextType
var current_display_text_time: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text_type = self.TextType.EMPTY
	self.current_display_text_type = self.text_type
	self.get_judgement_text()
	self.current_display_text_time = self.text_display_time_max


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if self.text_type != self.current_display_text_type:
		self.current_display_text_type = self.text_type
		self.current_display_text_time = self.text_display_time_max
	else:
		if self.current_display_text_type != self.TextType.EMPTY:
			self.current_display_text_time -= delta
		if self.current_display_text_time <= 0:
			self.text_type = self.TextType.EMPTY
			

func get_judgement_text() -> void:
	if self.current_display_text_type == self.TextType.EMPTY:
		self.text = ''
	elif self.current_display_text_type == self.TextType.PERFECT:
		self.text = 'PERFECT'
		self.label_settings.font_color = Color('#a900ff')
		self.label_settings.outline_color = Color('#ff8db9')
	elif self.current_display_text_type == self.TextType.EARLY_GREAT:
		self.text = 'E-GREAT'
		self.label_settings.font_color = Color('#0064ff')
		self.label_settings.outline_color = Color('#009fff')
	elif self.current_display_text_type == self.TextType.LATE_GREAT:
		self.text = 'L-GREAT'
		self.label_settings.font_color = Color('#e90000')
		self.label_settings.outline_color = Color('#ff7964')
	elif self.current_display_text_type == self.TextType.MISS:
		self.text = 'MISS'
		self.label_settings.font_color = Color('#a5a5a5')
		self.label_settings.outline_color = Color('#5a5a5a')


func _on_test(new_text: String):
	match new_text:
		'p':
			self.text_type = self.TextType.PERFECT
		'e', 'eg':
			self.text_type = self.TextType.EARLY_GREAT
		'l', 'lg':
			self.text_type = self.TextType.LATE_GREAT
		'm':
			self.text_type = self.TextType.MISS
		_:
			self.text_type = self.TextType.EMPTY
	self.get_judgement_text()
	print("new_text = ", new_text)
	print("self.text_type = ", self.TextType.find_key(self.text_type))
