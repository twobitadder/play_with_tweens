extends Node2D
class_name MapRoom

enum TYPE { ENTRANCE, DATA, IO, SECURITY, HEART, MIND }

export (Dictionary) var color_coding = {
	TYPE.ENTRANCE : Color.green,
	TYPE.DATA : Color.blue,
	TYPE.IO : Color.yellow,
	TYPE.SECURITY : Color.purple,
	TYPE.HEART : Color.orange,
	TYPE.MIND : Color.red
}

var type setget set_type
#steps from the entrance, or depth it exists on the tree.
var steps := 0

#everything inside of the room
var objects := []


#a particular room in the server dungeon should (for now) PROBABLY
#only have one parent, but multiple children is ok
#for more interesting generation in the future, perhaps a method to 
#share children for items on the same level might be good
var parents := []
var children := []

func set_type(value) -> void:
	type = value
	$Sprite.material.set_shader_param("replace_color", color_coding[type])

func add_tree_parent(parent) -> bool:
	for potential in parents:
		if potential.get_ref() == parent:
			return false
	
	parents.append(weakref(parent))
	parent.add_tree_child(self)
	steps = parent.steps + 1
	return true

func add_tree_child(child) -> void:
	for potential in children:
		if potential.get_ref() == child:
			return
	
	children.append(weakref(child))

func has_parent(room) -> bool:
	for potential in parents:
		if potential.get_ref() == room:
			return true
	
	return false

func has_child(room) -> bool:
	for potential in children:
		if potential.get_ref() == room:
			return true
	
	return false
