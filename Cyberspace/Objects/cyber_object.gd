extends Control

signal selected
signal deselected

export var object_data : Resource

var is_active := false

func _ready() -> void:
	if !object_data:
		return
	$"%Appearance".texture = object_data.appearance
	$"%Name".text = object_data.name
	$"%Status".text = object_data.status
	$"%ActionProgress".value = 0
	object_data.connect("change_status", self, "_on_change_status")
	object_data.connect("update_meter", self, "_on_update_meter")

func _on_CyberObject_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			activate()

func activate() -> void:
	$"%Name".self_modulate = Color.aqua
	is_active = true
	emit_signal("selected")

func deactivate() -> void:
	$"%Name".self_modulate = Color.white
	is_active = false
	object_data.interacting = false
	emit_signal("deselected")

func _on_CyberObject_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($HBoxContainer, "rect_position:x", 20.0, 0.1)
	tween.play()

func _on_CyberObject_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($HBoxContainer, "rect_position:x", 0.0, 0.1)
	tween.play()

func update_progress_color(value) -> void:
	var lerp_color = object_data.action_started_color.linear_interpolate(
		object_data.action_completed_color, 
		inverse_lerp(0.0, 100.0, value))
	$"%ActionProgress".self_modulate = lerp_color

func _on_update_meter(value) -> void:
	$"%ActionProgress".value = value

func interact(action : int) -> void:
	object_data.interact(action)

func _on_change_status(status: String, color : Color) -> void:
	$"%Status".text = status
	$"%Status".self_modulate = color
