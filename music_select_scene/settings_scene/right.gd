extends Button


func _ready() -> void:
	self.visible = true


func _pressed() -> void:
	var root_node: Node2D = $".."
	if root_node.current_settings_page < root_node.SETTINGS_PAGE_MAX:
		root_node.current_settings_page += 1
	root_node.emit_signal("page_changed", root_node.current_settings_page)


func _on_page_changed(_page: SettingsScene.SettingsPage) -> void:
	if _page == $"..".SETTINGS_PAGE_MAX:
		self.visible = false
	else:
		self.visible = true
	var settings_pages: Array[Node] = $"../Control".get_children()
	for i in range(len(settings_pages)):
		if i == _page:
			settings_pages[i].visible = true
		else:
			settings_pages[i].visible = false
	
