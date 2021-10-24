extends Node


onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func _enter_tree() -> void:
	randomize()


func random_angle() -> float:
	return range_f(0, TAU)


func random_angle_centered() -> float:
	return range_f(0, TAU) - TAU / 2


func random_vec(max_length: int = 1) -> Vector2:
	return Utils.ang2vec(random_angle()) * range_f(0, max_length)


func random_grid_dir() -> Vector2:
	# picks a random direction on square grid
	return Vector2(range_i(-1, 1), range_i(-1, 1))


func random_grid_dir_cardinal(with_zero: bool = true) -> Vector2:
	# picks a random cardinal direction on square grid
	var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	if with_zero:
		dirs.append(Vector2.ZERO)
	return random_choice(dirs)


func random_choice(array: Array):
	return array[range_i(0, len(array) - 1)]


func percent(value: float) -> bool:
	return range_f(0, 100) < value


func f() -> float:
	return rng.randf()


func coin_flip() -> bool:
	return rng.randi() % 2 == 0


func range_f(from: float, to: float) -> float:
	return rng.randf_range(from, to)


func randfn(mean: float = 0.0, deviation: float = 1.0) -> float:
	return rng.randfn(mean, deviation)


func i() -> int:
	return rng.randi()


func range_i(from: int, to: int) -> int:
	return rng.randi_range(from, to)
