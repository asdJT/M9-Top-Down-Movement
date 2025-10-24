extends CharacterBody2D

@export var max_speed := 600.0

@export var acceleration := 1200.0
@export var deceleration := 1080.0

@onready var _runner_visual: RunnerVisual = %RunnerVisualRed
@onready var _dust: GPUParticles2D = %Dust

func _physics_process(delta: float) -> void :
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction.length() > 0.0:
		_dust.emitting = true
		var desired_velocity := max_speed * direction
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		_dust.emitting = false
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
	if direction.length() > 0.0:
		_runner_visual.angle = rotate_toward(_runner_visual.angle, direction.orthogonal().angle(), 8.0 * delta)
		_runner_visual.animation_name = RunnerVisual.Animations.WALK
		var current_speed_percent := velocity.length() / max_speed
		_runner_visual.animation_name = (
			RunnerVisual.Animations.WALK
			if current_speed_percent < 0.8
			else RunnerVisual.Animations.RUN 
		)
	else:
		_runner_visual.animation_name = RunnerVisual.Animations.IDLE
		
	
	
	move_and_slide()
