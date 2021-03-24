extends Node

var networkPeer = NetworkedMultiplayerENet.new()
var peers = []
var levelPackedScene = preload("res://Scenes/Match.tscn")
var levelInstance
var hostIsGhost = false

const MAX_PLAYERS = 2

signal levelLoaded

var ghostScene = preload("res://Scenes/Ghost.tscn")
var mariaScene = preload("res://Scenes/Maria.tscn")

func _ready():
	networkPeer.connect("peer_connected", self, "_peer_connected")
	networkPeer.connect("peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	networkPeer.connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")

func create_server(port, stateGhostCheck): # Verificar como usar o stateGhostCheck para criar o player
	self.connect("levelLoaded", self, "server_setup_after_load", [stateGhostCheck])
	get_tree().change_scene_to(levelPackedScene)
	networkPeer.create_server(port, MAX_PLAYERS)
	
func server_setup_after_load(stateGhostCheck):
	levelInstance = get_tree().current_scene
	get_tree().network_peer = networkPeer
	peers.append(1)
	create_player(1, stateGhostCheck)

func create_client(address, port):
	self.connect("levelLoaded", self, "client_setup_after_load")
	get_tree().change_scene_to(levelPackedScene)
	networkPeer.create_client(address, port)

func client_setup_after_load():
	levelInstance = get_tree().current_scene
	get_tree().network_peer = networkPeer

func _peer_connected(peerId):
	peers.append(peerId)
	create_player(peerId)

func _peer_disconnected(peerId):
	peers.remove(peers.find(peerId))
	destroy_player(peerId)

func _connected_to_server():
	create_player(get_tree().get_network_unique_id())

func _connection_failed():
	_server_disconnected()

func _server_disconnected():
	peers.clear()
	get_tree().change_scene("res://Menu.tscn")

func create_player(peerId, isGhost = false):
	var spawn
	var newPlayer
	
	# Mudar para de acordo com a seleção	
	if(peerId == 1):
		if (isGhost):
			hostIsGhost = true
			spawn = levelInstance.get_node("Ghost_Spawn")
			newPlayer = ghostScene.instance()
		else:
			hostIsGhost = false
			spawn = levelInstance.get_node("Maria_Spawn")
			newPlayer = mariaScene.instance()
			
	else:
		if (hostIsGhost):
			spawn = levelInstance.get_node("Maria_Spawn")
			newPlayer = mariaScene.instance()
		else:
			spawn = levelInstance.get_node("Ghost_Spawn")
			newPlayer = ghostScene.instance()
	
	newPlayer.set_network_master(peerId)
	newPlayer.name = String(peerId)
	newPlayer.position = spawn.position
	levelInstance.add_child(newPlayer)

func destroy_player(peerId):
	levelInstance.remove_node(levelInstance.get_node(String(peerId)))
