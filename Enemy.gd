extends CharacterBody3D

@export var health: int = 1

signal enemy_died

@onready var nav = $NavigationAgent3D

const SPEED = 7.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var player = null

const STOPPING_DISTANCE = 1.5 

var attack_damage = 10 
var can_attack = true

func _ready():
	player = get_tree().get_first_node_in_group("player")
	call_deferred("nav_setup")

func nav_setup():
	await get_tree().physics_frame

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player:
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
	health -= damage_amount
	
	if health <= 0:
		enemy_die()


func enemy_die():
	enemy_died.emit() 
	queue_free()
