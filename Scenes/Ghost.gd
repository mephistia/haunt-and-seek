extends "res://Scenes/Player.gd"

signal haunting

signal stopped_haunting

var is_on_detection_area = false

var cooldown = 8.0

var duration = 2.5

var can_haunt = true

var last_sfx_id = -1

var maria

var normal_speed = 75

export(Array, AudioStream) var boo_sounds: Array

var detection_area

var maria_is_capturing = false

func _ready():
	gamestate.connect("game_started", self, "game_has_started")
	$RClickTimer.wait_time = cooldown	
	$RClickDuration.wait_time = duration
	$RClickFeedback.hide()
	$AnimatedSprite.animation = "ghost"
	speed = normal_speed
	$CollisionShape2D.set_deferred("disabled", true)
	$DetectionArea/DetectionShape.shape.set_radius(90)
	$DetectionArea/DetectionShape.shape.set_height(0)
	detection_area = get_node("DetectionArea/DetectionShape").shape.radius * 2
	$RClickTimer.connect("timeout", self, "_on_RClickTimer_timeout")
	$RClickDuration.connect("timeout", self, "_on_RClickDuration_timeout")
	randomize()
	.on_ready() # Chamar função pai ("super")
	
	
func game_has_started():
	if is_network_master():
		maria = get_parent().get_node("Maria")
		if maria:
			maria.connect("capturing", self, "_on_Maria_capturing")
			maria.connect("stopped_capturing", self, "_on_Maria_stopped_capturing")
		
func _process(delta):
	$RClickFeedback.text = "%3.1f" % $RClickTimer.time_left
	# velocidade diminui quanto mais próximo de maria
	if is_network_master():
		var distance = maria.global_position.distance_to(global_position)
		var clamped_distance = clamp(inverse_lerp(0, detection_area, distance), 0.85, 1)
		speed = clamped_distance * normal_speed
		
		if is_on_detection_area and maria_is_capturing:
			var maria_name = get_tree().get_root().get_node("Match/Players/Maria/PlayerName").text
			rpc("game_over", "Maria (" + maria_name + ")")
		

func _input(event):
	.detect_inputs(event)
	if event.is_action_pressed("click_right") and can_haunt:
		if is_network_master():
			$RClickTimer.start()
			$RClickDuration.start()
			$RClickFeedback.show()
			rpc("play_random")
			can_haunt = false
			rpc("emit_haunting")

func _on_RClickTimer_timeout():
	$RClickFeedback.hide()
	if !is_on_detection_area:
		can_haunt = true

func _on_RClickDuration_timeout():
	rpc("emit_stopped_haunting")
	
sync func emit_stopped_haunting():
	$AnimatedSprite.modulate = Color(1, 1, 1)
	emit_signal("stopped_haunting")

sync func emit_haunting():
	# mudar cor para feedback visual
	$AnimatedSprite.modulate = Color(1, 0, 0)
	emit_signal("haunting")

sync func play_random():
	var rand_id = randi() % boo_sounds.size()
	while rand_id == last_sfx_id:
		rand_id = randi() % boo_sounds.size()
		
	last_sfx_id = rand_id
	$SFX.stream = boo_sounds[rand_id]
	$SFX.play()

func _on_Maria_capturing():
	maria_is_capturing = true
	
	
func _on_Maria_stopped_capturing():
	maria_is_capturing = false

# quando o sprite de Maria entrar na área do fantasma
func _on_DetectionArea_body_entered(body):
	if is_network_master() and body.get_name() == "Maria":
		can_haunt = false
		is_on_detection_area = true


func _on_DetectionArea_body_exited(body):
	if is_network_master() and body.get_name() == "Maria":
		is_on_detection_area = false
		if !can_haunt and $RClickTimer.time_left == 0:
			can_haunt = true


