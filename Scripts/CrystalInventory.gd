# CrystalInventory.gd
class_name CrystalInventory
extends RefCounted

# Сигнал для слабой связанности (EventBus/Signals pattern)
signal crystal_count_changed(new_count: int)

# Приватное поле (Инкапсуляция)
var _crystal_quantity: int = 0

func add_crystal() -> void:
	_crystal_quantity += 1
	crystal_count_changed.emit(_crystal_quantity)

# Публичный метод для получения данных
func get_quantity() -> int:
	return _crystal_quantity
