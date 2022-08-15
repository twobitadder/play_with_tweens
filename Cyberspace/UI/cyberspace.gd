#warning-ignore-all:return_value_discarded
extends Control

func _ready() -> void:
	$"%MiniMap".connect("room_entered", $"%RunUI", "_on_room_entered")
	WorldState.connect("text_event_report", self, "_on_text_event_reported")

func _on_text_event_reported(event : String) -> void:
	$"%History".append_bbcode("\n" + event)

