extends "res://Scenes/Player.gd"

signal haunting

signal stopped_haunting

var is_on_detection_area = false

var cooldown = 8.0

export var duration = 2.5

var can_haunt = true

var last_sfx_id = -1

var maria

var normal_speed = 75

export(Array, AudioStream) var boo_sounds: Array

var detection_area

var maria_is_capturing = false

var object_to_haunt = null

var old_position

# som de movimento
var transition_duration = 0.5
var transition_type = 1
var volume_high = 8
var volume_low = 0


func _ready():
	gamestate.connect("game_started", self, "game_has_started")
	$RClickTimer.wait_time = cooldown	
	$RClickDuration.wait_time = duration
	$RClickFeedback.hide()
	idle_animation_name = "ghost"
	moving_animation_name = "ghost"
	$AnimatedSprite.scale = Vector2(1.5, 1.5)
	$AnimatedSprite.position = Vector2(0, -12)
	speed = normal_speed
	detection_area = get_node("DetectionArea/DetectionShape").shape.radius * 2
	$RClickTimer.connect("timeout", self, "_on_RClickTimer_timeout")
	$RClickDuration.connect("timeout", self, "_on_RClickDuration_timeout")
	randomize()
	$HauntingAnim.emitting = false
	.on_ready() # Chamar função pai ("super")
	
	
func game_has_started():
	maria = get_parent().get_node("Maria")
	if is_network_master():
		# desativar masks		
		$Trail.light_mask = 1
		$AnimatedSprite.light_mask = 1
		$PlayerName.light_mask = 1
		$Trail.material.light_mode = 0
		if maria:
			maria.connect("capturing", self, "_on_Maria_capturing")
			maria.connect("stopped_capturing", self, "_on_Maria_stopped_capturing")
				
func _process(delta):
	$RClickFeedback.text = "%3.1f" % $RClickTimer.time_left
	# velocidade diminui quanto mais próximo de maria
	if is_network_master() and maria:
		var distance = maria.global_position.distance_to(global_position)
		var clamped_distance = clamp(inverse_lerp(0, detection_area, distance), 0.75, 1)
		speed = clamped_distance * normal_speed
		
		if is_on_detection_area and maria_is_capturing:
			var maria_name = get_tree().get_root().get_node("Match/Players/Maria/PlayerName").text
			rpc("game_over", "Maria (" + maria_name + ")")


func _input(event):
	if event.is_action_pressed("main_action") and can_haunt and not is_paralyzed:
		if is_network_master():
			old_position = position
			
			if (object_to_haunt == null):
				haunt(false)
			else:
				rset("puppet_pos", object_to_haunt.position)
				position = object_to_haunt.position
				haunt(true)
				$AnimatedSprite.hide()
			
func haunt(should_paralyze):
	$RClickTimer.start()
	$RClickDuration.start()
	$RClickFeedback.show()
	rpc("play_random")
	can_haunt = false
	$HauntingAnim.emitting = true
	if (should_paralyze):
		$RClickDuration.wait_time = rand_range(0.8, 3.2)
		$RClickTimer.wait_time = rand_range(5.3, 9.2)
		if maria:
			rpc("set_new_contained_diff", 25)
		rpc("set_paralyzed", true)
		rpc("toggle_invisible", true)
	rpc("emit_haunting")
		
sync func set_new_contained_diff(value):
	maria.max_contained_diff = value
	
sync func set_paralyzed(value):
	is_paralyzed = value

sync func toggle_invisible(hide):
	if hide:
		$AnimatedSprite.hide()
	else:
		$AnimatedSprite.show()

func _on_RClickTimer_timeout():
	$RClickFeedback.hide()
	if !is_on_detection_area:
		can_haunt = true

sync func started_moving():
	$MoveSFXTween.interpolate_property($MoveSFX, "volume_db", volume_low, volume_high, transition_duration, transition_type, Tween.EASE_IN, 0)
	$MoveSFXTween.start()

	
sync func stopped_moving():
	$MoveSFXTween.interpolate_property($MoveSFX, "volume_db", volume_high, volume_low, transition_duration, transition_type, Tween.EASE_IN, 0)
	$MoveSFXTween.start()


func _on_RClickDuration_timeout():
	if is_paralyzed:
		rset("puppet_pos", old_position)
		position = old_position
		rpc("set_paralyzed", false)
	rpc("set_new_contained_diff", 35)
	rpc("toggle_invisible", false)
	rpc("emit_stopped_haunting")
	$HauntingAnim.emitting = false

	
sync func emit_stopped_haunting():
	$AnimatedSprite.modulate = Color(1, 1, 1)
	emit_signal("stopped_haunting")

sync func emit_haunting():
	$AnimatedSprite.modulate = Color(1, 0, 0)
	emit_signal("haunting")

sync func play_random():
	var rand_id = randi() % boo_sounds.size()
	while rand_id == last_sfx_id:
		rand_id = randi() % boo_sounds.size()
		
	last_sfx_id = rand_id
	$BooSFX.stream = boo_sounds[rand_id]
	$BooSFX.play()

func _on_Maria_capturing():
	maria_is_capturing = true
	
	
func _on_Maria_stopped_capturing():
	maria_is_capturing = false

# quando o sprite de Maria entrar na área do fantasma
func _on_DetectionArea_body_entered(body):
	if is_network_master() and body.get_name() == "Maria":
		can_haunt = false
		is_on_detection_area = true
	if is_network_master() and body.is_in_group("Objects"):
		if can_haunt:
			body.get_node("Tooltip").show_tooltip()
			rpc("set_obj_to_haunt", body)
		else:
			body.get_node("Tooltip").show_tooltip_blocked()
		pass


func _on_DetectionArea_body_exited(body):
	if is_network_master() and body.get_name() == "Maria":
		is_on_detection_area = false
		if !can_haunt and $RClickTimer.time_left == 0:
			can_haunt = true
	if is_network_master() and body.is_in_group("Objects"):
		rpc("set_obj_to_haunt", null)
		body.get_node("Tooltip").hide_tooltip()


sync func set_obj_to_haunt(object):
	object_to_haunt = object


sync func useItem(id):
	if id == 0:
		# menos rastros
		$Trail.speed_scale = 0.5
		$ItemDuration1.start()
	elif id == 1:
		# maior alcance assombração
		rpc("changeMariaDetectionRadius", true)
		$ItemDuration2.start()

sync func changeMariaDetectionRadius(should_increase):
		if maria:
			if should_increase:
				maria.get_node("DetectionArea/DetectionShape").shape.radius = 300
			else:
				maria.get_node("DetectionArea/DetectionShape").shape.radius = 200
	
func _on_ItemDuration1_timeout():
	$Trail.speed_scale = 3


func _on_ItemDuration2_timeout():
	rpc("changeMariaDetectionRadius", false)

	
func _on_DetectionArea_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_parent().name == "Maria":
		rpc("start_detection")

func _on_DetectionArea_area_shape_exited(area_id, area, area_shape, self_shape):
	if area.get_parent().name == "Maria":
		rpc("stop_detection")
