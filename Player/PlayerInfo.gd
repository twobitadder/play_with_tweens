extends Node

enum ATTACK_TYPE { SPOOF, FUZZ, DISABLE, ANALYZE, DECRYPT, DOWNLOAD }

signal time_remaining(value)
signal time_depleted

export var total_time : float setget set_total_time, get_total_time
export var time_remaining : float setget set_time_remaining, get_time_remaining
export var spoof_strength := 1.0
export var fuzz_strength := 1.0
export var disable_strength := 1.0
export var analyze_speed := 1.0
export var decrypt_speed := 1.0
export var download_speed := 1.0
export var detect_chance := 0.6
export var grid_pos := Vector2.ZERO


func _ready() -> void:
	time_remaining = total_time

func set_total_time(value) -> void:
	total_time = value

func get_total_time() -> float:
	return total_time

func set_time_remaining(value : float) -> void:
	if (value <= 0.0):
		emit_signal("time_depleted")
		return
	time_remaining = value
	emit_signal("time_remaining", time_remaining)

func get_time_remaining() -> float:
	return time_remaining

func estimate_time(object_data : ObjectData) -> float:
	return 1.0
