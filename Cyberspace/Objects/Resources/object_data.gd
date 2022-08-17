extends Resource
class_name ObjectData

var state_machine = preload("res://Abstract/StateMachine/state_machine.gd")

signal change_status(status, color)
signal change_state(state, color)
signal update_meter(value)
signal spoof_received
signal depleted

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
export (float) var query_time
export (bool) var can_move
export (Array) var valid_actions
export (Vector2) var grid_position 
export (bool) var is_placated = false
export (bool) var is_active = true
export (bool) var is_suspicious

var integrity : float setget set_integrity
var interaction
var interacting := false
var machine : StateMachine

##################
#DEBUG VARIABLES
##################
var i
var room
##################
#END DEBUG VARS
##################

func create(server_strength : float, _type := -1) -> void:
	if _type != -1:
		type = _type
	else:
		#data should be specifically spawned and kept in data rooms
		#kill, trace, and cook should be response ICE
		type = randi() % 4
	
	var base_states := []
	
	match type:
		TYPE.GATEWAY:
			name = "Gateway Daemon %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_green_diamond.png")
			action_started_color = Color.green
			action_completed_color = Color.orange
			strength = 10.0
			max_integrity = 1.0
			speed = 0.9
			query_time = 2.5
			status = "OK"
			can_move = false
			is_suspicious = false
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
			base_states = [load("res://Abstract/StateMachine/States/Object/ICE/idle_active.gd").new(),
			load("res://Abstract/StateMachine/States/Object/ICE/scan.gd").new(), load("res://Abstract/StateMachine/States/Object/ICE/query.gd").new(),
			load("res://Abstract/StateMachine/States/Object/ICE/activate.gd").new(), load("res://Abstract/StateMachine/States/Object/ICE/hunt.gd").new()]
		TYPE.MONITOR:
			name = "Monitor Daemon %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_blue_diamond.png")
			action_started_color = Color.green
			action_completed_color = Color.orange
			strength = 10.0
			max_integrity = 1.0
			speed = 0.9
			query_time = 2.5
			status = "OK"
			can_move = true
			is_suspicious = false
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
			base_states = [load("res://Abstract/StateMachine/States/Object/ICE/idle_active.gd").new(),
			load("res://Abstract/StateMachine/States/Object/ICE/scan.gd").new(), load("res://Abstract/StateMachine/States/Object/ICE/query.gd").new(),
			load("res://Abstract/StateMachine/States/Object/ICE/activate.gd").new(), load("res://Abstract/StateMachine/States/Object/ICE/hunt.gd").new()]
		TYPE.PROXY:
			name = "Proxy Daemon %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_grey_diamond.png")
			action_started_color = Color.green
			action_completed_color = Color.orange
			strength = 10.0
			max_integrity = 1.0
			speed = 0.9
			query_time = 2.5
			status = "OK"
			can_move = true
			is_suspicious = false
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
			base_states = [load("res://Abstract/StateMachine/States/Object/ICE/idle_active.gd").new(),
			load("res://Abstract/StateMachine/States/Object/ICE/scan.gd").new(), load("res://Abstract/StateMachine/States/Object/ICE/query.gd").new(),
			load("res://Abstract/StateMachine/States/Object/ICE/activate.gd").new(), load("res://Abstract/StateMachine/States/Object/ICE/hunt.gd").new()]
		TYPE.SENTRY:
			name = "Sentry Daemon %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_red_diamond.png")
			action_started_color = Color.green
			action_completed_color = Color.orange
			strength = 10.0
			max_integrity = 1.0
			speed = 0.9
			query_time = 2.5
			status = "OK"
			can_move = true
			is_suspicious = false
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
			base_states = [load("res://Abstract/StateMachine/States/Object/ICE/idle_active.gd").new(),
			load("res://Abstract/StateMachine/States/Object/ICE/scan.gd").new(), load("res://Abstract/StateMachine/States/Object/ICE/query.gd").new(),
			load("res://Abstract/StateMachine/States/Object/ICE/activate.gd").new(), load("res://Abstract/StateMachine/States/Object/ICE/hunt.gd").new()]
		TYPE.DATA:
			name = "Data File %X" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_blue_square.png")
			action_started_color = Color.yellow
			action_completed_color = Color.blue
			strength = 10.0
			max_integrity = 1.0
			speed = 0.9
			query_time = 2.5
			status = "ENCRYPTED"
			can_move = false
			is_suspicious = false
			interaction = funcref(self, "get_decrypted")
			valid_actions = [PlayerInfo.ATTACK_TYPE.ANALYZE, PlayerInfo.ATTACK_TYPE.DECRYPT, PlayerInfo.ATTACK_TYPE.DOWNLOAD]
			base_states = []
		TYPE.KILL:
			name = "Kill Countermeasure %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_yellow_polygon.png")
			action_started_color = Color.green
			action_completed_color = Color.red
			strength = 10.0
			max_integrity = 1.0
			speed = 0.9
			query_time = 2.5
			status = "OK"
			can_move = true
			is_suspicious = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
			base_states = []
		TYPE.TRACE:
			name = "Trace Countermeasure %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_red_polygon.png")
			action_started_color = Color.green
			action_completed_color = Color.red
			strength = 10.0
			max_integrity = 1.0
			speed = 0.9
			query_time = 2.5
			status = "OK"
			can_move = true
			is_suspicious = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
			base_states = []
		TYPE.COOK:
			name = "Cook Countermeasure %d" % (randi() % 10000)
			appearance = load("res://Assets/Objects/element_purple_polygon.png")
			action_started_color = Color.yellow
			action_completed_color = Color.red
			strength = 10.0
			max_integrity = 1.0
			speed = 0.9
			query_time = 2.5
			status = "OK"
			can_move = true
			is_suspicious = true
			interaction = funcref(self, "take_damage")
			valid_actions = [PlayerInfo.ATTACK_TYPE.SPOOF, PlayerInfo.ATTACK_TYPE.FUZZ, PlayerInfo.ATTACK_TYPE.DISABLE]
			base_states = []

	machine = state_machine.new()
	machine.setup(self, base_states)
	TimeKeeper.connect("pass_time", self, "_on_pass_time")
	emit_signal("change_status", status, Color.green)
	integrity = max_integrity
	if type != TYPE.DATA:
		machine.change_state("idle-active")

func _on_pass_time(time_passed : float) -> void:
	if !is_active:
		return
	machine.process(time_passed)
	if interacting:
		interaction.call_func(time_passed)

func take_damage(time_passed : float) -> void:
	self.integrity -= time_passed
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

func set_integrity(value) -> void:
	integrity = value
	if integrity <= 0.0:
		emit_signal("depleted")

func interact(action : int) -> void:
	interacting = true

func update_state(state_name) -> void:
	emit_signal("change_state", state_name, Color.white)

func destruct() -> void:
	pass
#	machine.disconnect("state_entering", self, "update_state")
#	machine = null
#	TimeKeeper.disconnect("pass_time", self, "_on_pass_time")
