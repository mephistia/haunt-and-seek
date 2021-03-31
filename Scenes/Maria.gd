extends "res://Scenes/Player.gd"

var is_detecting = false

var ghost

var distance = 0

var ghost_is_haunting = false

onready var fear_bar = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/FearProgress")

func _ready():
	$AnimatedSprite.animation = "maria"
	ghost = get_parent().get_node("Ghost")
	$RClickFeedback.hide()
	ghost.connect("haunting", self, "_on_Ghost_haunting")
	ghost.connect("stopped_haunting", self, "_on_Ghost_stopped_haunting")
	.on_ready() # Chamar função pai ("super")


func _on_DetectionArea_area_shape_entered(area_id, area, area_shape, self_shape):
	.start_detection()
	is_detecting = true
	

func _process(delta):
	if is_detecting  and is_network_master():
		distance = ghost.global_position.distance_to(global_position)
		
		print("Distance: " + str(distance))

		if ghost_is_haunting:
			var increase_by = range_lerp(distance, 0, 200, 1, 0.25)
			print("Increased by: " + str(increase_by))
			fear_bar.value += increase_by


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
