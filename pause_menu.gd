extends Control

func _ready():
	hide() 

func _input(event):
	
	if event.is_action_pressed("ui_cancel"): 
		toggle_pause()

func toggle_pause():
	
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	
	if is_paused:
		show()
		
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
	else:
		hide()
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_button_pressed():
	toggle_pause()


func _on_quit_button_pressed():
	get_tree().quit() 
