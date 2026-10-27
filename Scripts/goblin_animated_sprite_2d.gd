extends AnimatedSprite2D

const ANIMATION_IDLE: String = "Idle"
const ANIMATION_ATTACK: String = "Attack"
const ANIMATION_DEATH: String = "Death"


func _play_idle_animation()-> void:
	play(ANIMATION_IDLE)

func _play_attack_animation()-> void:
	play(ANIMATION_ATTACK)

func _play_death_animation()-> void:
	play(ANIMATION_DEATH)
