extends MeshInstance3D


func _ready():
	visible = false

func _on_player_detector_body_exited(body:Node3D) -> void:
	visible = false

func _on_player_detector_body_entered(body:Node3D) -> void:
	visible = true
