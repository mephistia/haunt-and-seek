extends KinematicBody2D

export var type = 0

export var id = 0

var texture_ring = preload("res://assets/GUI/item_ring.png")
var texture_necklace = preload("res://assets/GUI/item_necklace.png")

func _ready():
	randomize()

func rand_type():
	type = randi() % 2 # 0 ou 1
	update_texture()

func update_texture():
	if type == 0:
		$Sprite.texture = texture_ring
	else:
		$Sprite.texture = texture_necklace
