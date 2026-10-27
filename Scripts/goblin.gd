extends CharacterBody2D

@onready var goblin_animation: AnimatedSprite2D = $Goblin_AnimatedSprite2D
@onready var bow_barrel: Marker2D = $Marker2D
@onready var detection_area: Area2D = $DetectionArea

const SHOOT_INTERVAL: float = 3.0
const MAX_HEALTH: float = 1.0
const AIM_DELAY: float = 0.4  # Задержка перед выстрелом (в секундах)

var player: CharacterBody2D = null
var shoot_timer: float = 0.0
var is_aiming: bool = false
var barrel_default_x: float = 0.0
var aim_timer: float = 0.0  # Таймер прицеливания

var _health: HealthComponent
var _is_dead: bool = false

func _ready() -> void:
	goblin_animation._play_idle_animation()
	barrel_default_x = abs(bow_barrel.position.x)
	scale.x = -1
	bow_barrel.position.x = -barrel_default_x
	
	if detection_area:
		detection_area.body_entered.connect(_on_player_detected)
		detection_area.body_exited.connect(_on_player_lost)
	
	add_to_group("goblin")
	
	_health = HealthComponent.new(self, MAX_HEALTH)
	_health.died.connect(_on_death)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
		
	if player:
		shoot_timer += delta
		
		if shoot_timer >= SHOOT_INTERVAL:
			# Начинаем прицеливание
			if not is_aiming:
				is_aiming = true
				goblin_animation._play_attack_animation()
				aim_timer = 0.0
			else:
				# Отсчитываем время прицеливания
				aim_timer += delta
				if aim_timer >= AIM_DELAY:
					_shoot_arrow()
					shoot_timer = 0.0
					is_aiming = false
					aim_timer = 0.0
					goblin_animation._play_idle_animation()
	else:
		if is_aiming:
			is_aiming = false
			aim_timer = 0.0
			goblin_animation._play_idle_animation()
	
	move_and_slide()

func _on_player_detected(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		shoot_timer = SHOOT_INTERVAL 
		print("Игрок обнаружен! Выстрел сразу.")

func _on_player_lost(body: Node2D) -> void:
	if body == player:
		player = null
		is_aiming = false
		aim_timer = 0.0
		shoot_timer = 0.0
		print("Игрок потерян")

func _shoot_arrow() -> void:
	if not player or _is_dead:
		return
	
	var arrow = preload("res://Scenes/arrow.tscn").instantiate()
	get_tree().root.add_child(arrow)
	arrow.global_position = bow_barrel.global_position
	
	if arrow.has_method("setup"):
		arrow.setup(self)
	
	arrow.velocity = Vector2.LEFT * 300.0
	arrow.rotation = 0
	
	print("Гоблин выстрелил!")

func take_damage(amount: float) -> void:
	if _is_dead:
		return
		
	print("Гоблин получил урон: ", amount)
	_health.take_damage(amount)

func _on_death() -> void:
	print("Гоблин погиб!")
	_is_dead = true
	velocity = Vector2.ZERO
	
	goblin_animation._play_death_animation()
	
	if detection_area:
		detection_area.set_deferred("monitoring", false)
		detection_area.set_deferred("monitorable", false)
	
	get_tree().create_timer(0.6).timeout.connect(queue_free)
