extends Node2D

@onready var canvas_layer := $CanvasLayer
@onready var battle_blocks := $SubViewport/BattleBlocks
@onready var mario := $Mario 
@onready var luigi := $Luigi

var last_player_index := -1

func _process(delta):
	if not battle_blocks:
		return

	var current_index = battle_blocks.current_player_index

	if current_index != last_player_index:
		last_player_index = current_index

		if current_index == 0:
			# Mario's turn
			canvas_layer.offset = Vector2(-200, -200)
			move_character(mario, Vector2(-200, mario.position.y))
			move_character(luigi, Vector2(-300, luigi.position.y))
		else:
			# Luigi's turn
			canvas_layer.offset = Vector2(-200, -65)
			move_character(mario, Vector2(-300, mario.position.y))
			move_character(luigi, Vector2(-200, luigi.position.y))

func move_character(character: Node2D, target_position: Vector2):
	var tween := create_tween()
	tween.tween_property(character, "position", target_position, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
