extends CharacterBody2D

class_name Ghost

# Константы вместо магических чисел
const MOVE_SPEED: float = 100.0
const DETECTION_RANGE: float = 200.0
const CHASE_SPEED: float = 150.0
const CONTACT_DAMAGE: float = 1.0   # НОВОЕ: урон при касании
const TOUCH_RADIUS: float = 20.0    # НОВОЕ: радиус зоны касания

# Состояния
enum State { IDLE, CHASE }

# Приватные поля
var _ghost_health: float = 1.0
var _current_state: State = State.IDLE
var _player: CharacterBody2D = null
var _detection_area: Area2D
var _health: HealthComponent

@onready var _ghost_animations: AnimatedSprite2D = $Ghost_animations
@onready var _touch_area: Area2D  = $Area2D      # НОВОЕ: зона касания
# Публичные методы
func get_current_state() -> State:
	return _current_state

func _ready() -> void:
	_ghost_animations._play_idle_animation()
	_setup_detection_area()
	_setup_touch_area()
	_connect_signals()
	_health = HealthComponent.new(self, _ghost_health)
	_health.died.connect(_on_death)

func _physics_process(delta: float) -> void:
	match _current_state:
		State.IDLE:
			_idle_state()
		State.CHASE:
			_chase_state(delta)

# Приватные методы
func _setup_detection_area() -> void:
	_detection_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = DETECTION_RANGE
	collision_shape.shape = shape
	_detection_area.add_child(collision_shape)
	add_child(_detection_area)

func _setup_touch_area() -> void:
	# НОВОЕ: маленькая зона вокруг призрака для нанесения урона при касании.
	# CharacterBody2D с CharacterBody2D сигналов не шлют, поэтому нужен Area2D.
	_touch_area = Area2D.new()
	_touch_area.name = "TouchArea"
	var collision_shape := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = TOUCH_RADIUS
	collision_shape.shape = shape
	_touch_area.add_child(collision_shape)
	add_child(_touch_area)

func _connect_signals() -> void:
	_detection_area.body_entered.connect(_on_body_entered)
	_detection_area.body_exited.connect(_on_body_exited)
	_touch_area.body_entered.connect(_on_touch_body_entered)

func _idle_state() -> void:
	velocity = Vector2.ZERO

func _chase_state(delta: float) -> void:
	if _player == null:
		_transition_to_idle()
		return
		
	var direction = (_player.global_position - global_position).normalized()
	velocity = direction * CHASE_SPEED
	move_and_slide()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Player":
		_player = body
		_transition_to_chase()

func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_transition_to_idle()

func _on_touch_body_entered(body: Node2D) -> void:
	# НОВОЕ: бьём только игрока, один раз (HealthComponent сам защитит от повторного урона после смерти)
	if body is CharacterBody2D and body.name == "Player":
		body.take_damage(CONTACT_DAMAGE)

func _transition_to_chase() -> void:
	_current_state = State.CHASE

func _transition_to_idle() -> void:
	_current_state = State.IDLE

# Методы нанесения урона
func take_damage(amount: float) -> void:
	print("Получен урон!")
	_health.take_damage(amount)

func _on_death() -> void:
	print("Призрак погиб! ")
	queue_free()
