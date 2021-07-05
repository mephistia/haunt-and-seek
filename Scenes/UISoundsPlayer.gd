extends Node


func connect_to_button(button):
	button.connect("pressed", self, "_on_Button_pressed")
	button.connect("mouse_entered", self, "_on_Button_mouse_entered")
	
	
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func _on_Button_pressed():
	$ButtonClickPlayer.play()
	
func _on_Button_mouse_entered():
	$ButtonHoverPlayer.play()

func _on_SceneTree_node_added(node):
	if node is Button:
		connect_to_button(node)
		
func _ready():
	connect_buttons(get_tree().root)
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")
