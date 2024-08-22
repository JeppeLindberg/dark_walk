extends DirectionalLight3D

var target_energy = 0.2




func _process(delta: float) -> void:
	if light_energy > target_energy:
		light_energy = max(target_energy, light_energy - delta * 0.05)
	elif light_energy < target_energy:
		light_energy = min(target_energy, light_energy + delta * 0.05)

