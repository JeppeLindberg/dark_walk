extends Area3D

@export var target_energy = 0.2

@onready var sun = get_node('/root/main/sun')

func _on_body_entered(body:Node3D) -> void:
	sun.target_energy = target_energy
