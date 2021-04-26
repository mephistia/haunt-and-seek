extends Node2D

signal item_was_collected(which)

var spawns = []

var items_spawned = []

var items_used = []

var item_scene = load("res://Scenes/Item.tscn")

func _ready():
	for N in $ItemSpawns.get_children():
		spawns.append(N.position)
	
	gamestate.connect("game_started", self, "game_has_started")


func game_has_started():	
	var maria = get_node_or_null("Players/Maria")
	var ghost = get_node_or_null("Players/Ghost")
	
	if (maria):
		maria.connect("item_collected", self, "Maria_item_collected")
	if (ghost):
		ghost.connect("item_collected", self, "Ghost_item_collected")
	
	if (get_tree().is_network_server()):	
		for i in 2:
			var spawn = spawns[randi() % spawns.size()]
			if i == 1:
				while spawn == items_spawned[0].position:
					spawn = spawns[randi() % spawns.size()]
					
			var item_name = "Item" + str(i)
			rpc("spawn_item", item_scene, spawn, i, item_name)
			
remotesync func spawn_item(item_scene, spawn, type, item_name):
	var item_spawned = item_scene.instance()
	item_spawned.global_position = spawn
	item_spawned.type = type
	item_spawned.update_texture()
	item_spawned.name = item_name
	add_child(item_spawned)
	items_spawned.append(item_spawned)

func Maria_item_collected(which, by):
	collect_item(which, by)
	
	
func Ghost_item_collected(which, by):
	collect_item(which, by)
	print("Ghost obteu item do tipo " + str(which.type))
	
func collect_item(which, by):
		if by.is_network_master():
			$CanvasLayer/GUI/Inventory.add_item(which)
		rpc("delete_item", which)

		
remotesync func delete_item(which):
	get_node(which.get_path()).queue_free()
	var item_idx = items_spawned.find(which)
	if (item_idx > -1):
		items_spawned.remove(item_idx)
	


