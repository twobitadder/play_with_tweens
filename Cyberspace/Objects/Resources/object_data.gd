extends Resource
class_name ObjectData

signal change_status(status, color)
signal update_meter(value)

enum TYPE { GATEWAY, MONITOR, PROXY, SENTRY, DATA, KILL, TRACE, COOK}

export (TYPE) var type
export (Texture) var appearance
export (String) var name
export (String) var status
export (Color) var action_started_color
export (Color) var action_completed_color
export (float) var strength
export (float) var max_integrity
export (float) var speed
export (bool) var can_move
export (Array) var valid_actions

var integrity : float
var interaction
var interacting := false

func create(server_strength : float, _type := -1) -> void:
	if _type != -1:
		type = _type
	else:
		#data should be specifically spawned and kept in data rooms
		#kill, trace, and cook should be response ICE
		type = randi() % 4
	
	match type:
		TYPE.GATEWAY:
			name = "Gateway Daemon %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_green_diamond.png")
			action_started_color = Color.green
			action_completed_color = Color.orange
			strength = 10.0
			max_integrity = 20.0
			speed = 0.9
			status = "OK"
			can_move = false
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
		TYPE.MONITOR:
			name = "Monitor Daemon %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_blue_diamond.png")
			action_started_color = Color.green
			action_completed_color = Color.orange
			strength = 10.0
			max_integrity = 20.0
			speed = 0.9
			status = "OK"
			can_move = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
		TYPE.PROXY:
			name = "Proxy Daemon %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_grey_diamond.png")
			action_started_color = Color.green
			action_completed_color = Color.orange
			strength = 10.0
			max_integrity = 20.0
			speed = 0.9
			status = "OK"
			can_move = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
		TYPE.SENTRY:
			name = "Sentry Daemon %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_red_diamond.png")
			action_started_color = Color.green
			action_completed_color = Color.orange
			strength = 10.0
			max_integrity = 20.0
			speed = 0.9
			status = "OK"
			can_move = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
		TYPE.DATA:
			name = "Data File %X" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_blue_square.png")
			action_started_color = Color.yellow
			action_completed_color = Color.blue
			strength = 10.0
			max_integrity = 20.0
			speed = 0.9
			status = "ENCRYPTED"
			can_move = false
			interaction = funcref(self, "get_decrypted")
			valid_actions = [PlayerInfo.ATTACK_TYPE.ANALYZE, PlayerInfo.ATTACK_TYPE.DECRYPT, PlayerInfo.ATTACK_TYPE.DOWNLOAD]
		TYPE.KILL:
			name = "Kill Countermeasure %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_yellow_polygon.png")
			action_started_color = Color.green
			action_completed_color = Color.red
			strength = 10.0
			max_integrity = 20.0
			speed = 0.9
			status = "OK"
			can_move = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
		TYPE.TRACE:
			name = "Trace Countermeasure %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_red_polygon.png")
			action_started_color = Color.green
			action_completed_color = Color.red
			strength = 10.0
			max_integrity = 20.0
			speed = 0.9
			status = "OK"
			can_move = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
		TYPE.COOK:
			name = "Cook Countermeasure %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_purple_polygon.png")
			action_started_color = Color.yellow
			action_completed_color = Color.red
			strength = 10.0
			max_integrity = 20.0
			speed = 0.9
			status = "OK"
			can_move = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
	
	TimeKeeper.connect("pass_time", self, "_on_pass_time")
	emit_signal("change_status", status, Color.green)
	integrity = max_integrity

func _on_pass_time(time_passed : float) -> void:
	if interacting:
		interaction.call_func(time_passed)

func take_damage(time_passed : float) -> void:
	print(time_passed)
	integrity -= time_passed
	print(integrity)
	emit_signal("update_meter", range_lerp(integrity, max_integrity, 0.0, 0.0, 100.0))
	if integrity < 12 && integrity > 6:
		status = "COMPROMISED"
		emit_signal("change_status", status, Color.yellow)
	elif integrity < 6:
		status = "FAILING"
		emit_signal("change_status", status, Color.red)

func get_decrypted(time_passed : float) -> void:
	integrity -= time_passed
	emit_signal("update_meter", range_lerp(integrity, max_integrity, 0.0, 0.0, 100.0))
	if integrity < 12 && integrity > 6:
		status = "UNPROTECTED"
		emit_signal("change_status", status, Color.yellow)
	elif integrity < 6:
		status = "DOWNLOADING"
		emit_signal("change_status", status, Color.red)

func interact(action : int) -> void:
	PlayerInfo.set_interacting(action)
	interacting = true