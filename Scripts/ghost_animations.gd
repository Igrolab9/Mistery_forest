extends AnimatedSprite2D

const ANIMATION_IDLE: String = "Idle"
const ANIMATION_WALK: String = "Walk"
const ANIMATION_JUMP: String = "Jump"

func _play_idle_animation()-> void:
	play(ANIMATION_IDLE)
	animation_looped

func _play_walk_animation()-> void:
	play(ANIMATION_WALK)

func _play_jump_animation()-> void:
	play(ANIMATION_JUMP)
