extends Node2D

signal move(direction)

var map_pos := Vector2.ZERO
var moving := false

func _process(_delta: float) -> void:
	update()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && !event.echo && !moving && !PlayerInfo.is_interacting:
			match event.physical_scancode:
				KEY_LEFT:
					emit_signal("move", Vector2.LEFT)
				KEY_RIGHT:
					emit_signal("move", Vector2.RIGHT)
				KEY_UP:
					emit_signal("move", Vector2.UP)
				KEY_DOWN:
					emit_signal("move", Vector2.DOWN)

func move(target) -> void:
	var tween = get_tree().create_tween()
	tween.connect("finished", self, "move_ready")
	var pending = tween.tween_property(self, "position", target, 0.25)
	pending.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()
	moving = true

func move_ready() -> void:
	moving = false

func _draw() -> void:
	draw_rect(
		Rect2(map_pos - Vector2(40, 40), Vector2(80, 80)),
		Color.gold,
		false,
		3.0
	)
