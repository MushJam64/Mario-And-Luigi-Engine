extends CharacterBody2D

@export var follow_distance: float = 25.0
@export var move_speed: float = 120.0

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

	var snapped_dir = Vector2.ZERO
	if mario_node.velocity.length_squared() > 0:
		if mario_node.has_method("get_8_direction"):
			snapped_dir = mario_node.get_8_direction(mario_node.velocity.normalized())

	# Only update target when Mario is moving
	if snapped_dir != Vector2.ZERO:
		# Always put Luigi BEHIND Mario
		target_position = mario_node.global_position - snapped_dir * follow_distance

		# --- Clamp check so Luigi never overshoots in front ---
		var vec_to_mario = mario_node.global_position - global_position
		if vec_to_mario.dot(snapped_dir) < 0:
			# If Luigi is already in front, snap him back behind
			target_position = mario_node.global_position - snapped_dir * follow_distance

	# Move Luigi toward target
	var offset = target_position - global_position
	if offset.length() > 2.0:
		var snapped_offset = get_8_direction(offset.normalized())
		velocity = snapped_offset * move_speed
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

# --- Same snap system as Mario ---
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
