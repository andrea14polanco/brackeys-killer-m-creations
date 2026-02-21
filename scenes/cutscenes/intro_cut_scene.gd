extends Control

var mc_faceset01 = preload("res://assets/overlays/faceset_player_mad.png")
var mc_faceset02 = preload("res://assets/overlays/faceset_player_mad_talk.png")
var mc_faceset03 = preload("res://assets/overlays/faceset_player_sad.png")
var mc_faceset04 = preload("res://assets/overlays/faceset_player_sad_talk.png")
var mage_faceset01 = preload("res://assets/overlays/faceset_antagonist_mad.png")
var mage_faceset02 = preload("res://assets/overlays/faceset_antagonist_happy.png")

func _ready() -> void:
	pass

func start_chat():
	$Text_Panel.show()
	$FacesetPlayer.show()
	$Text_Panel._panel_chat("Player",
	["They slam their head repeatedly upon the library desk.",
	"Two books lay on the desk. One about the Titanic and one about the Rain Forest."
	,]
	,"next_chat"
	,1
	)

func next_chat(num):
	if num == 1:
		$FacesetPlayer.texture = mc_faceset02
		$Text_Panel._panel_chat("Player",
		["'UGH I can't believe they're making me do these stupid reports all over again.'"]
		,"next_chat"
		,2
		)
	elif num == 2:
		$FacesetPlayer.texture = mc_faceset01
		$Text_Panel._panel_chat("Player",
		["They throw the Titanic book across the room. Then someone catches it."]
		,"next_chat"
		,3
		)
	elif num == 3:
		$FacesetPlayer.texture = mc_faceset01
		$FacesetAntagonist.show()
		$Text_Panel._panel_chat("Mysterious Person",
		["Oh what is this? You should not disgrace the sanctity of the biblio young man."]
		,"next_chat"
		,4
		)
	elif num == 4:
		$FacesetPlayer.texture = mc_faceset02
		$Text_Panel._panel_chat("Player",
		["Right well that Bibilio failed me because I didn't learn nothing from it. 
		Apparently using ChitGPT does nothing but make me do this report all over again."]
		,"next_chat"
		,5
		)
	elif num == 5:
		$FacesetPlayer.texture = mc_faceset01
		$FacesetAntagonist.texture = mage_faceset02
		$Text_Panel._panel_chat("Mysterious Person",
		["Well, that's no good. Why must you taint the process of knowledge? "]
		,"next_chat"
		,6
		)
	elif num == 6:
		$FacesetPlayer.texture = mc_faceset04
		$Text_Panel._panel_chat("Player",
		["I just didn't learn anything from it, and it's boring. I just wanna read the exciting parts."]
		,"next_chat"
		,7
		)
	elif num == 7:
		$FacesetPlayer.texture = mc_faceset03
		$Text_Panel._panel_chat("Mysterious Person",
		["I suppose there are other ways we can teach you such."]
		,"next_scene"
		,"res://scenes/levels/titanic/titanic.tscn"
		)
