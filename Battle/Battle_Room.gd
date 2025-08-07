extends Node2D

@export var room: String = "Unnamed Room"
@export var location: String = "Uncharted Territory - A Debug Area"

func _ready():
	Globals.room = room
	Globals.location = location

	# Update Discord Rich Presence
	DiscordRPC.state = room
	DiscordRPC.details = location
	DiscordRPC.run_callbacks()
	DiscordRPC.refresh()
