extends Control

onready var music_bus = AudioServer.get_bus_index("Music")
onready var effects_bus = AudioServer.get_bus_index("Effects")

func _ready():
	$EffectsSlider.value = db2linear(AudioServer.get_bus_volume_db(effects_bus))
	$MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))


func _on_EffectsSlider_value_changed(value):
	AudioServer.set_bus_volume_db(effects_bus, linear2db(value))


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear2db(value))


func _on_BtnQuit_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_EffectsSlider_mouse_exited():
	release_focus()

func _on_MusicSlider_mouse_exited():
	release_focus()
