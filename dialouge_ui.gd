extends Control

@export var typing_speed := 0.04

var dialogues = []
var current_index = 0
var full_text = ""
var displayed_text = ""
var typing_timer := 0.0
var typing_in_progress = false

@onready var text_label = $RichTextLabel

signal dialogue_finished

func _ready():
	visible = false
	text_label.text = ""

func start_dialogue(dialogue_array):
	dialogues = dialogue_array
	current_index = 0
	visible = true
	_show_line()

func _show_line():
	if current_index >= dialogues.size():
		visible = false
		emit_signal("dialogue_finished")
		return
	
	var entry = dialogues[current_index]
	full_text = entry.get("text", "")
	displayed_text = ""
	typing_in_progress = true
	typing_timer = 0.0
	text_label.text = ""

func _process(delta):
	if not visible or not typing_in_progress:
		return
	
	typing_timer += delta
	var letters_to_show = int(typing_timer / typing_speed)
	if letters_to_show > get_visible_char_count(full_text):
		letters_to_show = get_visible_char_count(full_text)
		typing_in_progress = false
	
	displayed_text = get_bbcode_substring(full_text, letters_to_show)
	text_label.text = displayed_text

func _input(event):
	if not visible:
		return
	
	if event.is_action_pressed("Jump_A"):
		if typing_in_progress:
			typing_in_progress = false
			text_label.text = full_text
		else:
			current_index += 1
			_show_line()

func get_visible_char_count(text: String) -> int:
	var count = 0
	var inside_tag = false
	for c in text:
		if c == '[':
			inside_tag = true
			continue
		elif c == ']':
			inside_tag = false
			continue
		
		if not inside_tag:
			count += 1
	return count

func get_bbcode_substring(text: String, visible_chars: int) -> String:
	var result = ""
	var visible_count = 0
	var inside_tag = false
	var i = 0
	
	while i < text.length():
		var c = text[i]
		
		if c == '[':
			inside_tag = true
		
		if inside_tag:
			result += c
			if c == ']':
				inside_tag = false
			i += 1
			continue
		
		if visible_count < visible_chars:
			result += c
			visible_count += 1
			i += 1
		else:
			break
	
	return result
