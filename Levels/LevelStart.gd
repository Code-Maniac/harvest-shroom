extends Node2D

onready var player_preload = preload("res://Player/Player.tscn")
onready var ysort = get_node("/root/" + get_tree().current_scene.name + "/YSort")

# Called when the node enters the scene tree for the first time.
func _ready():
	# spawn a player here.
	# then if the player dies
	# wait for a period of time before spawning another player
	# there should only ever be one level start at a time
	var player = player_preload.instance()
	# get the ysort
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
