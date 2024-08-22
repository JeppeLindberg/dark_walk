extends Node3D

@onready var flicker = get_node('./flicker/light')
@onready var light_mesh = get_node('./light_mesh')

@export var start_enabled = true;
@export var modify_speed = 0.5;

var target_energy = 1

func _ready():
	if not start_enabled:
		target_energy = 0

func _process(delta):
	if flicker.energy_modifier > target_energy:
		flicker.energy_modifier = max(target_energy, flicker.energy_modifier - delta * modify_speed)
	elif flicker.energy_modifier < target_energy:
		flicker.energy_modifier = min(target_energy, flicker.energy_modifier + delta * modify_speed)
	
	if flicker.energy_modifier == 0.0:
		light_mesh.visible = false;
	else:
		light_mesh.visible = true;


func _on_player_detector_body_exited(body:Node3D) -> void:
	if not start_enabled:
		target_energy = 0

func _on_player_detector_body_entered(body:Node3D) -> void:
	if not start_enabled:
		target_energy = 1
