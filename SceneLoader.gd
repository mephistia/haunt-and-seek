extends Node

signal loaded

var loading_bar

func load_scene(path, current_scene, is_scene_free):
	
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		print("Não foi possível carregar esse caminho!")
		return
	
	loading_bar = load("res://Scenes/LoadingBar.tscn").instance()
	
	get_tree().get_root().call_deferred('add_child',loading_bar)
	
	while true:
		var error = loader.poll()
		if error == ERR_FILE_EOF:
			#Carregou
			var resource = loader.get_resource()
			get_tree().get_root().call_deferred('add_child',resource.instance())
			emit_signal("loaded")
			if is_scene_free:
				current_scene.queue_free()
			break
		elif error == OK:
			#Carregando
			var progress = float(loader.get_stage())/loader.get_stage_count()
			loading_bar.get_node("ProgressBar").value = progress * 100
			print(progress)
		else:
			print("Erro ao carregar o arquivo!" + error)
			break
		yield(get_tree(),"idle_frame")

func free_loading():
	loading_bar.queue_free()
