extends Area3D


func _on_shooting_dimmer_2_body_entered(node: Node3D):
	self.queue_free()

