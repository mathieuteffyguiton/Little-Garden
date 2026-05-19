extends Node

signal stats_changed
signal ability_unlocked(ability_id: String)

var player_stats := {
	"level": 1,
	"xp": 0,
	"xp_to_next": 100,
	"max_hp": 6,
	"hp": 6,
	"attack": 1,
	"defense": 0,
	"coins": 0
}

var unlocked_zones: Array[String] = ["village", "zone_01"]
var completed_zones: Array[String] = []
var unlocked_abilities: Array[String] = []

func add_xp(amount: int) -> void:
	player_stats.xp += amount
	while player_stats.xp >= player_stats.xp_to_next:
		player_stats.xp -= player_stats.xp_to_next
		level_up()
	stats_changed.emit()

func level_up() -> void:
	player_stats.level += 1
	player_stats.xp_to_next = int(player_stats.xp_to_next * 1.25)
	player_stats.max_hp += 1
	player_stats.hp = player_stats.max_hp
	player_stats.attack += 1 if player_stats.level % 2 == 0 else 0
	player_stats.defense += 1 if player_stats.level % 3 == 0 else 0

func add_coins(amount: int) -> void:
	player_stats.coins += amount
	stats_changed.emit()

func damage_player(amount: int) -> void:
	var final_damage: int = max(amount - player_stats.defense, 1)
	player_stats.hp = max(player_stats.hp - final_damage, 0)
	stats_changed.emit()

func heal_player(amount: int) -> void:
	player_stats.hp = min(player_stats.hp + amount, player_stats.max_hp)
	stats_changed.emit()

func unlock_ability(ability_id: String) -> void:
	if ability_id not in unlocked_abilities:
		unlocked_abilities.append(ability_id)
		ability_unlocked.emit(ability_id)

func unlock_zone(zone_id: String) -> void:
	if zone_id not in unlocked_zones:
		unlocked_zones.append(zone_id)

func complete_zone(zone_id: String) -> void:
	if zone_id not in completed_zones:
		completed_zones.append(zone_id)
