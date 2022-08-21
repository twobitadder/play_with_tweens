extends Node

signal text_event_report(event)

var ice_and_data := 0
var rooms_instanced := 0
var ice := {}
var rooms := {}

export var real_world : Resource
export var server : Resource

var active_world = null

func report_event(event) -> void:
	emit_signal("text_event_report", event)
