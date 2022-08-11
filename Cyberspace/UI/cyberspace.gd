extends Control

func _ready() -> void:
	$"%MiniMap".connect("room_entered", $"%RunUI", "_on_room_entered")

func update_history(event : String) -> void:
	$"%History".append_bbcode("\n" + event)
