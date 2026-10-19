class_name Spears
extends Area2D

# Урон копий: гарантированно смертельный при любом макс. здоровье игрока.
# HealthComponent сам обеспечит однократность срабатывания (защита if health <= 0).
const SPEAR_DAMAGE: float = 999.0

func _ready() -> void:
	# Корень сцены сам является зоной касания — форма уже задана в сцене
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _is_player(body):
		body.take_damage(SPEAR_DAMAGE)


func _is_player(body: Node2D) -> bool:
	# Duck-typing + проверка имени: бьём только игрока,
	# призрака и прочие тела копья не трогают
	return body is CharacterBody2D and body.name == "Player"
