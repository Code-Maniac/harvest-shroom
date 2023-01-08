extends KinematicBody2D

# whether or not the bird frees itself on reaching the end of the flight path
# or if it stick around and stay at the very end
export(bool) var free_on_end_path = false
export(bool) var will_fly = true

# The initial blend position - negative for left facing, positive for right facing
export(float) var initial_blend_position = -1
var blend_position = 0

# values to define the speed of the bird when it flys away, so that it doesn't
# fly in a really static way from a to b
export(float) var max_speed = 300
export(float) var fly_acceleration = 200
export(float) var fly_decceleration = 200

var fly_direction = Vector2.ZERO

# The flight path is the flight the bird takes when flying to it's next
# destination
# onready var flight_path = $FlightPath
# onready var flight_path_origin = flight_path.global_position
# The chirp timer will set the bird to chirp at random time's while in the idle
# state
onready var chirp_timer = $ChirpTimer
# The idle dir timer will change the direction of the bird at random time's
# while in the idle state
onready var idle_dir_timer = $IdleDirTimer
onready var anim_player = $AnimationPlayer
onready var anim_tree = $AnimationTree
onready var anim_state = $AnimationTree.get("parameters/playback")
var blend_anims = [
	"Idle",
	"Chirp",
	"TakeOff",
	"Fly",
	"Land"
]

enum {
	STATE_IDLE,
	STATE_FLY
}
var state = STATE_IDLE
var fly_index = 0
var velocity = Vector2.ZERO

# random number generator  used for random timings and blend_position
var rng = RandomNumberGenerator.new()

onready var color_sprite = $ColorSprite
# random colours that the bird can be -> need colours from the palette
var palette_colors = [
	Color(0, 0, 0),
	Color("#99e550"),
	Color("#76428a"),
	Color("#5fcde4"),
	Color("#ac3232"),
	Color("#3f3f74")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	# set the chirp_timer to a random time and start it
	# set the idle_dir_timer to a random time a start it
	# set the position of the bird to the first position in the flight_path
	_set_blend_position(initial_blend_position)
	rng.randomize()

	# set the bird to a random colour on the palette
	color_sprite.modulate = palette_colors[rng.randi_range(0, palette_colors.size() - 1)]
	anim_state.travel("Idle")

func _process(delta):
	match state:
		STATE_IDLE:
			_handle_idle(delta)
		STATE_FLY:
			_handle_fly(delta)

func _handle_idle(_delta):
	# we are idle so just make sure we aren't moving
	velocity = Vector2.ZERO
	pass

func _handle_fly(delta):
	# check that the bird has reached it's destination and if it has then we
	# go back to the idle state until the player once again enters the detector

	# var fly_position = flight_path_origin + flight_path.points[fly_index]
	# if global_position.distance_to(fly_position) < 3:
	# 	global_position = fly_position
	# 	_set_blend_position(0)
	# 	state = STATE_IDLE
	# else:
	# 	var dir = global_position.direction_to(fly_position)
	# 	velocity = velocity.move_toward(dir * max_speed, fly_acceleration * delta)
	# 	# global_position += velocity
	# 	velocity = move_and_slide(velocity)
		# _set_blend_position(velocity.x)

	velocity = velocity.move_toward(fly_direction * max_speed, fly_acceleration * delta)
	velocity = move_and_slide(velocity)

func _on_PlayerDetector_body_entered(_body:Node):
	# if flight_path.points.size() == 0 or state == STATE_IDLE:
	# 	pass

	if not will_fly:
		pass

	state = STATE_FLY
	fly_direction = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
	_set_blend_position(fly_direction.x * 30)
	anim_state.travel("Fly")
	# if there is as new point to fly to then fly to it
	# otherwise just remain in the idle state
	# var new_fly_index = clamp(fly_index + 1, 0, flight_path.points.size() - 1)
	# if new_fly_index > fly_index:
	# 	print("New fly index: " + str(fly_index))
	# 	fly_index = new_fly_index
	# 	state = STATE_FLY
	# 	anim_state.travel("Fly")
	# elif free_on_end_path:
	# 	# we have reached the end point (that is hopefully off screen)
	# 	# so free the bird as it's not need anymore
	# 	queue_free()

func _on_ChirpTimer_timeout():
	if state == STATE_IDLE:
		anim_state.travel("Chirp")

	chirp_timer.wait_time = rng.randf_range(1, 15)

func _on_IdleDirTimer_timeout():
	if state == STATE_IDLE:
		if blend_position >= 0:
			_set_blend_position(-1)
		else:
			_set_blend_position(1)

	idle_dir_timer.wait_time = rng.randf_range(3, 10)

func _set_blend_position(blend_pos):
	blend_position = clamp(blend_pos, -1, 1)
	for item in blend_anims:
		anim_tree.set("parameters/" + item + "/blend_position", blend_pos)

func chip_animation_finished():
	anim_state.travel("Idle")
