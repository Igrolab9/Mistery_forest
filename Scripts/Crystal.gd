# Crystal.gd
extends BaseCollectible

signal crystal_collected

func collect() -> void:
	# Кристалл просто эмитит сигнал о том, что его собрали, и уничтожает себя
	crystal_collected.emit()
	queue_free()
