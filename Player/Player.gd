extends KinematicBody2D

# export variables
export(float) var max_health = 1000.0 setget set_max_health, get_max_health
var health = max_health setget set_health, get_health
export(float) var max_speed = 120.0 setget set_max_speed, get_max_speed
export(float) var acceleration = 360.0 setget set_acceleration, get_acceleration
export(float) var friction = 480.0

var velocity = Vector2.ZERO
var distance_moved = 0.0

# The mushroom that is currently being eaten.
# When the eat state ends this is then processed and moved to the mushrooms
# With any buffs and debuffs being applied.
var eaten_mushroom = null
# player starts having eaten zero mushrooms
var mushrooms = []

enum {
	STATE_MOVING,
	STATE_EATING
	STATE_DYING
}
var state = STATE_MOVING

onready var animPlayer = $AnimationPlayer
onready var animTree = $AnimationTree
onready var animState = $AnimationTree.get("parameters/playback")

var blend_anims = [
	"Idle",
	"Walk",
	"Eat"
]

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
	add_to_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# print(state)
	match state:
		STATE_MOVING:
			_state_moving(delta)
		STATE_EATING:
			_state_eating(delta)
		STATE_DYING:
			_state_dying(delta)

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
	distance_moved += (velocity.length() * delta)

func _state_eating(delta):
	# all we do here is set the eating animation
	# when the eating animation ends it will set the state back to moving
	animState.travel("Eat")
	pass

func _state_dying(delta):
	# all we do here is set the dying animation here
	# when the dying animation finishes the player is freed and the level will
	# restart with the player respawning
	animState.travel("Die")
	pass

func _set_blend_position(blend_pos):
	for item in blend_anims:
		animTree.set("parameters/" + item + "/blend_position", blend_pos)

func eat_mushroom(mushroom):
	# what we do with the mushroom will depend on the type
	eaten_mushroom = mushroom.get_node("MushroomStats")
	state = STATE_EATING
	velocity = Vector2.ZERO


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
	eat_mushroom(area)
	area.queue_free()
	pass

func eating_animation_finished():
	state = STATE_MOVING
