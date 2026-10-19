extends AnimatedSprite2D

const ANIMATION_IDLE: String = "Idle"
const ANIMATION_WALK: String = "Walk"
const ANIMATION_JUMP: String = "Jump"
const ANIMATION_ATTACK: String = "Attack"
const ANIMATION_DEATH: String = "Death"

func _play_idle_animation()-> void:
	play(ANIMATION_IDLE)
	animation_looped

func _play_walk_animation()-> void:
	play(ANIMATION_WALK)

func _play_jump_animation()-> void:
	play(ANIMATION_JUMP)
	
func _play_attack_animation()-> void:
	if animation != ANIMATION_ATTACK:
		play(ANIMATION_ATTACK)
	frame = 0

func _play_death_animation()-> void:
	play(ANIMATION_DEATH)
