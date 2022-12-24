extends Node

enum {
	BUFF_NONE,
	BUFF_SPEED,
}

enum {
	# no debuff
	DEBUFF_NONE,
	# debuff to speed
	DEBUFF_SPEED,
	DEBUFF_DAMAGE_OVER_DISTANCE,
	DEBUFF_DAMAGE_OVER_TIME
}

# The buff type that this mushroom will give
export var buff_type = BUFF_NONE
# The strength modifier of the buff -> this will depend on the buff type
# For example buff_type = BUFF_SPEED, buff_mod_strength = 2.0 will result in
# double speed 
export(float) var buff_mod_strength = 0.0

# The debuff type that this mushroom will give
export var debuff_type = DEBUFF_NONE
# The strength of the debuff -> this will depend on the debuff type
# For example debuff_type = DEBUFF_DAMAGE_OVER_DISTANCE
# In this case debuff_mod_strength would be the distance that the player would
# travel before receiving the debuff
# The secondary would then be how much damage the player received for this
# debuff
export(float) var debuff_mod_strength = 0.0
export(float) var debuff_mod_strength_secondary = 0.0

# this is the debuff that this mushroom will cure
export var debuff_cure = DEBUFF_NONE

# how many points is the mushroom worth
export(int) var points = 1000
