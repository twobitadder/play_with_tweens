extends Node

signal post_initialize(arguments)

#Structure of scene dictionary is "Scene Name" : "path to scene"
export var scenes := {"Example Scene" : "res://path/to/example/scene.tscn"}
export var loading_scene : PackedScene
#set to false to squelch most print notifications
var enable_warnings := true

var loader : ResourceInteractiveLoader
var wait_frames : int
var time_max := 100 #msec
var currently_loading : String
var pending_args

func _process(_delta) -> void:
	if (!loader):
		return
	
	if (wait_frames > 0):
		wait_frames -=1
		return
	
	var time = OS.get_ticks_msec()
	
	while (OS.get_ticks_msec() < time + time_max):
		var result = loader.poll()
		
		if result == ERR_FILE_EOF:
			var new_scene = loader.get_resource()
			loader = null
			preinit_scene(new_scene)
			break
		elif result == OK:
			#update progress bar, etc
			pass
		else:
			loader = null
			break

func register_scene(scene_name : String, path : String, overwrite := false) -> void:
	if (scenes.has(scene_name) && !overwrite):
		if (enable_warnings):
			print("Duplicate scene dictionary key found without override enabled (%) - discarding " % scene_name)
		return
	scenes[scene_name] = path

func deregister_scene(scene_name : String) -> void:
	if (!scenes.has(scene_name)):
		if (enable_warnings):
			print("Scene %s not in scene dictionary - skipping" % scene_name)
			return
	scenes.erase(scene_name)

func change_scene(scene_name : String, arguments := []) -> void:
	pending_args = arguments
	if (!scenes.has(scene_name)):
		printerr("Invalid scene name %s!" % scene_name)
		return
	currently_loading = scene_name
	loader = ResourceLoader.load_interactive(scenes[scene_name])
	var prev_scene = get_tree().current_scene
	prev_scene.queue_free()
	wait_frames = 1

func preinit_scene(scene : PackedScene) -> void:
	var new_scene = scene.instance()
	new_scene.connect("ready", self, "_postinitialize_args")
	connect("post_initialize", new_scene, "_on_postinitalize")
	get_tree().get_root().add_child(new_scene)
	get_tree().current_scene = new_scene

func _postinitialize_args() -> void:
	emit_signal("post_initialize", pending_args)
	pending_args = []
