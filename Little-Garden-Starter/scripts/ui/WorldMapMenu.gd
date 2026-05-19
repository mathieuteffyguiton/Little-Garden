extends Control

@onready var label: Label = $Panel/MarginContainer/Label

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_world_map"):
		visible = not visible
		refresh()

func refresh() -> void:
	var text := "CARTE DU MONDE\n\nZones débloquées :\n"
	for zone in GameManager.unlocked_zones:
		var done := " ✓" if zone in GameManager.completed_zones else ""
		text += "- " + zone + done + "\n"
	label.text = text
