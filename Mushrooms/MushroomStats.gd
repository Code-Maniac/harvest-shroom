extends Node

enum {
	BUFF_NONE,
	BUFF_SPEED,
}

enum {
	TYPE_NONE, # type none is for mushrooms that cure nothing
	TYPE_WHITE,
	TYPE_RED,
	TYPE_GREEN,
	TYPE_BLUE,
	TYPE_PURPLE,
	TYPE_YELLOW,
	TYPE_CYAN,
	TYPE_BLACK
}

# The buff type that this mushroom will give
export var buff = BUFF_NONE
# The strength modifier of the buff -> this will depend on the buff type
# For example buff_type = BUFF_SPEED, buff_mod_strength = 2.0 will result in
# double speed 
export(float) var buff_mod_strength = 0.0

# The debuff type that this mushroom will give
export var debuff = Debuff.DEATH_OVER_DISTANCE
# The strength of the debuff -> this will depend on the debuff type
# For example debuff_type = DEBUFF_DAMAGE_OVER_DISTANCE
# In this case debuff_mod_strength would be the distance that the player would
# travel before receiving the debuff
# The secondary would then be how much damage the player received for this
# debuff
export(float) var debuff_mod_strength = 0.0
export(float) var debuff_mod_strength_secondary = 0.0

# type / type that it cures
export var debuff_type = TYPE_WHITE
export var debuff_cure = TYPE_NONE

# how many points is the mushroom worth
export(int) var points = 1000

var distance_moved = 0.0 setget set_distance

var active = false

signal expired(debuff)

func set_distance(val):
	distance_moved = val
	if debuff == Debuff.DEATH_OVER_DISTANCE and distance_moved >= debuff_mod_strength:
		print("DEATH")
		emit_signal("expired", debuff, debuff_mod_strength)
