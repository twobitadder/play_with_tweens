extends State

var scan_check := 0.0

func setup(object, machine) -> void:
	.setup(object, machine)
	state_name = "idle-active"

func process(delta) -> void:
	scan_check += delta
	if scan_check >= get_object().speed:
		scan_check = 0.0
		if !WorldState.server.ice.has(get_object()):
			print(get_object().get_incoming_connections())
			print(WorldState.server.ice)
			assert(WorldState.server.ice.has(get_object()))
		if PlayerInfo.grid_pos == WorldState.server.ice[get_object()]:
			emit_signal("done", "scan")
