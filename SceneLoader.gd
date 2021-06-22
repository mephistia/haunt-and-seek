extends Node


func load_scene(path, current_scene):
	
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		print("Não foi possível carregar esse caminho!")
		return
	
	var loading_bar = load("res://Scenes/LoadingBar.tscn").instance()
	
	get_tree().get_root().call_deferred('add_child',loading_bar)
	
	while true:
		var error = loader.poll()
		if error == ERR_FILE_EOF:
			#Carregou
			var resource = loader.get_resource()
			get_tree().get_root().call_deferred('add_child',resource.instance())
			current_scene.queue_free()
			loading_bar.queue_free()
			break
		elif error == OK:
			#Carregando
			var progress = float(loader.get_stage())/loader.get_stage_count()
			loading_bar.value = progress * 100
			print(progress)
		else:
			print("Erro ao carregar o arquivo!" + error)
			break
		yield(get_tree(),"idle_frame")
