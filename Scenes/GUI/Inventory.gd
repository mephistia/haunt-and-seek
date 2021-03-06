extends GridContainer

onready var slot1 = $Slot1
onready var slot2 = $Slot2

var items = []

func add_item(item, by_name):
	items.append(item.type)
	var texture_child = TextureRect.new()
	texture_child.texture = item.get_node("Sprite").texture
	texture_child.name = "TextureRect"
	texture_child.anchor_bottom = 0.15
	texture_child.anchor_left = 0.15
	texture_child.anchor_top = 0.15
	texture_child.anchor_right = 0.15
	if (item.type == 1):
		if by_name == "Maria":
			texture_child.hint_tooltip = "Diminui a barra de medo mais rápido"
		else:
			texture_child.hint_tooltip = "Aumenta o alcance da assombração"
	else:
		if by_name == "Maria":
			texture_child.hint_tooltip = "Aumenta a luz da lanterna"
		else:
			texture_child.hint_tooltip = "Diminui a quantidade de rastros deixados"
		
	if (slot1.get_node_or_null("TextureRect") == null):
		slot1.add_child(texture_child)
	else:
		slot2.add_child(texture_child)
		
func use_item(slot):
	get_node("Slot" + str(slot)).get_node("TextureRect").queue_free()
	var item_type = items[slot-1]
	items.remove(slot-1)
	return item_type




