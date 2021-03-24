extends "res://Scenes/Player.gd"


func _ready():
	$AnimatedSprite.animation = "ghost"
	speed = 75
	player_name = 'Fantasma' # Mudar para nome digitado
	.on_ready() # Chamar função pai ("super")

	
