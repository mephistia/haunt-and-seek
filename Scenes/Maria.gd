extends "res://Scenes/Player.gd"

signal capturing

signal stopped_capturing

var cooldown = 8.0

var duration = 0.8

var can_capture = true

var ghost

var distance = 0

var ghost_is_haunting = false

var max_captures = 3

var rotation_tween_ended = true

var reduce_fear_bar = 1

export var divide_difference_by = 10

export var max_contained_diff = 25

onready var fear_bar = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/FearProgress")

onready var captures_count = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/HBoxContainer2/CapturesCount")

onready var sound_indicator = $Center/SoundIndicator


func _ready():
	gamestate.connect("game_started", self, "game_has_started")
	$MainActionTimer.wait_time = cooldown	
	$MainActionDuration.wait_time = duration
	$AnimatedSprite.animation = "maria"
	$MainActionFeedback.hide()
	$CapturingVFX.emitting = false
	.on_ready() # Chamar função pai ("super")

func game_has_started():
	if is_network_master():
		ghost = get_parent().get_node("Ghost")
		if ghost:
			ghost.connect("haunting", self, "_on_Ghost_haunting")
			ghost.connect("stopped_haunting", self, "_on_Ghost_stopped_haunting")	
			ghost.get_node("Light2D").hide()


func _process(delta):
	$MainActionFeedback.text = "%3.1f" % $MainActionTimer.time_left
	if is_network_master():
		if ghost_is_haunting:		
			print("Detecting? " + str(is_being_detected))
			sound_indicator.look_at(ghost.global_position)
			sound_indicator.rotation_degrees += 90
			
		if is_being_detected and ghost_is_haunting:
			distance = position.distance_to(ghost.position)
			
			
			var difference = (global_position.length() - (distance)) / divide_difference_by
			var contained_difference = inverse_lerp(0, max_contained_diff, difference)
			var increase_by = abs(contained_difference)
			fear_bar.value += increase_by
				
		# deve diminuir mesmo dentro da área
		else:
			fear_bar.value -= reduce_fear_bar
		
		if (fear_bar.value == fear_bar.max_value):
			var ghost_name = get_tree().get_root().get_node("Match/Players/Ghost/PlayerName").text
			rpc("game_over", "Fantasma (" + ghost_name + ")")

func _input(event):
	.on_input(event)
	if event.is_action_pressed("main_action") and can_capture and max_captures > 0:
		if is_network_master():
			$MainActionTimer.start()
			$MainActionDuration.start()
			$MainActionFeedback.show()
			max_captures -= 1
			can_capture = false
			rpc("emit_capturing")
			
sync func useItem(id):
	if id == 0:
		# mais visão
		$Light2D.texture_scale = 2
		$ItemDuration1.start()
	elif id == 1:
		#reduz mais rápido
		reduce_fear_bar = 2
		$ItemDuration2.start()
		

sync func emit_capturing():
	# feedback visual
	$CapturingVFX.emitting = true
	emit_signal("capturing")
	
func _on_MainActionTimer_timeout():
	$MainActionFeedback.hide()
	can_capture = true

func _on_MainActionDuration_timeout():
	rpc("emit_stopped_capturing")

	captures_count.text = str(max_captures)
	
	if max_captures == 0:
		var ghost_name = get_tree().get_root().get_node("Match/Players/Ghost/PlayerName").text
		rpc("game_over", "Fantasma (" + ghost_name + ")")
	
	
sync func emit_stopped_capturing():
	$CapturingVFX.emitting = false
	emit_signal("stopped_capturing")


func _on_Ghost_haunting():
	ghost_is_haunting = true
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.6)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.2)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.8)
	$Tween.start()
func _on_Ghost_stopped_haunting():
	ghost_is_haunting = false
	
		
func _on_DetectionArea_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_parent().name == "Ghost":
		rpc("start_detection")

func _on_DetectionArea_area_shape_exited(area_id, area, area_shape, self_shape):
	if area.get_parent().name == "Ghost":
		rpc("stop_detection")


func _on_ItemDuration1_timeout():
	$Light2D.texture_scale = 1


func _on_ItemDuration2_timeout():
	reduce_fear_bar = 1
