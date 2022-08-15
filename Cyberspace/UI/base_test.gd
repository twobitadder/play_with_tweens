# warning-ignore-all:return_value_discarded
extends Control

var object_display = preload("res://Cyberspace/Objects/CyberObject.tscn")

onready var time_remaining = $"%TimeRemaining"

var selected_object = null
var pending_action_time := 0.0

func _ready() -> void:
	TimeKeeper.connect("pass_time", self, "_on_pass_time")
	PlayerInfo.connect("time_remaining", self, "update_time_remaining")
	update_time_remaining(PlayerInfo.total_time)

func update_time_remaining(value : float) -> void:
	time_remaining.bbcode_text = "[center]%.3f[/center]" % value
	var lerp_color = Color.green.linear_interpolate(Color.red, inverse_lerp(PlayerInfo.total_time, 0.0, value))
	time_remaining.self_modulate = lerp_color

func _on_Button_pressed() -> void:
	for child in $"%RoomContents".get_children():
		if child.is_active:
			child.interact(PlayerInfo.ATTACK_TYPE.SPOOF)
			child.connect("deselected", self, "_on_object_deselected", [child])
			TimeKeeper.pass_time(pending_action_time)
			

func _on_Button2_pressed() -> void:
	for child in $"%RoomContents".get_children():
		if child.is_active:
			child.interact(PlayerInfo.ATTACK_TYPE.DECRYPT)
			child.connect("deselected", self, "_on_object_deselected", [child])
			TimeKeeper.pass_time(pending_action_time)

func _on_object_deselected(object) -> void:
	selected_object = null
	object.disconnect("deselected", self, "_on_object_deselected")

func _on_pass_time(time_cost : float) -> void:
	PlayerInfo.time_remaining -= time_cost

func _on_room_object_selected(object) -> void:
	for child in $"%RoomContents".get_children():
		if child != object:
			child.deactivate()
	selected_object = object

func _on_room_entered(objects : Array) -> void:
	selected_object = null
	for child in $"%RoomContents".get_children():
		child.deactivate()
		child.queue_free()
	
	for object in objects:
		if !object.is_active:
			continue
		var new_object = object_display.instance()
		new_object.object_data = object
		$"%RoomContents".add_child(new_object)
		new_object.connect("selected", self, "_on_room_object_selected", [new_object])

func _on_Button_mouse_entered() -> void:
	if !is_instance_valid(selected_object):
		return
	pending_action_time = PlayerInfo.estimate_time(selected_object.object_data)
	
	#if objects are incompatible, zero out and cancel
	if pending_action_time == -1.0:
		pending_action_time = 0.0
		return
	
	#else display pending time
	$"%TimeSubtracted".bbcode_text = "- %.3f" % pending_action_time

func _on_Button_mouse_exited() -> void:
	pending_action_time = 0.0
	$"%TimeSubtracted".bbcode_text = ""

func _on_Button2_mouse_entered() -> void:
	if !is_instance_valid(selected_object):
		return

func _on_Button2_mouse_exited() -> void:
	pass # Replace with function body.
