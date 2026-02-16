extends Control

func _ready() -> void:
	$Text_Panel._panel_chat("Librarian",
	["How DARE you RUIN my library!","Bippity boppity boop! Now you go into a book."]
	,"next_scene"
	,"res://prototypes/world/world_rotation_test.tscn"
	)
