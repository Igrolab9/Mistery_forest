# BaseCollectible.gd
class_name BaseCollectible
extends Area2D

# Абстрактный метод. Наследники обязаны его реализовать.
func collect() -> void:
	pass
