extends "res://Scenes/Player.gd"


func _ready():
	$AnimatedSprite.animation = "maria"
	player_name = 'Maria' # Mudar para nome digitado
	.on_ready() # Chamar função pai ("super")


