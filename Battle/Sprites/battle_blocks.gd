extends Node3D

@export var frontBlock: Node3D
@export var rightfrontBlock: Node3D
@export var rightbackBlock: Node3D
@export var backBlock: Node3D
@export var leftbackBlock: Node3D
@export var leftfrontBlock: Node3D

var blocks: Array[Node3D]
var layout_positions: Array[Vector3]
var target_indices: Array[int]
var block_opacity: Array[float]

var rotate_direction := 1
var current_player_index := 0
var state := "selecting" # "selecting", "targeting", "executing"
var fade_counter := 0
var pending_execution := false
var last_selected_index := 0
var awaiting_timer := false
var input_repeat_timer := 0.0
var input_initial_delay := 0.25
var input_repeat_delay := 0.1
var input_holding := false
var input_last_direction := 0    # 1 for left, -1 for right, 0 for none

func _ready():
	blocks = [frontBlock, rightfrontBlock, rightbackBlock, backBlock, leftbackBlock, leftfrontBlock]
	layout_positions = []
	target_indices = []
	block_opacity = []

	for block in blocks:
		layout_positions.append(block.position)
		block_opacity.append(1.0)

	for i in range(blocks.size()):
		target_indices.append(i)

	fade_in_with_spawn()

func _process(delta):
	if state == "selecting":
		var left_pressed = Input.is_action_pressed("Left")
		var right_pressed = Input.is_action_pressed("Right")

		var current_direction = 0
		if left_pressed:
			current_direction = 1
		elif right_pressed:
			current_direction = -1

		if current_direction != 0:
			if not input_holding or current_direction != input_last_direction:
				rotate_direction = current_direction
				rotate_targets()
				$RotationSoundPlayer.play()
				update_debug_text()
				
				input_repeat_timer = input_initial_delay
				input_holding = true
				input_last_direction = current_direction
			else:
				input_repeat_timer -= delta
				if input_repeat_timer <= 0.0:
					rotate_direction = current_direction
					rotate_targets()
					$RotationSoundPlayer.play()
					update_debug_text()
					
					input_repeat_timer = input_repeat_delay
		else:
			# No left/right presses, reset state
			input_holding = false
			input_last_direction = 0
			input_repeat_timer = 0.0
	if state == "targeting" and Input.is_action_just_pressed("UI_Cancel"):
			print("Going back to move selection.")
			state = "selecting"
			fade_in_with_spawn()
			return  # Exit early to prevent selecting a target on the same frame

	var player_input := get_current_player_input()
	if Input.is_action_just_pressed(player_input):
		

		if state == "selecting":
			$BlockSelectionSoundPlayer.play()
			fade_out_all_sprites()
			last_selected_index = target_indices.find(0)
			var selected_block = blocks[last_selected_index].name
			print("Player %d selected: %s" % [((current_player_index % 2) + 1), selected_block])

			var selected_block_index = target_indices.find(0)
			var selected_block_node = blocks[selected_block_index]
			var original_pos = layout_positions[0]
			var raised_pos = original_pos + Vector3(0, 0.10, 0)

			var tween := create_tween()
			tween.tween_property(selected_block_node, "position", raised_pos, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(selected_block_node, "scale", Vector3(1.2, 1.2, 1.2), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(selected_block_node, "position", original_pos, 0.1).set_delay(0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tween.tween_property(selected_block_node, "scale", Vector3.ONE, 0.1).set_delay(0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

			state = "targeting"
			

		elif state == "targeting" and not awaiting_timer:
			pending_execution = true
			state = "executing"
			print("Player %d's move is being executed" % ((current_player_index % 2) + 1))
			$EnemySelectionSoundPlayer.play()
			awaiting_timer = true
			await get_tree().create_timer(5.0).timeout
			current_player_index = (current_player_index + 1) % 2
			state = "selecting"
			fade_in_with_spawn()

func get_current_player_input() -> String:
	if current_player_index % 2 == 0:
		return "Jump_A"
	elif current_player_index % 2 == 1:
		return "Jump_B"
	else:
		return "Jump_A"

func rotate_targets():
	for i in range(target_indices.size()):
		target_indices[i] = (target_indices[i] + rotate_direction) % blocks.size()
		if target_indices[i] < 0:
			target_indices[i] += blocks.size()

	# Smooth move blocks to new positions
	for i in range(blocks.size()):
		var block = blocks[i]
		var target_pos = layout_positions[target_indices[i]]
		var tween := create_tween()
		tween.tween_property(block, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func rotate_targets_to_last_selected():
	var offset = (blocks.size() - last_selected_index) % blocks.size()
	for i in range(target_indices.size()):
		target_indices[i] = (i + offset) % blocks.size()

func fade_out_sprite(sprite: Sprite3D):
	if not sprite:
		return
	fade_counter += 1
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(sprite, "hide"))
	tween.tween_callback(Callable(self, "_on_fade_done"))

func fade_out_all_sprites():
	for block in blocks:
		var sprite = block.get_node_or_null("Sprite3D")
		if sprite:
			fade_out_sprite(sprite)

func fade_in_with_spawn():
	rotate_targets_to_last_selected()
	var duration := 0.75

	for i in range(blocks.size()):
		var block = blocks[i]
		var sprite = block.get_node_or_null("Sprite3D")
		if sprite:
			sprite.show()
			sprite.modulate.a = 0.0

		block.position = layout_positions[0]
		block.scale = Vector3.ZERO

		var target_index = target_indices[i]
		var end_pos = layout_positions[target_index]

		var tween := create_tween().set_parallel(true)
		tween.tween_property(block, "position", end_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(block, "scale", Vector3.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		if sprite:
			tween.tween_property(sprite, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		tween.tween_callback(Callable(self, "_on_fade_done"))
		fade_counter += 1

func _on_fade_done():
	fade_counter -= 1
	if fade_counter <= 0:
		fade_counter = 0
		if state == "selecting" and awaiting_timer:
			awaiting_timer = false
			update_debug_text()

func update_debug_text():
	var player_number = (current_player_index % 2) + 1
	var selected_index = target_indices.find(0)
	var block_name = blocks[selected_index].name
	print("Player %d's turn - Selecting: %s" % [player_number, block_name])
