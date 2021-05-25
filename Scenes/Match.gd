extends Node2D

signal item_was_collected(which)

var spawns = []

var items_spawned = [] #IDs dos itens spawnados

var items_used = []

func _ready():
	for N in $ItemSpawns.get_children():
		spawns.append(N.position)
	
	gamestate.connect("game_started", self, "game_has_started")


func game_has_started():	
	var maria = get_node_or_null("Players/Maria")
	var ghost = get_node_or_null("Players/Ghost")
	
	if (maria):
		maria.connect("item_collected", self, "Maria_item_collected")
		maria.connect("used_item", self, "Maria_used_item")
	if (ghost):
		ghost.connect("item_collected", self, "Ghost_item_collected")
		ghost.connect("used_item", self, "Ghost_used_item")
	
	if (get_tree().is_network_server()):	
		for i in 2:
			var spawn = spawns[randi() % spawns.size()]
			if i == 1:
				while spawn == get_node("Item" + str(items_spawned[0])).position:
					spawn = spawns[randi() % spawns.size()]
					
			rpc("spawn_item", spawn, i)
			
sync func spawn_item(spawn, type):
	var item_scene = load("res://Scenes/Item.tscn")
	var item_spawned = item_scene.instance()
	item_spawned.global_position = spawn
	item_spawned.type = type
	item_spawned.update_texture()
	add_child(item_spawned)
	item_spawned.id = items_spawned.size()
	item_spawned.name = "Item" + str(item_spawned.id)
	items_spawned.append(item_spawned.id)

func Maria_item_collected(which, by):
	collect_item(which, by)
	rpc("delete_item", which.id)
	
func Maria_used_item(slot, who):
	if who.is_network_master():
		var item_type_to_use = use_item(slot)
		print("Usar item do tipo: " + str(item_type_to_use))
	
	
func Ghost_item_collected(which, by):
	collect_item(which, by)
	rpc("delete_item", which.id)
	
func Ghost_used_item(slot, who):
	if who.is_network_master():
		var item_type_to_use = use_item(slot)
		print("Usar item do tipo: " + str(item_type_to_use))

func collect_item(which, by):
		if by.is_network_master():
			$CanvasLayer/GUI/Inventory.add_item(which)

func use_item(slot):
	return $CanvasLayer/GUI/Inventory.use_item(slot)
		
sync func delete_item(id):
	get_node("Item" + str(id)).queue_free()
	var item_idx = items_spawned.find(id)
	if (item_idx > -1):
		items_spawned.remove(item_idx)

