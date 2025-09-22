extends CharacterBody2D

@export var follow_delay: int = 8
@export var move_speed: float = 120.0
@export var stop_threshold: float = 10.0

@export var jump_height: float = 40.0
@export var jump_duration: float = 0.45
@export var gravity_z: float = 0.0

var jump_z := 0.0
var jump_velocity_z := 0.0
var is_jumping := false

var mario_node: CharacterBody2D
var target_position: Vector2

@onready var luigisprite = $LuigiSprite

func _ready():
	mario_node = get_parent().get_node("Mario")
	target_position = global_position
	gravity_z = (8 * jump_height) / pow(jump_duration, 2)

func _physics_process(delta):
	handle_jump_z(delta)
	follow_mario(delta)
	move_and_slide()

func follow_mario(delta):
	if not mario_node:
		return

	# Grab Mario's position history
	if mario_node.has_method("get_position_history"):
		var history = mario_node.get_position_history()
		if history.size() > follow_delay:
			target_position = history[follow_delay]

	var offset = target_position - global_position
	var distance = offset.length()

	if distance > stop_threshold:
		var move_dir = offset.normalized()

		# --- Snap Luigi’s movement to the same 8-direction grid as Mario ---
		var snapped_dir = get_8_direction(move_dir)

		velocity = snapped_dir * move_speed
	else:
		velocity = Vector2.ZERO

func handle_jump_z(delta):
	if is_jumping:
		jump_z += jump_velocity_z * delta
		jump_velocity_z -= gravity_z * delta

		if jump_z <= 0.0:
			jump_z = 0.0
			jump_velocity_z = 0.0
			is_jumping = false

		luigisprite.position.y = -jump_z
	else:
		luigisprite.position.y = 0.0

	if Input.is_action_just_pressed("Jump_B") and not is_jumping:
		jump_velocity_z = (4 * jump_height) / jump_duration
		is_jumping = true

func is_falling() -> bool:
	return is_jumping and jump_velocity_z < 0 and jump_z > 0

# --- Copy of Mario’s 8-direction snap ---
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
