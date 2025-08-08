extends Node2D

@onready var dialogue_ui = $DialougeUI

func _ready():
	var dialogue_script = [
		{"text": "Welcome to the [color=yellow]Mushroom Kingdom[/color]!"},
		{"text": "It's dangerous to go alone."},
		{"text": "Let's-a go!"},
	]
	
	dialogue_ui.start_dialogue(dialogue_script)
