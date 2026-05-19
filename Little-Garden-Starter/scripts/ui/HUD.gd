extends CanvasLayer

@onready var stats_label: Label = $StatsLabel

func _ready() -> void:
	GameManager.stats_changed.connect(update_stats)
	update_stats()

func update_stats() -> void:
	var s = GameManager.player_stats
	stats_label.text = "Niv %s | HP %s/%s | XP %s/%s | ATK %s | DEF %s | Pièces %s" % [
		s.level, s.hp, s.max_hp, s.xp, s.xp_to_next, s.attack, s.defense, s.coins
	]
