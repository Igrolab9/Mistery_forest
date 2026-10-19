extends Camera2D

@export var player_target: CharacterBody2D
@export var camera_offset: Vector2 = Vector2(150, -50)
@export var follow_speed: float = 5.0  # Скорость следования

func _process(delta: float) -> void:
	if player_target:
		var target_position := player_target.position + camera_offset
		position = position.lerp(target_position, follow_speed * delta)
