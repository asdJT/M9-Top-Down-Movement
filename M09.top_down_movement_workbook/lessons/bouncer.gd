extends CharacterBody2D

@export var max_speed := 700.0
@export var avoidance_strength := 21000.0
@export var acceleration := 1200.0

@onready var _runner_visual: RunnerVisual = %RunnerVisualBlue
@onready var _dust: GPUParticles2D = %Dust
@onready var _ray_casts: Node2D = %RayCasts

var current_speed_limit := 100.0

func get_global_player_position() -> Vector2:
	return get_tree().root.get_node("Game/Runner").global_position

func _physics_process(delta: float) -> void :
	var direction := global_position.direction_to(get_global_player_position())
	var distance := global_position.distance_to(get_global_player_position())
	var speed := current_speed_limit if distance > 100 else current_speed_limit * distance/ 80
	
	current_speed_limit = move_toward(current_speed_limit, max_speed, 40)
	
	var desired_velocity := speed * direction
	desired_velocity += calculate_avoidance_force() * delta
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	if velocity.length() > 10.0:
		_dust.emitting = true
		_runner_visual.angle = rotate_toward(_runner_visual.angle, direction.orthogonal().angle(), 8.0 * delta)
		_ray_casts.rotation = _runner_visual.angle
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


@onready var _hit_box: Area2D = %HitBox

func _ready() -> void:
	_hit_box.body_entered.connect(func(body: Node) -> void:
		if body is Runner:
			get_tree().reload_current_scene.call_deferred()
	)
	for raycast: RayCast2D in _ray_casts.get_children():
		raycast.add_exception(self)
		raycast.add_exception(get_tree().root.get_node("Game/Runner"))

func calculate_avoidance_force() -> Vector2:
	var avoidance_force := Vector2.ZERO
	for raycast: RayCast2D in _ray_casts.get_children():
		if raycast.is_colliding():
			var collision_position := raycast.get_collision_point()
			var direction_away_from_obstacle := collision_position.direction_to(raycast.global_position)

			# The more the raycast is into the obstacle, the more we want to push away from the obstacle.
			var ray_length := raycast.target_position.length()
			var intensity := 1.0 - collision_position.distance_to(raycast.global_position) / ray_length

			var force := direction_away_from_obstacle * avoidance_strength * intensity
			avoidance_force += force
			
	if avoidance_force.length() > 15000:
		avoidance_force = avoidance_force.normalized() * 10000
		
	return avoidance_force
