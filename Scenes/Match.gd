extends Node2D

var spawns = []

var item_scene = preload("res://Scenes/Item.tscn")

func _ready():
	for N in $ItemSpawns.get_children():
		spawns.append(N.position)
	
	gamestate.connect("game_started", self, "game_has_started")


func game_has_started():
	var items_spawned = []
	for i in 2:
		var spawn = spawns[randi() % spawns.size()]
		if i == 1:
			while spawn == items_spawned[0].position:
				spawn = spawns[randi() % spawns.size()]
				
		var item_spawned = item_scene.instance()
		item_spawned.global_position = spawn
		item_spawned.type = i
		item_spawned.update_texture()
		
