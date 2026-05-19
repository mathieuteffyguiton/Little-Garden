extends Node

const SAVE_PATH := "user://save_little_garden.json"

func save_game() -> void:
	var save_data := {
		"player_stats": GameManager.player_stats,
		"unlocked_zones": GameManager.unlocked_zones,
		"completed_zones": GameManager.completed_zones,
		"unlocked_abilities": GameManager.unlocked_abilities,
		"equipment": InventoryManager.equipment,
		"items": InventoryManager.items,
		"lore_entries": InventoryManager.lore_entries,
		"equipped_magic": InventoryManager.equipped_magic
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	GameManager.player_stats = parsed.get("player_stats", GameManager.player_stats)
	GameManager.unlocked_zones = parsed.get("unlocked_zones", GameManager.unlocked_zones)
	GameManager.completed_zones = parsed.get("completed_zones", GameManager.completed_zones)
	GameManager.unlocked_abilities = parsed.get("unlocked_abilities", GameManager.unlocked_abilities)

	InventoryManager.equipment = parsed.get("equipment", InventoryManager.equipment)
	InventoryManager.items = parsed.get("items", InventoryManager.items)
	InventoryManager.lore_entries = parsed.get("lore_entries", InventoryManager.lore_entries)
	InventoryManager.equipped_magic = parsed.get("equipped_magic", InventoryManager.equipped_magic)
