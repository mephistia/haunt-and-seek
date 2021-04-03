extends "res://Scenes/Player.gd"

var is_detecting = false

var ghost

var distance = 0

var ghost_is_haunting = false

onready var detection_radius = get_node("DetectionArea/DetectionShape").shape.radius

onready var fear_bar = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/FearProgress")

func _ready():
	gamestate.connect("game_started", self, "game_has_started")
	$AnimatedSprite.animation = "maria"
	$RClickFeedback.hide()
	.on_ready() # Chamar função pai ("super")

func game_has_started():
	if is_network_master():
		ghost = get_parent().get_node("Ghost")
		ghost.connect("haunting", self, "_on_Ghost_haunting")
		ghost.connect("stopped_haunting", self, "_on_Ghost_stopped_haunting")	


func _on_DetectionArea_area_shape_entered(area_id, area, area_shape, self_shape):
	.start_detection()
	is_detecting = true
	

func _process(delta):
	if is_detecting  and is_network_master() and ghost_is_haunting:
		distance = ghost.global_position.distance_to(global_position)
		
		print("Distance: " + str(distance))
		
		# shape radius * 2
		var difference = 336 - distance
		var a = inverse_lerp(0, 336, difference)
		
		var increase_by = difference * delta
		print("Increased by: " + str(increase_by))
		fear_bar.value += increase_by
			
	# deve diminuir mesmo dentro da área
	elif is_network_master():
		fear_bar.value -= 1


func _on_DetectionArea_area_shape_exited(area_id, area, area_shape, self_shape):
	.stop_detection()
	is_detecting = false

func _on_Ghost_haunting():
	if is_network_master():
		print("Ghost is haunting")
	ghost_is_haunting = true

func _on_Ghost_stopped_haunting():
	if is_network_master():
		print("Ghost stopped haunting")
	ghost_is_haunting = false
