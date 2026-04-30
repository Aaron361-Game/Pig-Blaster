extends Node2D



#func _ready():
	#$HardModeToggle.button_pressed = Global.hard_mode



func _process(_delta):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://World.tscn")


func _on_controls_pressed():
	get_tree().change_scene_to_file("res://controls.tscn")


func _on_hard_mode_toggle_toggled(toggled_on):
	Global.hard_mode = toggled_on
