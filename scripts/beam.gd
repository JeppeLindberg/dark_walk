
extends Node3D

@export var line_radius = 0.05
@export var line_resoultion = 12
@export var beam_speed = 10;
@export var single_beam:PackedScene

@onready var main = get_node("/root/main")

var start_time = 0;
var beams = []
var total_length = 0.0;
var finished = false;

func start_beam(new_points):
	start_time = main.curr_secs();
	beams = [];

	for i in range(len(new_points)-1):
		var new_single_beam = single_beam.instantiate();
		self.add_child(new_single_beam);
		new_single_beam.global_position = Vector3.ZERO;
		var start_point = new_points[i];
		var end_point = new_points[i+1];
		var beam_length = start_point.distance_to(end_point);

		beams.append([beam_length, new_single_beam, start_point, end_point]);
		total_length += beam_length;

func _process(_delta: float):
	if finished:
		return;

	var elapsed_time = main.curr_secs() - start_time;
	var processed = elapsed_time * beam_speed;
	var accu_length = 0.0;

	for beam in beams:
		if (processed - accu_length) < 0:
			beam[1].visible = false;
			continue;

		beam[1].visible = true;

		var path = beam[1].get_node('path');
		path.curve = Curve3D.new();
		path.curve.add_point(beam[2]);
		path.curve.add_point(lerp(beam[2], beam[3], min((processed - accu_length) / beam[0], 1)));

		accu_length += beam[0];
	
	if accu_length > total_length:
		finished = true;