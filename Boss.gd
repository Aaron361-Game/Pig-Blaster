extends CharacterBody3D

@export var max_health: int = 40
@export var fireball_scene: PackedScene
var fireball_cooldown: float = 5.0
var current_fireball_timer: float = 0.0
var current_health: int



signal enemy_died
signal health_changed(current_hp, max_hp) 

@onready var nav = $NavigationAgent3D
@onready var fireball_spawn = $FireballSpawn

const SPEED = 4.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player = null
const STOPPING_DISTANCE = 7.5
var attack_damage = 10 
var can_attack = true

func _ready():
	current_health = max_health 
	player = get_tree().get_first_node_in_group("player")
	call_deferred("nav_setup")

func nav_setup():
	await get_tree().physics_frame

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player:
		current_fireball_timer += delta
		if current_fireball_timer >= fireball_cooldown:
			shoot_fireball()
			current_fireball_timer = 0.0 
		
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player <= STOPPING_DISTANCE:
			velocity.x = 0
			velocity.z = 0
			
			if can_attack:
				attack_player()
				
		else:
			nav.target_position = player.global_position
			
			if nav.is_navigation_finished():
				velocity.x = 0
				velocity.z = 0
			else:
				var next_p = nav.get_next_path_position()
				var direction = (next_p - global_position)
				
				direction.y = 0 
				direction = direction.normalized()
				
				if direction:
					velocity.x = direction.x * SPEED
					velocity.z = direction.z * SPEED
		
		var look_target = player.global_position
		look_target.y = global_position.y 
		
		if global_position.distance_to(look_target) > 0.1:
			look_at(look_target, Vector3.UP, true)

	move_and_slide()

func attack_player():
	can_attack = false
	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
	
	await get_tree().create_timer(1.0).timeout
	can_attack = true

func take_damage(damage_amount: int):
	current_health -= damage_amount
	health_changed.emit(current_health, max_health) 
	
	if current_health <= 0:
		enemy_die()

func shoot_fireball():
	if fireball_scene == null:
		return
		
	var fireball = fireball_scene.instantiate()
	get_parent().add_child(fireball)
	
	
	fireball.global_position = fireball_spawn.global_position 
	
	var aim_target = player.global_position + Vector3(0, 1, 0)
	fireball.look_at(aim_target, Vector3.UP)
	
	

func enemy_die():
	enemy_died.emit() 
	queue_free()
