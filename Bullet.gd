extends CharacterBody3D

var speed = 50

func _physics_process(delta):
	
	var velocity = transform.basis * Vector3(0, 0, -speed) * delta
	
	var collision = move_and_collide(velocity)
	
	if collision:
		
		var hit_object = collision.get_collider()
		
		
		if hit_object.has_method("take_damage"):
			
			hit_object.take_damage(1)
		
			
		queue_free()
