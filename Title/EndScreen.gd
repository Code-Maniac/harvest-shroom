extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# go back to the title screen if the user presses ui_accept
	if Input.is_action_just_pressed("ui_accept"):
		get_node("/root/World/SceneTransition").next_scene()
		queue_free()
