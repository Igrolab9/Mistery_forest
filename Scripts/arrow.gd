extends Area2D

const LIFETIME := 10.0
const DAMAGE := 1.0
const SAFE_DISTANCE := 24.0  # Дистанция для включения коллизий

var _lifetime: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var _can_collide: bool = false
var _spawn_position: Vector2 = Vector2.ZERO
var _shooter: Node2D = null  # Стрелок, которого игнорируем

var _original_collision_layer: int = 0
var _original_collision_mask: int = 0

func _ready() -> void:
	_lifetime = 0.0
	_can_collide = false
	monitoring = false
	monitorable = false
	body_entered.connect(_on_body_entered)
	z_index = 10
	
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask

func setup(shooter: Node2D) -> void:
	_shooter = shooter
	_spawn_position = global_position

func _physics_process(delta: float) -> void:
	_lifetime += delta
	
	# Включаем коллизии когда стрела улетела на безопасное расстояние
	if not _can_collide:
		var distance_squared := global_position.distance_squared_to(_spawn_position)
		if distance_squared >= SAFE_DISTANCE * SAFE_DISTANCE:
			_can_collide = true
			monitoring = true
			monitorable = true
			collision_layer = _original_collision_layer
			collision_mask = _original_collision_mask
	
	global_position += velocity * delta
	
	if _lifetime >= LIFETIME:
		_return_to_pool()

func _on_body_entered(body: Node2D) -> void:
	# Двойная страховка: никогда не бьём стрелка
	if body == _shooter or body.is_in_group("player"):
		return
	
	# Статические объекты
	if body is StaticBody2D or body is TileMap or body is TileMapLayer:
		_return_to_pool()
		return
	
	# Враги и другие интерактивные объекты
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)
	
	_return_to_pool()

func _return_to_pool() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	call_deferred("_do_return_to_pool")

func _do_return_to_pool() -> void:
	velocity = Vector2.ZERO
	_lifetime = 0.0
	_can_collide = false
	_shooter = null	
	ArrowPool.return_arrow(self)
