extends Node2D

export(String) var first_level = "res://Levels/Level1.tscn" setget set_level
var current_level = ""

func _ready():
	set_level(first_level)

# func _load_level(res_path):
# 	var level = load(res_path)
# 	add_child()

func reload_level():
	var level_name = get_node("Level").filename
	set_level(level_name)

func set_next_level():
	var level_name = get_node("Level").filename
	var next_level = "res://Levels/Level" + str(int(level_name) + 1) + ".tscn"
	set_level(next_level)


func set_level(res_path):
	var existing_level = get_node("Level")
	if existing_level != null:
		existing_level.queue_free()
		remove_child(existing_level)

	current_level = res_path
	var level = load(current_level)

	if level != null:
		add_child(level.instance())
	else:
		print("Winner winner chicken dinner")
		# you've won the game - go to the credits scene
