extends Node

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 5252


# Max number of players.
const MAX_PEERS = 2

var peer = null

var upnp = UPNP.new()

export var my_ip = 0

# Name for my player.
var player_name = "Player"


# Names for remote players in id:name format.
var players = {}
var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)
signal game_started()

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/Match"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Jogador " + players[id] + " desconectado.")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Servidor desconectado.")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game(id_class):
	# Change scene.
	var world = load("res://Scenes/Match.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("Lobby").hide()

	# Preload  Maria and  Ghost
	var maria = load("res://Scenes/Maria.tscn")
	var ghost = load("res://Scenes/Ghost.tscn")

	for p_id in id_class:
		var player
		
		if id_class[p_id] == 0:
			player = instantiate_maria(world) 
		else:
			player = instantiate_ghost(world)

		if p_id == get_tree().get_network_unique_id():	
			if id_class[p_id] == 1:
				world.get_node("CanvasLayer/GUI/HBoxContainer/VBoxContainer/FearProgress").hide()

			player.set_player_name(player_name)
			
		else:
			player.set_player_name(players[p_id])

		player.set_network_master(p_id) #set unique id as master.
		world.get_node("Players").add_child(player)

	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	emit_signal("game_started")
	get_tree().set_pause(false) # Unpause and unleash the game!

func instantiate_maria(world):
	var maria = load("res://Scenes/Maria.tscn")
	var new_player = maria.instance()
	new_player.position = world.get_node("Maria_Spawn").position
	new_player.set_name("Maria") 
	return new_player
	
func instantiate_ghost(world):
	var ghost = load("res://Scenes/Ghost.tscn")
	var new_player = ghost.instance()
	new_player.position = world.get_node("Ghost_Spawn").position
	new_player.set_name("Ghost") 
	return new_player

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	var result_upnp = open_port(DEFAULT_PORT)
	if result_upnp != 0:
		print("ERROR ON UPNP CONNECTION: " + str(result_upnp))
		emit_signal("game_error", "Erro na conexão UPnP:  " + str(result_upnp) + "\n\n\n Pode ser necessário ativar a conexão UPnP no roteador.")
		end_game()
	else:
		print("PORT OPENED")
		peer.create_server(DEFAULT_PORT, MAX_PEERS)
		get_tree().set_network_peer(peer)
	
	
func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
#	var result_upnp = open_port(DEFAULT_PORT)
#	if result_upnp != 0:
#		print("ERROR ON UPNP CONNECTION: " + result_upnp)
#	else:
#		print("PORT OPENED")
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func open_port(port):
	upnp.discover(2000, 2, "InternetGatewayDevice")
	var result = upnp.add_port_mapping(port)
	print(upnp.query_external_address())
	my_ip = upnp.query_external_address()
	return result


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


func begin_game(is_ghost):
	assert(get_tree().is_network_server())
	var id_class = {}
	id_class[1] = int(is_ghost) # Server é fantasma 1 ou 0
	var other_player_ghost = 0 if is_ghost else 1
	for p in players: # server não está na relação?
		id_class[p] = other_player_ghost
	# Call to pre-start game
	for p in players:
		rpc_id(p, "pre_start_game", id_class)

	pre_start_game(id_class)


func end_game():
	if has_node("/root/Match"): # Game is in progress.
		# End it
		get_node("/root/Match").queue_free()

	emit_signal("game_ended")
	players.clear()


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().set_auto_accept_quit(false)
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		upnp.delete_port_mapping(DEFAULT_PORT)
		print("Bye!")
		get_tree().quit() # default behavior
	

