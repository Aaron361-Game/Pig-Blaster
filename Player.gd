extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSIVITY = 0.003

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5


var gravity = 9.8


@export var max_health: int = 100
var current_health: int

@onready var head = $Head
@onready var camera = $Head/Camera3D

var bullet=load("res://bullet.tscn")
@onready var pos = $Head/Camera3D/gun/pos



@onready var health_bar = $"../UI/Health Bar/ProgressBar" 


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	
func _unhandled_input(event):
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * SENSIVITY)
			camera.rotate_x(-event.relative.y * SENSIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# Handle Sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "foward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else: 
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
		
	#headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)


	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	### 3d Gun Shoot
	if Input.is_action_just_pressed("click"):
		var instance = bullet.instantiate()
		get_parent().add_child(instance)
		instance.global_position = pos.global_position
		instance.global_transform.basis = pos.global_transform.basis
		
		# Despawn bullets
		get_tree().create_timer(2.0).timeout.connect(instance.queue_free)

	move_and_slide()


func _headbob(time) -> Vector3:
	var bob_pos = Vector3.ZERO
	bob_pos.y = sin(time * BOB_FREQ) * BOB_AMP
	bob_pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return bob_pos


func take_damage(amount: int):
	current_health -= amount
	health_bar.value = current_health
	print("Player took damage! Health is now: ", current_health)
	
	if current_health <= 0:
		die()
		$"../WaveManager".trigger_game_over(false)

func die():
	print("Player has died!")
