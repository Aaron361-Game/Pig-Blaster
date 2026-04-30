extends Node3D

@export var enemy_scene: PackedScene
@export var enemies_left_label: Label
@export var kill_notification_label: Label
@export var end_screen: Panel
@export var result_label: Label
@export var restart_button: Button
@export var main_menu_button: Button 
@export var boss_scene: PackedScene
@export var boss_health_bar: ProgressBar
@export var boss_health_bar_2: ProgressBar

var waves: Array[int] = [1,1,1]
var current_wave: int = 0
var enemies_alive: int = 0
var bosses_alive: int = 0 

func _ready():
	if kill_notification_label:
		kill_notification_label.modulate.a = 0.0 
		
	if restart_button:
		restart_button.pressed.connect(restart_game)
		
	if main_menu_button:
		main_menu_button.pressed.connect(go_to_main_menu) 
		
	await get_tree().create_timer(2.0).timeout
	start_next_wave()

func start_next_wave():
	if current_wave >= waves.size():
		start_boss_wave() 
		return
		
	var enemies_to_spawn = waves[current_wave]
	
	
	if Global.hard_mode == true:
		enemies_to_spawn *= 2 
	
	
	print("Starting Wave ", current_wave + 1, " with ", enemies_to_spawn, " enemies!")
	
	for i in range(enemies_to_spawn):
		spawn_enemy()
		await get_tree().create_timer(0.5).timeout
		
	current_wave += 1

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	
	var random_x = randf_range(-20.0, 20.0)
	var random_z = randf_range(-20.0, 20.0)
	enemy.global_position = global_position + Vector3(random_x, 0, random_z)
	
	enemy.enemy_died.connect(_on_enemy_died)
	enemies_alive += 1
	update_ui()

func _on_enemy_died():
	enemies_alive -= 1
	update_ui()
	show_kill_notification()
	
	if enemies_alive <= 0:
		print("Wave Cleared!")
		await get_tree().create_timer(3.0).timeout
		start_next_wave()

func update_ui():
	if enemies_left_label:
		enemies_left_label.text = "Enemies Left: " + str(enemies_alive)

func show_kill_notification():
	if kill_notification_label:
		kill_notification_label.text = "Enemy Killed!"
		kill_notification_label.modulate.a = 1.0 
		var tween = get_tree().create_tween()
		tween.tween_property(kill_notification_label, "modulate:a", 0.0, 1.5)

func trigger_game_over(is_win: bool):
	end_screen.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if is_win:
		result_label.text = "YOU WIN! All Waves Cleared!"
		result_label.modulate = Color(0, 1, 0) 
	else:
		result_label.text = "GAME OVER!"
		result_label.modulate = Color(1, 0, 0) 
		
	get_tree().paused = true

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()

func go_to_main_menu():
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://menu.tscn")

func start_boss_wave():
	print("WARNING: BOSS INCOMING!")
	
	if enemies_left_label:
		enemies_left_label.text = "WARNING: BOSS FIGHT!"
		enemies_left_label.modulate = Color(1, 0, 0) 
		
	await get_tree().create_timer(2.0).timeout
	spawn_boss()

func spawn_boss():
	if boss_scene == null:
		trigger_game_over(true)
		return
		
	
	var boss1 = boss_scene.instantiate()
	get_parent().add_child(boss1)
	boss1.global_position = global_position 
	boss1.enemy_died.connect(_on_boss_died)
	bosses_alive = 1
	
	if boss_health_bar:
		boss_health_bar.show() 
		boss_health_bar.max_value = boss1.max_health 
		boss_health_bar.value = boss1.max_health 
		boss1.health_changed.connect(update_boss_ui)

	
	
	if Global.hard_mode == true:
		var boss2 = boss_scene.instantiate()
		get_parent().add_child(boss2)
		boss2.global_position = global_position + Vector3(15, 2, -15)
		boss2.enemy_died.connect(_on_boss_died)
		bosses_alive = 2
		
		
		if boss_health_bar_2:
			boss_health_bar_2.show() 
			boss_health_bar_2.max_value = boss2.max_health 
			boss_health_bar_2.value = boss2.max_health 
			boss2.health_changed.connect(update_boss_ui_2)
	
	

func _on_boss_died():
	show_kill_notification()
	bosses_alive -= 1
	
	
	if bosses_alive <= 0:
		if boss_health_bar:
			boss_health_bar.hide()
		if boss_health_bar_2:
			boss_health_bar_2.hide() 
			
		await get_tree().create_timer(1.5).timeout
		trigger_game_over(true)


func update_boss_ui(current_hp, _max_hp):
	if boss_health_bar:
		boss_health_bar.value = current_hp


func update_boss_ui_2(current_hp, _max_hp):
	if boss_health_bar_2:
		boss_health_bar_2.value = current_hp
