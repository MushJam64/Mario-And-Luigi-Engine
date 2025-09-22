extends Node
func _ready():
	DiscordRPC.app_id = 1402830885325373532 # Application ID
	DiscordRPC.details = Globals.location
	DiscordRPC.state = Globals.room
	DiscordRPC.large_image = "mario_and_luigi_engine_logo" # Image key from "Art Assets"
	DiscordRPC.large_image_text = "The Mario And Luigi Engine"
	DiscordRPC.small_image = "mushroom_icon" # Image key from "Art Assets"
	DiscordRPC.small_image_text = "Exploring a vast world"

	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	# DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"

	DiscordRPC.refresh() # Always refresh after changing the values!
