extends "res://Scenes/Player.gd"


func _ready():
	$AnimatedSprite.animation = "maria"
	.on_ready() # Chamar função pai ("super")


