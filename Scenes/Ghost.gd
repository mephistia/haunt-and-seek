extends "res://Scenes/Player.gd"


func _ready():
	$AnimatedSprite.animation = "ghost"
	speed = 75
	.on_ready() # Chamar função pai ("super")

	
