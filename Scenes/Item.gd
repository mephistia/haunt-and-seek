extends KinematicBody2D

export var type = 0

var texture_ring = preload("res://assets/GUI/item_ring.png")
var texture_necklace = preload("res://assets/GUI/item_necklace.png")

func _ready():
	randomize()
	$Tooltip.hide()

func rand_type():
	type = randi() % 2 # 0 ou 1
	update_texture()

func update_texture():
	if type == 0:
		$Sprite.texture = texture_ring
	else:
		$Sprite.texture = texture_necklace


func show_tooltip():
	$Tooltip.modulate = Color.white
	$Tooltip.show()
	
func hide_tooltip():
	$Tooltip.hide()
	
func show_tooltip_blocked():
	$Tooltip.modulate = Color(1,1,1,.7)
	$Tooltip.show()
