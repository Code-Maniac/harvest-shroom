extends CanvasLayer

func reload_scene(type: String = 'dissolve') -> void:
	if type == 'dissolve':
		$AnimationPlayer.play('dissolve')
		yield($AnimationPlayer,'animation_finished')
		get_node("/root/World").reload_level() 
		$AnimationPlayer.play_backwards('dissolve')
	else:
		$AnimationPlayer.play('clouds_in')
		yield($AnimationPlayer,'animation_finished')
		get_node("/root/World").reload_level() 
		$AnimationPlayer.play('clouds_out')

func next_scene(type: String = 'dissolve') -> void:
	if type == 'dissolve':
		$AnimationPlayer.play('dissolve')
		yield($AnimationPlayer,'animation_finished')
		get_node("/root/World").set_next_level() 
		$AnimationPlayer.play_backwards('dissolve')
	else:
		$AnimationPlayer.play('clouds_in')
		yield($AnimationPlayer,'animation_finished')
		get_node("/root/World").set_next_level() 
		$AnimationPlayer.play('clouds_out')
