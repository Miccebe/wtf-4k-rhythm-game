extends ItemList

var songs_list: ChartLoader = ChartLoader.new()
var selected_chart: int = 0


func _ready() -> void:
	self._on_reload_songs_list()


func load_songs_list() -> void:
	self.songs_list.load_charts()
	self.clear()
	for i in self.songs_list.charts:
		var basic_info: Dictionary = i.get_basic_info()
		self.add_item("%s - %s" % [basic_info["song_name"], basic_info["composer"]])
	self.add_item("...")
	print("songs_list = ", self.songs_list)
	#breakpoint


func _on_reload_songs_list() -> void:
	self.load_songs_list()
	self.select_and_emit_signal(0)
	self.selected_chart = 0


func select_and_emit_signal(idx: int, single: bool = true) -> void:
	self.selected_chart = idx
	self.select(idx, single)
	emit_signal("item_selected", idx)
	print("select_and_emit_signal runned")
