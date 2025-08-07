extends CharacterBody2D

@export var move_speed: float = 120.0
@export var jump_height: float = 40.0
@export var jump_duration: float = 0.45
@export var gravity_z: float = 0.0 

var jump_z := 0.0
var jump_velocity_z := 0.0
var is_jumping := false

@onready var mariosprite = $MarioSprite
@onready var camera = $Camera2D

var camera_target_pos := Vector2.ZERO
var position_history: Array = []
const MAX_HISTORY = 30

const DEVICE_ID = 0
const DEADZONE = 0.2

func _ready():
	gravity_z = (8 * jump_height) / pow(jump_duration, 2)

func _physics_process(delta):
	handle_input(delta)
	handle_jump_z(delta)
	move_and_slide()
	update_position_history()
	handle_camera()

	if Input.is_action_pressed("Up"):
		set_z_index(0)
	elif Input.is_action_pressed("Down"):
		set_z_index(2)

func handle_input(delta):
	var input_vec = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	)

	if input_vec.length_squared() > 0:
		var snapped_vec = get_8_direction(input_vec.normalized())
		velocity = snapped_vec * move_speed
	else:
		velocity = Vector2.ZERO

	if Input.is_action_just_pressed("Jump_A") and not is_jumping:
		jump_velocity_z = (4 * jump_height) / jump_duration
		is_jumping = true

func handle_jump_z(delta):
	if is_jumping:
		jump_z += jump_velocity_z * delta
		jump_velocity_z -= gravity_z * delta

		if jump_z <= 0.0:
			jump_z = 0.0
			jump_velocity_z = 0.0
			is_jumping = false

		mariosprite.position.y = -jump_z
	else:
		mariosprite.position.y = 0.0

func update_position_history():
	if velocity.length_squared() > 0.1:
		position_history.insert(0, global_position)
		if position_history.size() > MAX_HISTORY:
			position_history.pop_back()

func get_position_history():
	return position_history

func get_8_direction(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		return Vector2.ZERO

	var angle = dir.angle()
	var octant = int(round(angle / (PI / 4.0))) % 8

	match octant:
		0: return Vector2.RIGHT
		1: return Vector2(1, 1).normalized()
		2: return Vector2.DOWN
		3: return Vector2(-1, 1).normalized()
		4: return Vector2.LEFT
		5: return Vector2(-1, -1).normalized()
		6: return Vector2.UP
		7: return Vector2(1, -1).normalized()

	return dir

# === CAMERA SYSTEM ===
var camera_mode = "free"
var last_tile_pos = Vector2i(-9999, -9999)

func handle_camera():
	var tilemap = Globals.tilemap
	if tilemap == null:
		# No tilemap assigned, just follow player freely
		camera_mode = "free"
		camera_target_pos = global_position
		camera.global_position = camera_target_pos
		return

	var player_pos = global_position.round()
	var tile_pos = tilemap.local_to_map(player_pos)
	var tile_data = tilemap.get_cell_tile_data(tile_pos)

	if tile_pos != last_tile_pos:
		last_tile_pos = tile_pos

		if tile_data:
			var red = tile_data.get_custom_data("red_boundary") if tile_data.has_custom_data("red_boundary") else false
			var green = tile_data.get_custom_data("green_boundary") if tile_data.has_custom_data("green_boundary") else false
			var orange = tile_data.get_custom_data("orange_reset") if tile_data.has_custom_data("orange_reset") else false

			if orange:
				camera_mode = "free"
			elif red:
				camera_mode = "y_only"
			elif green:
				camera_mode = "x_only"
			else:
				camera_mode = "free"

	match camera_mode:
		"x_only":
			camera_target_pos.x = player_pos.x
		"y_only":
			camera_target_pos.y = player_pos.y
		"free":
			camera_target_pos = player_pos

	camera.global_position = camera_target_pos


# function to check if Mario is currently falling
func is_falling() -> bool:
	return is_jumping and jump_velocity_z < 0 and jump_z > 0
