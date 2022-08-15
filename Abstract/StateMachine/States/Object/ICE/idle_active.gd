extends State

var scan_check := 0.0

func setup(object, machine) -> void:
	.setup(object, machine)
	state_name = "idle-active"

func process(delta) -> void:
	scan_check += delta
	if scan_check >= machine.object.speed:
		scan_check = 0.0
		if PlayerInfo.grid_pos == WorldState.server.ice[machine.object]:
			emit_signal("done", "scan")
