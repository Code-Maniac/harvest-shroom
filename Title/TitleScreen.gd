extends Node2D

var background = null
var foreground = null
onready var title_text = $TitleText/Sprite
onready var bill = $Bill

var title_text_wobble = 1 / (2 * PI)

var rng = RandomNumberGenerator.new()
var start_scale_background = 1.0 + rng.randf_range(0, 0.01)
var start_scale_foreground = 1.0 + rng.randf_range(0, 0.01)

# Called when the node enters the scene tree for the first time.
func _ready():
	background = $Background/Sprite
	foreground = $Foreground/Sprite

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_node("/root/World/SceneTransition").next_scene()
		pass

	var sin_ticks = sin(float(OS.get_ticks_msec()) / 1000)
	var cos_ticks = cos(float(OS.get_ticks_msec()) / 1000)

	# trippy effects on background and foreground
	var background_scale = 1.01 + (0.01 * sin_ticks)
	background.scale = Vector2(background_scale, background_scale)

	var foreground_scale = 1.01 + (0.01 * cos_ticks)
	foreground.scale = Vector2(foreground_scale, foreground_scale)

	# title_text.rotation = title_text_wobble * sin_ticks
	# title_text.scale = Vector2(0.75 * background_scale, 0.75 * background_scale)

func _on_Timer_timeout():
	$StartLabel.visible = !$StartLabel.visible

