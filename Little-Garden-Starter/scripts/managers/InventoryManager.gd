extends Node

signal inventory_changed

var equipment := {
	"sword": "rusty_sword",
	"shield": "wooden_shield",
	"armor": "old_clothes"
}

var items := {
	"potions": 0,
	"keys": 0
}

var lore_entries: Array[String] = []

var equipped_magic: Array[String] = ["", "", "", ""]

func add_item(item_id: String, amount: int = 1) -> void:
	items[item_id] = items.get(item_id, 0) + amount
	inventory_changed.emit()

func add_lore(entry_id: String) -> void:
	if entry_id not in lore_entries:
		lore_entries.append(entry_id)
		inventory_changed.emit()

func equip_magic(slot: int, ability_id: String) -> void:
	if slot < 0 or slot >= equipped_magic.size():
		return
	if ability_id in GameManager.unlocked_abilities:
		equipped_magic[slot] = ability_id
		inventory_changed.emit()
