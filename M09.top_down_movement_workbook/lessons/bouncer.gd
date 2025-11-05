extends CharacterBody2D

@export var max_speed := 600.0

@export var acceleration := 1200.0

@onready var _runner_visual: RunnerVisual = %RunnerVisualBlue
@onready var _dust: GPUParticles2D = %Dust

signal walked_to

func _physics_process(delta: float) -> void :
	var direction := global_position.direction_to(get_global_mouse_position())
	var distance := global_position.distance_to(get_global_mouse_position())
	var speed := max_speed if distance > 100 else max_speed * distance/ 100
	
	var desired_velocity := speed * direction
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	
	
	if velocity.length() > 10.0:
		_dust.emitting = true
		_runner_visual.angle = rotate_toward(_runner_visual.angle, direction.orthogonal().angle(), 8.0 * delta)
		_runner_visual.animation_name = RunnerVisual.Animations.WALK
		var current_speed_percent := velocity.length() / max_speed
		_runner_visual.animation_name = (
			RunnerVisual.Animations.WALK
			if current_speed_percent < 0.8
			else RunnerVisual.Animations.RUN 
		)
	else:
		_dust.emitting = false
		_runner_visual.animation_name = RunnerVisual.Animations.IDLE
	
	move_and_slide()

func walk_to (destination_global_position: Vector2) -> void:
	var direction := global_position.direction_to(destination_global_position)
	_runner_visual.angle = direction.orthogonal().angle()
	_runner_visual.animation_name = RunnerVisual.Animations.WALK
	_dust.emitting = true
	var distance := global_position.distance_to(destination_global_position)
	var duration := distance/ (max_speed * 0.2)
	var tween := create_tween()
	tween.tween_property(self, "global_position", destination_global_position, duration)
	tween.finished.connect(func ():
		_runner_visual.animation_name = RunnerVisual.Animations.IDLE
		_dust.emitting = false
		walked_to.emit()
	)
