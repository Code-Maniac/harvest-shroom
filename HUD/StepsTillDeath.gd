extends Control


onready var progress_bar = $ProgressBar
onready var steps_remaining = $StepsRemaining
var progress_bar_max_width = 228

# mushroom must be mushroom stats
var mushroom = null

# func _ready():
# 	var theme = steps_remaining.get_theme()
# 	var newfont = load('res://PublicPixel-z84yD.ttf')
# 	theme.set_font(newfont)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mushroom == null:
		queue_free()
		pass

	print(mushroom.sprite_resource)
	if $Skull.texture.resource_path != mushroom.sprite_resource and mushroom.sprite_resource != "":
		$Skull.texture = load(mushroom.sprite_resource)

	progress_bar.set_size(Vector2(228 * mushroom.get_distance_remaining_ratio(), 16))
	steps_remaining.text = str(int(mushroom.get_distance_remaining()))

func on_mushroom_destroyed():
	# once the mushroom has died this is no longer valid
	queue_free()
