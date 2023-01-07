extends Node2D

onready var player_preload = preload("res://Player/Player.tscn")
onready var ysort = get_node("/root/World/Level/YSort")

# Called when the node enters the scene tree for the first time.
func _ready():
	# spawn a player here.
	# then if the player dies
	# wait for a period of time before spawning another player
	# there should only ever be one level start at a time
	var player = player_preload.instance()
	player.global_position = global_position
	ysort.add_child(player)
	# get the ysort
	pass # Replace with function body.

func _get_level_ysort():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
