extends Node2D

var is_ghost = false

var character_before

func _ready():
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	gamestate.connect("character_of_player", self, "_on_character_set")
	
	if $Panel/GameOver/BtnReplay.disabled:
		get_node("Panel/GameOver/BtnReplay/ReplayLabel").add_color_override("font_color",Color(0.874, 0.752, 0.588, 0.3))

	if OS.has_environment("USERNAME"):
		$Panel/CreateMatch/Name.text = OS.get_environment("USERNAME")
		$Panel/JoinMatch/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Panel/CreateMatch/Name.text = desktop_path[desktop_path.size() - 2]
		$Panel/JoinMatch/Name.text = desktop_path[desktop_path.size() - 2]

func _on_BtnOptions_pressed():
	$Panel/MainMenu.hide()
	$Panel/Options.show()
	$ScreenFadeSound.play()


func _on_BtnReturn_pressed():
	$Panel/CreateMatch/ErrorLabel.text = ""
	$Panel/JoinMatch/ErrorLabel.text = ""
	$Panel/Options.hide()
	$Panel/HowToPlay.hide()
	$Panel/Credits.hide()
	$Panel/CreateMatch.hide()
	$Panel/JoinMatch.hide()
	$Panel/GameOver.hide()
	$Panel/MainMenu.show()
	$ScreenFadeSound.play()


func _on_BtnHowToPlay_pressed():
	$Panel/MainMenu.hide()
	$Panel/HowToPlay.show()
	$ScreenFadeSound.play()


func _on_BtnCredits_pressed():
	$Panel/MainMenu.hide()
	$Panel/Credits.show()
	$ScreenFadeSound.play()
	

func _on_BtnCreateMatch_pressed():
	if $Panel/CreateMatch/Name.text == "":
		$Panel/CreateMatch/ErrorLabel.text = "Nome inválido!"
		return
		
	$Panel/CreateMatch/ErrorLabel.text = ""
	$Panel/JoinMatch/ErrorLabel.text = ""
	is_ghost = $Panel/CreateMatch/GhostCheckButton.pressed
	$Panel/CreateMatch.hide()
	$ScreenFadeSound.play()
	$Panel/AwaitingPlayers.show()
	$Panel/CreateMatch/ErrorLabel.text = ""
	var player_name = $Panel/CreateMatch/Name.text
	gamestate.host_game(player_name)
	refresh_lobby()
	
	
func _on_BtnJoinMatch_pressed():
	if $Panel/JoinMatch/Name.text == "":
		$Panel/JoinMatch/ErrorLabel.text = "Nome inválido!"
		return
	
	var ip = $Panel/JoinMatch/IP.text
	if not ip.is_valid_ip_address():
		$Panel/JoinMatch/ErrorLabel.text = "IP inválido!"
		return
		
	$Panel/JoinMatch/ErrorLabel.text = ""
	$Panel/JoinMatch/BtnJoinMatch.disabled = true
	$Panel/JoinMatch/BtnReturn.disabled = true
	var player_name = $Panel/JoinMatch/Name.text
	gamestate.join_game(ip, player_name)

	
	
func _on_connection_success():
	$Panel/CreateMatch.hide()
	$Panel/JoinMatch.hide()
	$Panel/AwaitingPlayers.show()
	$ScreenFadeSound.play()
	
func _on_connection_failed():
	$Panel/CreateMatch/BtnCreateMatch.disabled = false
	$Panel/JoinMatch/BtnJoinMatch.disabled = false
	$Panel/CreateMatch/BtnReturn.disabled = false
	$Panel/JoinMatch/BtnReturn.disabled = false
	$Panel/CreateMatch/ErrorLabel.text = "A conexão falhou"
	$Panel/JoinMatch/ErrorLabel.text = "A conexão falhou"
	
func _on_game_ended():
	show()
	$Panel/MainMenu.hide()
	$Panel/AwaitingPlayers.hide()
	$Panel/JoinMatch/BtnJoinMatch.disabled = false
	$Panel/JoinMatch/BtnReturn.disabled = false
	
func _on_game_error(errortxt):
	$Panel/ErrorDialog.dialog_text = errortxt
	$Panel/ErrorDialog.popup_centered_minsize()
	$Panel/CreateMatch/BtnCreateMatch.disabled = false
	$Panel/JoinMatch/BtnJoinMatch.disabled = false	
	
func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	$Panel/AwaitingPlayers/List.clear()
	$Panel/AwaitingPlayers/List.add_item(gamestate.get_player_name() + " (Você)")
	for p in players:
		$Panel/AwaitingPlayers/List.add_item(p)
		
	$Panel/AwaitingPlayers/BtnPlay.disabled = not get_tree().is_network_server()
	


func _on_BtnPlay_pressed():
	gamestate.begin_game(is_ghost)
	

func _on_BtnReturnMenu_pressed():
	gamestate.clear_players()
	gamestate.delete_peer()
	$Panel/GameOver.hide()
	$Panel/MainMenu.show()
	
	
func _on_BtnReplay_pressed():
	var player_name = gamestate.get_player_name()
	is_ghost = !is_ghost
	$Panel/GameOver.hide()
	_on_BtnPlay_pressed()


func _on_character_set(character_name):
	character_before = character_name
	

func _on_BtnCreateMatchMenu_pressed():
	$Panel/MainMenu.hide()
	$Panel/CreateMatch.show()


func _on_BtnJoinMatchMenu_pressed():
	$Panel/MainMenu.hide()
	$Panel/JoinMatch.show()


#auxiliar do botão
func _on_BtnReplay_mouse_entered():
	if not $Panel/GameOver/BtnReplay.disabled:
		get_node("Panel/GameOver/BtnReplay/ReplayLabel").add_color_override("font_color", Color(0.8, 0.57, 0.22))


func _on_BtnReplay_mouse_exited():
	if not $Panel/GameOver/BtnReplay.disabled:
		$Panel/GameOver/BtnReplay/ReplayLabel.add_color_override("font_color", Color(0.874, 0.752, 0.588))





