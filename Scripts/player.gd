extends CharacterBody2D

@onready var _player_animation: AnimatedSprite2D = $Player_animation
@onready var _pickup_area: Area2D = $PickupArea
@onready var _bow_barrel: Marker2D = $Marker2D

var _player_health: float = 1.0

const ATTACK_RELEASE_FRAME := 2

var _inventory: CrystalInventory
var _movement: PlayerMovement
var _bow: BowController
var _health: HealthComponent
var _barrel_default_x: float = 0.0
var _is_attacking: bool = false
var _is_dead: bool = false            # НОВОЕ: состояние смерти
var _restart_requested: bool = false  # НОВОЕ: защита от двойного перезапуска

func _ready() -> void:
	_player_animation._play_idle_animation()
	
	_inventory = CrystalInventory.new()
	_inventory.crystal_count_changed.connect(_on_crystal_count_changed)
	
	_movement = PlayerMovement.new(self, _player_animation)
	_movement.jumped.connect(_on_player_jumped)
	_movement.direction_changed.connect(_on_direction_changed)
	
	_pickup_area.area_entered.connect(_on_pickup_area_area_entered)

	_barrel_default_x = abs(_bow_barrel.position.x)
	
	_bow = BowController.new(_bow_barrel, _movement, self)
	_bow.attack_started.connect(_on_attack_started)
	_bow.arrow_fired.connect(_on_arrow_fired)
	
	_health = HealthComponent.new(self, _player_health)
	_health.died.connect(_on_death)
	
	_player_animation.frame_changed.connect(_on_attack_frame_changed)
	_player_animation.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Мёртвый игрок не двигается и не анимируется движением
	if _is_dead:
		return
	
	_movement.update(delta)
	
	if _bow:
		_bow.update(delta)
	
	_update_animation()

func _unhandled_input(event: InputEvent) -> void:
	if _is_dead:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_try_attack()
			get_viewport().set_input_as_handled()

func _try_attack() -> void:
	if _is_attacking:
		return
	_bow.fire()

func _on_attack_started() -> void:
	_is_attacking = true
	_player_animation._play_attack_animation()

func _on_attack_frame_changed() -> void:
	if not _is_attacking:
		return
	if _player_animation.animation != &"Attack":
		return
	if _player_animation.frame == ATTACK_RELEASE_FRAME:
		_bow.release_arrow()

func _on_animation_finished() -> void:
	match _player_animation.animation:
		&"Attack":
			_is_attacking = false
		&"Death":
			# НОВОЕ: анимация смерти доиграла — перезапускаем сцену
			_restart_scene()

func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area is BaseCollectible:
		var collectible := area as BaseCollectible
		collectible.collect()
		_inventory.add_crystal()

func _on_crystal_count_changed(new_count: int) -> void:
	print("Кристаллов собрано: ", new_count)

func _on_player_jumped() -> void:
	print("Прыжок!")

func _on_direction_changed(new_direction: int) -> void:
	if new_direction == 0:
		return
	_bow_barrel.position.x = _barrel_default_x * new_direction

func get_crystal_quantity() -> int:
	return _inventory.get_quantity()

func is_moving() -> bool:
	return _movement.get_velocity().x != 0

func _on_arrow_fired(position: Vector2) -> void:
	pass

func _update_animation() -> void:
	if _is_attacking:
		return
	if not _movement.is_on_floor(): 
		_player_animation._play_jump_animation()
	elif is_moving():
		_player_animation._play_walk_animation()
	else:
		_player_animation._play_idle_animation()

# Методы нанесения урона
func take_damage(amount: float) -> void:
	print("Получен урон!")
	_health.take_damage(amount)

func _on_death() -> void:
	print("Игрок погиб! Game Over.")
	_is_dead = true
	velocity = Vector2.ZERO
	_player_animation._play_death_animation()
	
	# НОВОЕ: страховка на случай, если анимации Death нет или она зациклена.
	# После перезагрузки сцены игрок будет освобождён, и соединение само отвалится.
	get_tree().create_timer(1.5).timeout.connect(_restart_scene)

func _restart_scene() -> void:
	if _restart_requested:
		return
	_restart_requested = true
	get_tree().reload_current_scene()
