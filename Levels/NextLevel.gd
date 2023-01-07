extends Node2D

func _on_Area2D_area_entered(area):
	# go to the next level
	var current_scene_idx = int(get_tree().current_scene.name)
	get_tree().change_scene("res://Levels/Level" + str(current_scene_idx) + ".tscn") 
