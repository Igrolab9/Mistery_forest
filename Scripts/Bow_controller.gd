class_name BowController
extends RefCounted

const ARROW_SPEED := 500.0
const FIRE_RATE := 1.6          # чуть реже, чем длина анимации (3 кадра / 5 FPS = 0.6 c)
const SPAWN_OFFSET := 16.0

var _barrel: Node2D
var _movement: PlayerMovement
var _owner: CharacterBody2D
var _fire_cooldown: float = 0.0

signal attack_started            # НОВОЕ: игрок проигрывает анимацию
signal arrow_fired(arrow_position: Vector2)

func _init(barrel: Node2D, movement: PlayerMovement, owner_body: CharacterBody2D) -> void:
	_barrel = barrel
	_movement = movement
	_owner = owner_body
	if _barrel == null:
		push_error("BowController requires a valid barrel Node2D")

func update(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown -= delta

func fire() -> void:
	# ТЕПЕРЬ: только старт атаки. Стрела НЕ создаётся.
	if _fire_cooldown > 0.0:
		return
	_fire_cooldown = 1.0 / FIRE_RATE
	attack_started.emit()

func release_arrow() -> void:
	# НОВОЕ: вызывается, когда анимация дошла до кадра спуска тетивы
	var facing := _movement.get_facing_direction()
	var shoot_direction := Vector2(facing, 0.0)

	var arrow := ArrowPool.get_arrow()
	arrow.global_position = _barrel.global_position + shoot_direction * SPAWN_OFFSET
	arrow.global_rotation = 0.0 if facing > 0 else PI
	arrow.setup(_owner)
	arrow.velocity = shoot_direction * ARROW_SPEED

	arrow_fired.emit(arrow.global_position)
