extends "res://Scenes/Player.gd"


func _ready():
	$AnimatedSprite.animation = "ghost"
	speed = 75
	$CollisionShape2D.set_deferred("disabled", true)
	.on_ready() # Chamar função pai ("super")
	

	
