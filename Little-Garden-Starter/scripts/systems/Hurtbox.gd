extends Area2D

@export var hp: int = 3
signal died

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		died.emit()
		get_parent().queue_free()
