extends CharacterBody3D

@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 8
@export var beam:PackedScene

@export_subgroup("Weapon")
@export var weapon_sound_shoot: String  # Sound path
@export_range(0, 50) var weapon_knockback: int = 20  # Amount of knockback
@export_range(0.1, 1) var weapon_cooldown: float = 1  # Firerate
@export var crosshair:TextureRect
@export_flags_3d_physics var beam_collision_mask:int

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3 = Vector3(PI/16,PI/2,0)

var input_mouse: Vector2
var input_enabled = true;

var health:int = 100
var gravity := 0.0

var previously_floored := false

var jump_single := true
var jump_double := false

var tween:Tween

@onready var camera = $Head/Camera
@onready var sub_camera = $Head/Camera/SubViewportContainer/SubViewport/sub_camera
@onready var sound_footsteps = $SoundFootsteps
@onready var blaster_cooldown = $Cooldown
@onready var beams = get_node('/root/main/beams')
@onready var no_of_beams = get_node('/root/main/hud/white/CenterContainer/VBoxContainer/no_of_beams/number')
@onready var time_elapsed = get_node('/root/main/hud/white/CenterContainer/VBoxContainer/time_elapsed/number')
@onready var main = get_node('/root/main')

# Functions

func _ready():	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if not input_enabled:
		return;

	time_elapsed.text = secs_to_time(main.curr_secs())

func secs_to_time(secs: int) -> String:
	var minutes = int(secs / 60)
	var seconds = secs % 60
	return str(minutes) + " minutes " + str(seconds) + " seconds."

func _physics_process(delta):
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	if not input_enabled:
		return;
	
	# Movement

	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	
	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	# Movement sound
	
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
	
	# Landing after jump or falling
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	# Falling/respawning
	
	if position.y < -1000:
		get_tree().reload_current_scene()

	sub_camera.global_position = camera.global_position
	sub_camera.global_rotation = camera.global_rotation

# Mouse movement

func _input(event):
	if not input_enabled:
		return;

	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func handle_controls(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	if not input_enabled:
		return;
	
	# Mouse capture
	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	# Movement
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	# Rotation
	
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Shooting
	
	action_shoot()
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			jump_double = false
			
		if(jump_single): action_jump()
	
	if Input.is_action_just_pressed("reset"):
		for beam_instance in beams.get_children():
			beam_instance.queue_free()

# Handle gravity

func handle_gravity(delta):
	if not input_enabled:
		return;
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func action_jump():
	if not input_enabled:
		return;
	
	gravity = -jump_strength
	
	jump_single = false;
	jump_double = false;

# Shooting

func action_shoot():
	if not input_enabled:
		return;
	
	if Input.is_action_pressed("shoot"):
	
		if !blaster_cooldown.is_stopped(): return # Cooldown for shooting
		
		Audio.play(weapon_sound_shoot)
		
		camera.rotation.x += 0.025 # Knockback of camera
		movement_velocity += Vector3(0, 0, weapon_knockback) # Knockback
		
		# Set muzzle flash position, play animation
		
		blaster_cooldown.start(weapon_cooldown)
		
		# Shoot the weapon, amount based on shot count
		
		var beam_points = get_reflecting_positions()
		# print(beam_points)
		var new_beam = beam.instantiate()
		beams.add_child(new_beam)
		new_beam.global_position = Vector3.ZERO;
		new_beam.start_beam(beam_points)

		no_of_beams.text = str(int(no_of_beams.text) + 1)

func get_reflecting_positions():
	var position_from = camera.project_ray_origin(get_viewport().size/2) + Vector3.DOWN * 0.1
	var position_to = position_from + camera.project_ray_normal(get_viewport().size/2) * 100
	var result = [position_from]
	return get_reflecting_positions_helper(result, position_from, position_to)

func get_reflecting_positions_helper(result, position_from, position_to):
	var ray_from = position_from
	var ray_to = position_to
	var space_state = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.new()
	ray.collision_mask = beam_collision_mask
	ray.from = ray_from
	ray.to = ray_to
	var collision = space_state.intersect_ray(ray)

	if collision.has('collider'):
		var remaining_distance = ray_from.distance_to(ray_to) - ray_from.distance_to(collision['position']);
		var reflected_beam_from = collision['position']
		var reflected_beam_to = reflected_beam_from + (ray_to-ray_from).bounce(collision['normal']).normalized() * remaining_distance
		
		result.append(collision['position'])
		return get_reflecting_positions_helper(result, reflected_beam_from, reflected_beam_to)

	result.append(ray_to)
	return result


func _on_victory_body_entered(body:Node3D) -> void:
	input_enabled = false
