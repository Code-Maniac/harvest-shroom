extends KinematicBody2D

# export variables
export(float) var max_health = 1000.0 setget set_max_health, get_max_health
var health = max_health setget set_health, get_health
export(float) var max_speed = 120.0 setget set_max_speed, get_max_speed
export(float) var acceleration = 360.0 setget set_acceleration, get_acceleration
export(float) var friction = 480.0

# camera rotation vars
export(float) var max_camera_rot_acceleration = 30.0
export(float) var max_camera_rot_speed = 50.0
export(float) var camera_rot_return_speed = 30.0
var camera_approach_angle = 0.0
onready var camera = get_node("/root/World/Camera")

var velocity = Vector2.ZERO

# The mushroom that is currently being eaten.
# When the eat state ends this is then processed and moved to the mushrooms
# With any buffs and debuffs being applied.
var eaten_mushroom = null
# player starts having eaten zero mushrooms
var mushrooms = []

onready var death_effect_preload = preload("res://Effects/DeathEffect.tscn")

enum {
	STATE_MOVING,
	STATE_EATING,
	STATE_DYING,
	STATE_WIN
}
export(int,
	"Moving",
	"Eating",
	"Dying") var start_state = STATE_MOVING
onready var state = start_state

onready var animPlayer = $AnimationPlayer
onready var animTree = $AnimationTree
onready var animState = $AnimationTree.get("parameters/playback")
var blend_anims = [
	"Idle",
	"Walk",
	"Eat"
]

var hud = null

# onready var camera = get_node("/root/World/Camera2D")
# onready var camera_transform = $RemoteTransform2D

var rng = RandomNumberGenerator.new()

var points = 0

signal mushroom_eaten(mushroom)
signal mushroom_cured(mushroom)

# The entire concept of this game is to harvest mushrooms
# but picking mushrooms will do certain things.
# What can we have for different mushrooms
# We will have mushrooms that give difference buffs + side effects
# Some will cure the side effects of other mushrooms
# side effect type
# 1. Fuck with controls
# 2. Make the player faster / slower
# 3. 


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize( )

	hud = $CanvasLayer.get_node("HUD")
	if hud != null:
		var _tmp = connect("mushroom_eaten", hud, "on_mushroom_eaten")
		_tmp = connect("mushroom_cured", hud, "on_mushroom_cured")

	$RemoteTransform2D.remote_path = "/root/World/Camera"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		STATE_MOVING:
			_state_moving(delta)
		STATE_EATING:
			_state_eating(delta)
		STATE_DYING:
			_state_dying(delta)
		STATE_WIN:
			_state_win(delta)

	# if mushrooms.size() > 0:
	# 	_fuck_with_camera(delta)
	# else:
	# 	_reset_camera(delta)

func _state_moving(delta):
	var left = Input.get_action_strength("ui_left");
	var right = Input.get_action_strength("ui_right")
	var up = Input.get_action_strength("ui_up")
	var down = Input.get_action_strength("ui_down")
	var input_vector = Vector2(right - left, down - up).normalized()

	if input_vector != Vector2.ZERO:
		# we are moving
		_set_blend_position(input_vector)
		animState.travel("Walk")
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		# we are idle
		animState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	velocity = move_and_slide(velocity)

	_handle_mushrooms(velocity.length() * delta)

func _state_eating(_delta):
	# all we do here is set the eating animation
	# when the eating animation ends it will set the state back to moving
	animState.travel("Eat")
	pass

func _state_dying(_delta):
	# all we do here is set the dying animation here
	# when the dying animation finishes the player is freed and the level will
	# restart with the player respawning
	animState.travel("Dying")

	# var death_effect = death_effect_preload.instance()
	# get_parent().add_child(death_effect)
	# death_effect.global_position = global_position
	# queue_free()

func _state_win(_delta):
	# all we are doing here is waiting for the win animation to finish
	# then 
	velocity = Vector2.ZERO
	# animState.travel("Win")
	pass

