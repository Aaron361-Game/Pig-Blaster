extends Area3D

var speed: float = 20.0
var damage: int = 30 

func _physics_process(delta):
	
	global_position += global_transform.basis * Vector3(0, 0, -speed) * delta

func _on_body_entered(body):
	
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free() 
			
	elif body.is_in_group("enemy"):
		pass 
			
	else:
		queue_free()
			
	
