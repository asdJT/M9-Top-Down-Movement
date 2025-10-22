extends CharacterBody2D

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var collision_shape_2d = %CollisionShape2D

var max_speed := 800.0
var acceleration := 500.0
var deceleration := 500.0
var rotation_speed := 3.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_moving := direction.length() > 0.0

	if is_moving:
		var desired_velocity := direction * max_speed
		# make sure to make the velocity progress toward the desired state over time
		velocity = velocity.move_toward(desired_velocity, acceleration * delta) # velocity = desired_velocity
	else:
		# make sure the make the velocity process toward zero over time
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta) # velocity = Vector2.ZERO
	
	if direction.length() > 0:
		# make sure to make the rotation progress towards the desired angle over time
		# make sure to use `orthogonal()`!
		# and don't forget to use `rotation_speed`
		rotation = rotate_toward(rotation, direction.orthogonal().angle(), rotation_speed * delta) # rotation = direction.angle()
	move_and_slide()
