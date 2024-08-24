extends AudioStreamPlayer3D


var turning_down = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if turning_down:
		volume_db -= delta * 10;


func _on_victory_body_entered(body:Node3D) -> void:
	turning_down = true
