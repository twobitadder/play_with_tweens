extends Node

signal text_event_report(event)

export var real_world : Resource
export var server : Resource

var active_world = null

func report_event(event) -> void:
	emit_signal("text_event_report", event)
