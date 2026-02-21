extends Control

@onready var current_array: = []
@onready var array_count: = 0
@onready var text_count: = 0
@onready var option: = "none"
@onready var final_action
@onready var name_var: = "none"

#func_option
#################
#this if for what you want the next button to do at the end.
################
#  - "next_scene"

func _panel_chat(func_name, func_array, func_option, func_end) -> void:
	current_array = func_array
	array_count = func_array.size()
	option = func_option
	name_var = func_name
	final_action = func_end
	if text_count == array_count:
		return
	$bg_Panel.show()
	$bg_Panel/name_label.text = name_var
	$bg_Panel/text_label.full_text = func_array[text_count]
	$bg_Panel/text_label.type_text()

func _on_next_button_pressed() -> void:
	text_count += 1
	if text_count < array_count:
		_panel_chat(name_var, current_array, option, final_action)
	else:
		if option == "next_scene":
			get_tree().change_scene_to_file(final_action)
		elif option == "next_chat":
			text_count = 0
			array_count = 0
			$"..".next_chat(final_action)
		
