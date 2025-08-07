extends Area2D

@export var contained_item: String = "Coin"
@export var given_item: String = "SuperMushroom"

var used: bool = false
signal block_used(given_item)

var overlapping_bodies := []

var original_block_y := 0.0
var original_item_y := 0.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	if has_node("QuestionBlock"):
		original_block_y = $QuestionBlock.position.y
	if has_node("QuestionBlock/Item"):
		$QuestionBlock/Item.visible = false
		original_item_y = $QuestionBlock/Item.position.y

func _on_body_entered(body):
	if body.is_in_group("Player"):
		overlapping_bodies.append(body)

func _on_body_exited(body):
	if body in overlapping_bodies:
		overlapping_bodies.erase(body)

func _physics_process(delta):
	if used:
		for body in overlapping_bodies:
			if body.has_method("is_falling"):
				if "is_jumping" in body and body.is_jumping and not body.is_falling():
					interact(true)
					break
		return

	for body in overlapping_bodies:
		if body.has_method("is_falling"):
			if "is_jumping" in body and body.is_jumping and not body.is_falling():
				used = true
				interact()
				overlapping_bodies.erase(body)
				break

func interact(bounce_only: bool = false):
	if has_node("QuestionBlock"):
		var tween = create_tween()
		tween.tween_interval(0.15)
		tween.tween_callback(func():
			_change_frame_and_bounce(bounce_only)
		)

	if not bounce_only:
		emit_signal("block_used", given_item)
		print("Block activated! Visual: ", contained_item, ", Gives: ", given_item)

func _change_frame_and_bounce(bounce_only: bool = false):
	$QuestionBlock.frame = 1

	var block = $QuestionBlock
	var block_tween = create_tween()
	block_tween.tween_property(block, "position:y", original_block_y - 10, 0.1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	block_tween.tween_property(block, "position:y", original_block_y, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	if bounce_only:
		return  # Skip item animation if block is used

	if has_node("QuestionBlock/Item"):
		var item = $QuestionBlock/Item
		item.animation = contained_item
		item.visible = true
		item.play()

		var item_tween = create_tween()
		item_tween.tween_property(item, "position:y", original_item_y - 10, 0.15)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		item_tween.tween_interval(0.45)
		item_tween.tween_callback(Callable(self, "_hide_item"))

func _hide_item():
	$QuestionBlock/Item.visible = false
