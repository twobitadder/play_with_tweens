extends State

var query_time := 0.0

func setup(object, machine) -> void:
	.setup(object, machine)
	state_name = "query"
	object.get_ref().connect("spoof_received", self, "_on_spoof_received")

func process(delta) -> void:
	query_time += delta
	if query_time >= get_object().query_time:
		var next
		if PlayerInfo.grid_pos == WorldState.server.ice[get_object()]:
			next = "activate"
		else:
			next = "hunt"
		emit_signal("done", next)

func _on_spoof_received() -> void:
	if machine.states.front() == state_name:
		get_object().is_placated = true
		emit_signal("done", "idle")
