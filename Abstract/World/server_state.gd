extends Resource
class_name ServerState

export var min_size := 5
export var max_size := 15
export var max_iterations := 100
export var interconnectedness := .65
export var has_heart := true
export var has_mind := true
export var server_strength := 1.0
export var traverse_cost := 0.1
export var num_ice := 10
export var num_data := 20
export var rooms := {}
export var ice := {}

var placed_heart := false
var placed_mind := false
