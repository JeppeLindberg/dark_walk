extends Node3D


@export var line_radius = 0.05
@export var line_resoultion = 12
@export var beam_speed = 2;

func _ready():
	var circle = []
	for degree in line_resoultion:
		var x = line_radius * sin(PI * 2 * degree / line_resoultion)
		var y = line_radius * cos(PI * 2 * degree / line_resoultion)
		var coords = Vector2(x,y)
		circle.append(coords)
	$polygon.polygon = circle
