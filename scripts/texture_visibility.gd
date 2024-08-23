extends TextureRect

@export var target_visibility = 1

func _process(delta: float) -> void:
	if modulate.a > target_visibility:
		modulate.a = max(target_visibility, modulate.a - delta * 0.5)
	elif modulate.a < target_visibility:
		modulate.a = min(target_visibility, modulate.a + delta * 0.5)

func _on_wasd_dimmer_body_entered(node: Node3D, new_target_visibility: float):
	target_visibility = new_target_visibility
