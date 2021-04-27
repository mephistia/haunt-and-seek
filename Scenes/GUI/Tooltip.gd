extends Node2D

func _ready():
	hide()		

func show_tooltip():
	modulate = Color.white
	show()
	
func hide_tooltip():
	hide()
	
func show_tooltip_blocked():
	modulate = Color(1,1,1,.4)
	show()
	
