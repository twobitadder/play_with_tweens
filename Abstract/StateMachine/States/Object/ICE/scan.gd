extends State

var scan_time := 0.0

func setup(object, machine) -> void:
	.setup(object, machine)
	state_name = "scan"

func process(delta) -> void:
	scan_time += delta
	if scan_time >= machine.object.speed / 10:
		if randf() < PlayerInfo.detect_chance:
			emit_signal("done", "query")
		else:
			emit_signal("done", "idle-active")
