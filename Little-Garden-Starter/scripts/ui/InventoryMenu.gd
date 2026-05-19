extends Control

@onready var label: Label = $Panel/MarginContainer/Label

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		visible = not visible
		refresh()

func refresh() -> void:
	var s = GameManager.player_stats
	label.text = """INVENTAIRE

Stats :
Niveau : %s
HP : %s/%s
XP : %s/%s
Attaque : %s
Défense : %s
Pièces : %s

Équipement :
Épée : %s
Bouclier : %s
Armure : %s

Magies équipées :
1. %s
2. %s
3. %s
4. %s

Lore trouvé : %s
""" % [
		s.level, s.hp, s.max_hp, s.xp, s.xp_to_next, s.attack, s.defense, s.coins,
		InventoryManager.equipment.sword,
		InventoryManager.equipment.shield,
		InventoryManager.equipment.armor,
		InventoryManager.equipped_magic[0],
		InventoryManager.equipped_magic[1],
		InventoryManager.equipped_magic[2],
		InventoryManager.equipped_magic[3],
		InventoryManager.lore_entries.size()
	]
