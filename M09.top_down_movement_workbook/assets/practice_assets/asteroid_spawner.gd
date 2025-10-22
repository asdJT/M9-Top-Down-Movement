extends Control

const AsteroidScene := preload("asteroid_for_practice.tscn")

@export var field_size := Vector2i(8000, 8000)
@export var safe_zone := Vector2i(1920, 1080)
@export var total_asteroids := 500

var _locations := {}

func _ready() -> void:
	for i in total_asteroids:
		var asteroid := AsteroidScene.instantiate()
		asteroid.position = _find_suitable_location()
		add_child(asteroid)


func _find_suitable_location() -> Vector2i:
	var v := _get_random_location()
	var max_iterations := 10000
	while _is_forbidden_location(v) and max_iterations > 0:
		max_iterations -= 1
		v = _get_random_location()
	if not _locations.has(v.x):
		_locations[v.x] = {}
	_locations[v.x][v.y] = true
	return v


func _get_random_location() -> Vector2i:
	return Vector2i(
		randf_range(- (field_size.x / 2), field_size.x / 2),
		randf_range(- (field_size.y / 2), field_size.x / 2)
	)


func _is_forbidden_location(location: Vector2i) -> bool:
	if get_rect().has_point(location - Vector2i(size / 2)):
		return true
	if _locations.has(location.x) and _locations[location.x].has(location.y):
		return true
	return false
