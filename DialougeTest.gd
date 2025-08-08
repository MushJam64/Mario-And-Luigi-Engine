extends Node2D

@onready var dialogue_ui = $DialougeUI

func _ready():
	var dialogue_script = [
		{"text": "Have you ever heard of [color=red]joe[/color]"},
		{"text": "What? Who's [color=red]joe?[/color]"},
		{"text": "Joe suck my nuts gottem!!!!9"},
	]
	
	dialogue_ui.start_dialogue(dialogue_script)
