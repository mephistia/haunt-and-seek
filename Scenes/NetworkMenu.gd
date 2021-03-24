extends Panel

onready var Host = get_node("Host")
onready var Join = get_node("Join")
onready var JoinAddress = get_node("Join/Address")
onready var GhostCheck = get_node("Host/Ghost_Check")

var Port = 4242
var stateGhostChecked

func _ready():
	Host.connect("button_down", self, "host_pressed")
	Join.connect("button_down", self, "join_pressed")


func host_pressed():
	stateGhostChecked = GhostCheck.is_pressed()
	NetworkSingleton.create_server(Port, stateGhostChecked) # Passa a seleção de personagem (bool se selecionou fantasma)

func join_pressed():
	var Address = JoinAddress.text
	NetworkSingleton.create_client(Address, Port)
