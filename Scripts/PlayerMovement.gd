class_name PlayerMovement
extends RefCounted

const SPEED := 300.0
const JUMP_VELOCITY := -300.0

# Клавиши назначены напрямую, без Input System
# Используем ФИЗИЧЕСКИЕ коды: работает и на QWERTY (A/D), и на ЦФЫВ (Ф/В)
const MOVE_LEFT_KEY := KEY_A
const MOVE_RIGHT_KEY := KEY_D

var _body: CharacterBody2D
var _sprite: AnimatedSprite2D
var _facing_direction: int = 1  # ВАЖНО: никогда не бывает 0

signal jumped
signal direction_changed(new_direction: int)

func _init(body: CharacterBody2D, sprite: AnimatedSprite2D = null) -> void:
	_body = body
	_sprite = sprite
	if _sprite != null:
		_sprite.scale.x = 1

func update(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	_update_sprite_direction()
	_body.move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not _body.is_on_floor():
		_body.velocity += _body.get_gravity() * delta

func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and _body.is_on_floor():
		_body.velocity.y = JUMP_VELOCITY
		jumped.emit()

func _handle_movement() -> void:
	# Прямой опрос клавиш вместо Input.get_axis()
	var direction := 0.0
	if Input.is_physical_key_pressed(MOVE_RIGHT_KEY):
		direction += 1.0
	if Input.is_physical_key_pressed(MOVE_LEFT_KEY):
		direction -= 1.0
	
	if direction != 0.0:
		_body.velocity.x = direction * SPEED
		
		# Обновляем направление взгляда только при реальном движении
		var new_direction := -1 if direction < 0.0 else 1
		if new_direction != _facing_direction:
			_facing_direction = new_direction
			direction_changed.emit(_facing_direction)
	else:
		_body.velocity.x = move_toward(_body.velocity.x, 0.0, SPEED)

func _update_sprite_direction() -> void:
	if _sprite == null:
		return
	if _body.velocity.x < 0:
		_sprite.scale.x = -1
	elif _body.velocity.x > 0:
		_sprite.scale.x = 1

func get_facing_direction() -> int:
	return _facing_direction

func get_velocity() -> Vector2:
	return _body.velocity

func is_on_floor() -> bool:
	return _body.is_on_floor()
