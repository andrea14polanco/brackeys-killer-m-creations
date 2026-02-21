extends Control

func _ready() -> void:
	$Text_Panel._panel_chat("Player",
	["They slam their head repeatedly upon the library desk.",
	"Two books lay on the desk. One about the Titanic and one about the Rain Forest."
	,"'UGH I can't believe they're making me do these stupid reports all over again.'"
	,"They throw the book across the room. Then someone catches it."]
	,"next_chat"
	,1
	)

func next_chat(num):
	if num == 1:
		$Text_Panel._panel_chat("Mysterious Person",
		["Oh what is this? You should not disgrace the sanctity of the biblio young man."]
		,"next_chat"
		,2
		)
	elif num == 2:
		$Text_Panel._panel_chat("Player",
		["Right well that Bibilio failed me because I didn't learn nothing from it. 
		Apparently using ChitGPT does nothing but make me do this report all over again."]
		,"next_chat"
		,3
		)
	elif num == 3:
		$Text_Panel._panel_chat("Mysterious Person",
		["Well, that's no good. Why must you taint the process of knowledge? "]
		,"next_chat"
		,4
		)
	elif num == 4:
		$Text_Panel._panel_chat("Player",
		["I just didn't learn anything from it, and it's boring. I just wanna read the exciting parts."]
		,"next_chat"
		,5
		)
	elif num == 5:
		$Text_Panel._panel_chat("Mysterious Person",
		["I suppose there are other ways we can teach you such."]
		,"next_scene"
		,"res://scenes/levels/titanic/titanic.tscn"
		)
