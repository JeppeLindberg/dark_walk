extends OmniLight3D

@export var curve:Curve
@export var speed:float = 1

@onready var main = get_node("/root/main")
@onready var time_modifier = randf_range(0, 10)
@onready var base_range = omni_range

var energy_modifier = 1

func _process(delta):
	var t = (main.curr_secs() + time_modifier) * speed
	t = t - int(t);
	var point = curve.sample(t)
	omni_range = point * base_range * energy_modifier
