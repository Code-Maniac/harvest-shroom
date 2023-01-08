extends Node2D

export(String) var first_level = "res://Levels/Level1.tscn"
var title_level = "res://Title/TitleScreen.tscn"
var credits_level = "res://Title/EndScreen.tscn"
var current_level = ""

func _ready():
	load_title_level()

func reload_level():
	var level_name = get_node("Level").filename
	set_level(level_name)

func set_next_level():
	var next_level = ""
	if current_level == title_level:
		next_level = first_level
	elif current_level == credits_level:
		next_level = title_level
	else:
		var level_name = get_node("Level").filename
		next_level = "res://Levels/Level" + str(int(level_name) + 1) + ".tscn"

	set_level(next_level)

func load_title_level():
	var level = load(title_level)

	if level != null:
		add_child(level.instance())
		current_level = title_level

func load_credits_level():
	var level = load(credits_level)

	if level != null:
		add_child(level.instance())
		current_level = credits_level

func set_level(res_path):
	var existing_level = get_node("Level")
	if existing_level != null:
		existing_level.queue_free()
		remove_child(existing_level)

	current_level = res_path
	var file = File.new()
	var exists = file.file_exists(current_level)

	var level = null
	if exists:
		level = load(current_level)

	if level != null:
		add_child(level.instance())
	else:
		load_credits_level()

	set_camera_zoom()

func set_camera_zoom():
	if current_level == title_level or current_level == credits_level:
		get_node("Camera").position = Vector2(160, 90)
		get_node("Camera").zoom = Vector2(1, 1)
	else:
		get_node("Camera").zoom = Vector2(1.25, 1.25)
