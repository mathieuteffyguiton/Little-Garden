extends Node

const SAVE_DIR := "user://saves/"
const SLOT_COUNT := 3

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func get_save_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot

func has_save(slot: int) -> bool:
	return slot >= 1 and slot <= SLOT_COUNT and FileAccess.file_exists(get_save_path(slot))

func new_game(slot: int, save_name: String = "") -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		return false
	GameState.current_slot = slot
	GameState.reset_new_game()
	if save_name.strip_edges() == "":
		save_name = "Partie %d" % slot
	return save_game(slot, save_name)

func save_game(slot: int, save_name: String = "") -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		return false
	if save_name.strip_edges() == "":
		save_name = get_slot_name(slot)
		if save_name == "":
			save_name = "Partie %d" % slot
	GameState.current_slot = slot
	var file := FileAccess.open(get_save_path(slot), FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(GameState.get_save_data(save_name), "\t"))
	return true

func load_game(slot: int) -> bool:
	if not has_save(slot):
		return false
	var file := FileAccess.open(get_save_path(slot), FileAccess.READ)
	if not file:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	GameState.current_slot = slot
	GameState.apply_save_data(parsed)
	return true

func delete_save(slot: int) -> bool:
	if not has_save(slot):
		return false
	DirAccess.remove_absolute(get_save_path(slot))
	return true

func get_latest_save_slot() -> int:
	var best_slot := -1
	var best_time := -1
	for slot in range(1, SLOT_COUNT + 1):
		if has_save(slot):
			var modified := FileAccess.get_modified_time(get_save_path(slot))
			if modified > best_time:
				best_time = modified
				best_slot = slot
	return best_slot

func continue_latest_game() -> bool:
	var slot := get_latest_save_slot()
	return false if slot == -1 else load_game(slot)

func read_slot_data(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var file := FileAccess.open(get_save_path(slot), FileAccess.READ)
	if not file:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func get_slot_name(slot: int) -> String:
	return str(read_slot_data(slot).get("save_name",""))

func get_slot_label(slot: int) -> String:
	if not has_save(slot):
		return "Slot %d — vide" % slot
	var data := read_slot_data(slot)
	var stats: Dictionary = data.get("stats", {})
	var time := int(data.get("timestamp_unix", 0))
	var date := Time.get_datetime_string_from_unix_time(time, true) if time > 0 else "date inconnue"
	return "%s — Niv.%s — %s" % [data.get("save_name","Partie %d" % slot), stats.get("level","?"), date]
