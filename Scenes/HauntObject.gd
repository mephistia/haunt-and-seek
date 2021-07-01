extends KinematicBody2D

enum Object_Type {CLOCK, LAMP, WATER, FURNITURE, RADIO, TYPEWRITER, MUSIC_BOX, FLOATING}

export(Object_Type) var type = Object_Type.CLOCK

var ghost

export(Array, AudioStream) var haunt_SFX_stream: Array

var ghost_boo_sfx

func _ready():
	get_node("Tooltip/Panel/Label").text = 	"Boo!          _"
	gamestate.connect("game_started", self, "game_has_started")

func game_has_started():
	ghost = get_node("/root/Match/Players/Ghost")
	if (ghost):
		ghost.connect("haunting", self, "_on_ghost_haunting")
		ghost_boo_sfx = ghost.get_node("BooSFX")

func _on_ghost_haunting():
	if ghost.object_to_haunt == self and ghost.is_paralyzed:
		ghost_boo_sfx.stop()
		ghost_boo_sfx.rpc("stop")
		rpc("play_sound")


sync func play_sound():
	match type:
		Object_Type.CLOCK:
			$HauntSFX.stream = haunt_SFX_stream[Object_Type.CLOCK]
		Object_Type.LAMP:
			$HauntSFX.stream = haunt_SFX_stream[Object_Type.LAMP]
		Object_Type.WATER:
			$HauntSFX.stream = haunt_SFX_stream[Object_Type.WATER]
		Object_Type.FURNITURE:
			$HauntSFX.stream = haunt_SFX_stream[Object_Type.FURNITURE]
		Object_Type.RADIO:
			$HauntSFX.stream = haunt_SFX_stream[Object_Type.RADIO]
		Object_Type.TYPEWRITER:
			$HauntSFX.stream = haunt_SFX_stream[Object_Type.TYPEWRITER]
		Object_Type.MUSIC_BOX:
			$HauntSFX.stream = haunt_SFX_stream[Object_Type.MUSIC_BOX]
		Object_Type.FLOATING:
			$HauntSFX.stream = haunt_SFX_stream[Object_Type.FLOATING]
			
	$HauntSFX.play()
	
