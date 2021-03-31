extends "res://Scenes/Player.gd"

signal haunting

signal stopped_haunting

var cooldown = 8.0

var duration = 1.5

var can_haunt = true

func _ready():
	$RClickTimer.wait_time = cooldown	
	$RClickDuration.wait_time = duration
	$RClickFeedback.hide()
	$AnimatedSprite.animation = "ghost"
	speed = 75
	$CollisionShape2D.set_deferred("disabled", true)
	$DetectionArea/DetectionShape.shape.set_radius(80)
	$DetectionArea/DetectionShape.shape.set_height(0)
	$RClickTimer.connect("timeout", self, "_on_RClickTimer_timeout")
	$RClickDuration.connect("timeout", self, "_on_RClickDuration_timeout")
	.on_ready() # Chamar função pai ("super")
	

func _process(delta):
	$RClickFeedback.text = "%3.1f" % $RClickTimer.time_left

func _input(event):
	.detect_inputs(event)
	if event.is_action_pressed("click_right") and can_haunt:
		if is_network_master():
			$RClickTimer.start()
			$RClickDuration.start()
			$RClickFeedback.show()
			can_haunt = false
			rpc("emit_haunting")

func _on_RClickTimer_timeout():
	$RClickFeedback.hide()
	can_haunt = true

func _on_RClickDuration_timeout():
	rpc("emit_stopped_haunting")
	
sync func emit_stopped_haunting():
	emit_signal("stopped_haunting")

sync func emit_haunting():
	emit_signal("haunting")
