extends Control

export (NodePath) var time_left_path
export (NodePath) var button1_path
export (NodePath) var button2_path
export (NodePath) var freq_timer_path
export (NodePath) var dur_timer_path
export (float) var total_time = 10.0
export (float) var button1_time = 1.0
export (float) var button2_time = 3.0
export (float) var shake_freq = 45.0
export (float) var shake_dur = 0.5
export (float) var shake_amp = 5.0

onready var time_left_visual : ProgressBar = get_node(time_left_path) as ProgressBar
onready var button1 = get_node(button1_path) as Button
onready var button2 : Button = get_node(button2_path)
onready var freq = get_node(freq_timer_path)
onready var dur = get_node(dur_timer_path)

var time_left : float setget set_time_left
var initial_pos : Vector2
var time_per_shake : float
var is_shaking := false

func _ready() -> void:
	time_left = total_time
	time_left_visual.max_value = total_time
	time_left_visual.value = time_left
	initial_pos = time_left_visual.rect_position


func set_time_left(value):
	time_left = value
	var tween = get_tree().create_tween()
	var pending = tween.tween_property(time_left_visual, "value", time_left, 0.5)
	pending.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()

func _on_Button_pressed() -> void:
	if (time_left >= button1_time):
		self.time_left -= button1_time
	else:
		invalid_action()


func _on_Button2_pressed() -> void:
	if (time_left >= button2_time):
		self.time_left -= button2_time
	else:
		invalid_action()

func invalid_action() -> void:
	start_shake()
	var tween2 = get_tree().create_tween()
	var pending = tween2.tween_property(time_left_visual, "self_modulate", Color.red, 0.5)
	pending.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pending = tween2.tween_property(time_left_visual, "self_modulate", Color.white, 1.0)
	pending.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween2.play()

func start_shake() -> void:
	is_shaking = true
	time_per_shake = 1 / shake_freq
	freq.start(time_per_shake)
	dur.start(shake_dur)
	new_shake()

func new_shake() -> void:
	if (!is_shaking):
		return
	
	var shake_tween = get_tree().create_tween()
	var shake_to = Vector2(
		rand_range(-shake_amp, shake_amp),
		rand_range(-shake_amp, shake_amp)
	)
	var pending = shake_tween.tween_property(time_left_visual, "rect_position", shake_to, time_per_shake)
	pending.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	shake_tween.play()
	freq.start(time_per_shake)

func shake_complete() -> void:
	is_shaking = false
	var shake_tween = get_tree().create_tween()
	var pending = shake_tween.tween_property(time_left_visual, "rect_position", initial_pos, time_per_shake)
	pending.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	shake_tween.play()
