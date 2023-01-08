extends Control

onready var player = get_parent()

# auto load the item we are going to use for steps till death
onready var steps_till_death_preload = preload("res://HUD/StepsTillDeath.tscn")

var controls = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# go through the controls and set their positions
	for i in controls.size():
		controls[i].rect_position.y = (i * 16)
	pass


# add ui item for showing when the player is going to die
func on_mushroom_eaten(mushroom):
	var control = steps_till_death_preload.instance()
	control.mushroom = mushroom
	if mushroom.sprite_resource != "":
		control.get_node("Skull").texture = load(mushroom.sprite_resource)
	add_child(control)
	controls.append(control)

# remove the ui item for the cured mushroom
func on_mushroom_cured(mushroom):
	# remove the control that contains the mushroom
	for i in controls.size():
		var control = controls[i]
		if control.mushroom == mushroom:
			controls.remove(i)
			control.queue_free()
			return # mushroom should never be duplicated onto more than one control
