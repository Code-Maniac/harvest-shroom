extends Area2D

# func _ready():
	# print(collision_mask)
	# self.connect("area_entered", self, "_on_NextLevel_area_entered")

func _on_NextLevel_area_entered(_area:Area2D):
	# go to the next level
	var current_scene_idx = int(get_tree().current_scene.name)
	get_node("/root/World").set_level("res://Levels/Level" + str(current_scene_idx) + ".tscn") 
