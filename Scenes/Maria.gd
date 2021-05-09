extends "res://Scenes/Player.gd"

signal capturing

signal stopped_capturing

var cooldown = 8.0

var duration = 0.5

var can_capture = true

var is_detecting = false

var ghost

var distance = 0

var ghost_is_haunting = false

var max_captures = 3

var rotation_tween_ended = true

onready var fear_bar = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/FearProgress")

onready var captures_count = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/HBoxContainer2/CapturesCount")

onready var sound_indicator = $Center/SoundIndicator


func _ready():
	gamestate.connect("game_started", self, "game_has_started")
	$RClickTimer.wait_time = cooldown	
	$RClickDuration.wait_time = duration
	$AnimatedSprite.animation = "maria"
	$RClickFeedback.hide()
	.on_ready() # Chamar função pai ("super")

func game_has_started():
	if is_network_master():
		ghost = get_parent().get_node("Ghost")
		if ghost:
			ghost.connect("haunting", self, "_on_Ghost_haunting")
			ghost.connect("stopped_haunting", self, "_on_Ghost_stopped_haunting")	


	
	
# se pegar item q aumenta visão: $Light2D.texture_scale = 2	

func _process(delta):
	$RClickFeedback.text = "%3.1f" % $RClickTimer.time_left
	if is_network_master():
		# sempre mostra indicador
		if ghost_is_haunting:		
			
			sound_indicator.look_at(ghost.global_position)
			sound_indicator.rotation_degrees += 90
			
		if is_detecting and ghost_is_haunting:
			distance = ghost.global_position.distance_to(global_position)
			
			
			var difference = (global_position.length() - distance)
			print("Difference: " + str(difference))
			var contained_difference = inverse_lerp(150, 0, difference)
			var increase_by = abs(contained_difference)
			print ("increase_by: " + str(increase_by))
			print("Fear bar is on: " + str(fear_bar.value))
			fear_bar.value += increase_by
				
		# deve diminuir mesmo dentro da área
		else:
			fear_bar.value -= 1
		
		if (fear_bar.value == fear_bar.max_value):
			var ghost_name = get_tree().get_root().get_node("Match/Players/Ghost/PlayerName").text
			rpc("game_over", "Fantasma (" + ghost_name + ")")

func _input(event):
	.on_input(event)
	if event.is_action_pressed("main_action") and can_capture and max_captures > 0:
		if is_network_master():
			$RClickTimer.start()
			$RClickDuration.start()
			$RClickFeedback.show()
			max_captures -= 1
			can_capture = false
			rpc("emit_capturing")


sync func emit_capturing():
	# feedback visual
	$AnimatedSprite.modulate = Color(1, 0, 0)
	emit_signal("capturing")
	
func _on_RClickTimer_timeout():
	$RClickFeedback.hide()
	can_capture = true

func _on_RClickDuration_timeout():
	rpc("emit_stopped_capturing")

	captures_count.text = str(max_captures)
	
	if max_captures == 0:
		var ghost_name = get_tree().get_root().get_node("Match/Players/Ghost/PlayerName").text
		rpc("game_over", "Fantasma (" + ghost_name + ")")
	
	
sync func emit_stopped_capturing():
	$AnimatedSprite.modulate = Color(1, 1, 1)
	emit_signal("stopped_capturing")
	
func _on_DetectionArea_area_shape_entered(area_id, area, area_shape, self_shape):
	.start_detection()
	is_detecting = true

func _on_DetectionArea_area_shape_exited(area_id, area, area_shape, self_shape):
	.stop_detection()
	is_detecting = false

func _on_Ghost_haunting():
	ghost_is_haunting = true
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.6)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.2)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.8)
	$Tween.start()
func _on_Ghost_stopped_haunting():
	ghost_is_haunting = false
	
	
