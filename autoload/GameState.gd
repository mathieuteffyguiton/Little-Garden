extends Node
signal state_changed

var current_slot := -1
var current_zone := "village"
var stats := {}
var inventory := {}
var progression := {}

func _ready() -> void:
	reset_new_game()

func reset_new_game() -> void:
	stats = {"level":1,"xp":0,"xp_to_next":100,"hp":20,"max_hp":20,"attack":1,"defense":0,"gold":0}
	inventory = {
		"equipment":{"sword":"Épée en bois","shield":"Bouclier en bois"},
		"resources":{"fer_brut":0,"bois":0,"fragment_noir":0},
		"items":{"potion":1},
		"quests":{"current":"Explorer la zone test.","available":["Explorer la zone test."]},
		"lore":[]
	}
	progression = {
		"unlocked_zones":["village"],
		"zone_maps":{"village":true,"zone_01":false,"zone_02":false,"zone_03":false,"zone_04":false,"zone_05":false,"zone_06":false,"zone_07":false,"zone_08":false,"zone_09":false,"zone_10":false},
		"completed_zones":[]
	}
	current_zone = "village"
	state_changed.emit()

func get_save_data(save_name: String) -> Dictionary:
	return {"save_name":save_name,"timestamp_unix":Time.get_unix_time_from_system(),"current_zone":current_zone,"stats":stats,"inventory":inventory,"progression":progression}

func apply_save_data(data: Dictionary) -> void:
	current_zone = str(data.get("current_zone","village"))
	stats = data.get("stats", stats)
	inventory = data.get("inventory", inventory)
	progression = data.get("progression", progression)
	state_changed.emit()

func has_zone_map(zone_id: String) -> bool:
	var maps: Dictionary = progression.get("zone_maps", {})
	return bool(maps.get(zone_id, false))