func _set_blend_position(blend_pos):
	for item in blend_anims:
		animTree.set("parameters/" + item + "/blend_position", blend_pos)

# func _fuck_with_camera(delta):
# 	camera_rot_velocity.move_toward(Vector2(rng.randf_range(-5, 5), 0),  max_camera_rot_acceleration)
# 	print(camera_rot_velocity)
# 	camera_transform.rotation_degrees = camera_rot_velocity.length() * 45
# 	# var rot = camera_transform.rotation_degrees
# 	# rot += rng.randf_range(-5, +5)
# 	# rot = clamp(rot, -45, 45)
# 	# camera_transform.rotation_degrees = rot

# func _reset_camera(delta):
# 	camera_transform_approach
# 	camera_rot_velocity.move_toward(Vector2.ZERO, delta * camera_rot_return_speed)


func set_health(val):
	health = val
	if health > max_health:
		health = max_health
	elif health <= 0:
		# we have died
		state = STATE_DYING
	
func get_health():
	return health

func set_max_health(val):
	max_health = val

func get_max_health():
	# apply max health modifiers and return
	return max_health

func set_max_speed(val):
	max_speed = val

func get_max_speed():
	# apply max speed modifiers and return
	return max_speed

func set_acceleration(val):
	acceleration = val

func get_acceleration():
	# apply acceleration modifiers and return
	return acceleration

func _on_MushroomDetector_area_entered(area:Area2D):
	# the area defines a mushroom.
	# we need to get the mushrooms stats from the mushroom
	# and eat it
	# then free the area
	_eat_mushroom(area)
	area.queue_free()
	pass

func _eat_mushroom(mushroom):
	# what we do with the mushroom will depend on the type
	eaten_mushroom = mushroom.get_node("MushroomStats").duplicate()
	state = STATE_EATING
	velocity = Vector2.ZERO

func _handle_mushrooms(distance_moved):
	for mushroom in mushrooms:
		if mushroom.debuff == Debuff.DEATH_OVER_DISTANCE:
			mushroom.distance_moved += distance_moved

func _cure_debuffs(cure):
	if cure == DebuffType.NONE:
		pass
	elif cure == DebuffType.ALL:
		# cure all the mushrooms effects and clear them all
		for mushroom in mushrooms:
			emit_signal("mushroom_cured", mushroom)
			mushroom.queue_free()

		mushrooms.clear()
	else:
		# remove any mushroom where the cure matches the type
		var new_array = []
		for mushroom in mushrooms:
			if cure != mushroom.debuff_type:
				new_array.append(mushroom)
			else:
				emit_signal("mushroom_cured", mushroom)
				mushroom.queue_free()

		mushrooms = new_array

func eating_animation_finished():
	state = STATE_MOVING

	_cure_debuffs(eaten_mushroom.debuff_cure)
	eaten_mushroom.active = true
	if eaten_mushroom.debuff != Debuff.NONE:
		mushrooms.append(eaten_mushroom)
		eaten_mushroom.connect("expired", self, "_on_mushroom_debuff_expired")
		emit_signal("mushroom_eaten", eaten_mushroom) # don't emit this if NONE
	eaten_mushroom = null

func _on_mushroom_debuff_expired(debuff, strength):
	match debuff:
		Debuff.DEATH_OVER_DISTANCE:
			# we die if we ever get this effect
			state = STATE_DYING


func _on_LevelEndDetector_area_entered(area:Area2D):
	state = STATE_WIN
	print("LEVEL END")
	get_node("/root/World/SceneTransition").next_scene()
	# get_node("/root/World").set_next_level() 
	# we then want to set the animation then wait for the celebration animation
	# to end
	# then change the level
	# maybe have a transition animation - ala fade out / fade in

func death_animation_finished():
	queue_free()
	get_node("/root/World/SceneTransition").reload_scene()