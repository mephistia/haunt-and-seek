extends Sprite


export var type = 0

var texture_ring = preload("res://assets/GUI/item_ring.png")
var texture_necklace = preload("res://assets/GUI/item_necklace.png")

func _ready():
	randomize()

func rand_type():
	type = randi() % 2 # 0 ou 1
	update_texture()

func update_texture():
	if type == 0:
		texture = texture_ring
	else:
		texture = texture_necklace
	
