extends Node

const ARROW_SCENE := preload("res://Scenes/arrow.tscn")
const POOL_SIZE := 10

var _pool: Array[Area2D] = []
var _active_arrows: Array[Area2D] = []

func _ready() -> void:
	for i in POOL_SIZE:
		var arrow := ARROW_SCENE.instantiate() as Area2D
		arrow.set_process(false)
		arrow.set_physics_process(false)
		arrow.visible = false
		add_child(arrow)
		_pool.append(arrow)

func get_arrow() -> Area2D:
	var arrow: Area2D
	
	if _pool.size() > 0:
		arrow = _pool.pop_back()
	else:
		push_warning("ArrowPool exhausted! Creating new arrow dynamically.")
		arrow = ARROW_SCENE.instantiate() as Area2D
		add_child(arrow)
	
	# Полный сброс перед использованием
	arrow.set_process(true)
	arrow.set_physics_process(true)
	arrow.visible = true
	arrow._lifetime = 0.0
	arrow._can_collide = false
	arrow._shooter = null
	arrow.velocity = Vector2.ZERO
	arrow.monitoring = false
	arrow.monitorable = false
	
	_active_arrows.append(arrow)
	return arrow

func return_arrow(arrow: Area2D) -> void:
	# Полное обнуление перед возвратом в пул
	arrow.set_process(false)
	arrow.set_physics_process(false)
	arrow.visible = false
	arrow.velocity = Vector2.ZERO
	arrow.monitoring = false
	arrow.monitorable = false
	arrow.collision_layer = 0
	arrow.collision_mask = 0
	arrow._shooter = null
	
	_active_arrows.erase(arrow)
	_pool.append(arrow)
