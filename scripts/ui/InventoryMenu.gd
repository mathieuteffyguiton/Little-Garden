extends CanvasLayer

@onready var root: Control = $Root
@onready var equipment_label: Label = $Root/Center/Panel/VBox/Tabs/Equipement/EquipmentLabel
@onready var resources_label: Label = $Root/Center/Panel/VBox/Tabs/Ressources/ResourcesLabel
@onready var items_label: Label = $Root/Center/Panel/VBox/Tabs/Objets/ItemsLabel
@onready var quests_label: Label = $Root/Center/Panel/VBox/Tabs/Quetes/QuestsLabel
@onready var lore_label: Label = $Root/Center/Panel/VBox/Tabs/Lore/LoreLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("inventory_menu")
	root.visible = false
	GameState.state_changed.connect(refresh)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		if root.visible:
			close_menu()
		else:
			open_menu()


func open_menu() -> void:
	if get_tree().paused and not root.visible:
		return

	root.visible = true
	get_tree().paused = true
	refresh()


func close_menu() -> void:
	root.visible = false
	get_tree().paused = false


func refresh() -> void:
	var inv: Dictionary = GameState.inventory

	equipment_label.text = dict_to_lines(inv.get("equipment", {}))
	resources_label.text = dict_to_lines(inv.get("resources", {}))
	items_label.text = dict_to_lines(inv.get("items", {}))

	var quests: Dictionary = inv.get("quests", {})
	quests_label.text = "Tâche actuelle :\n%s\n\nDisponibles :\n%s" % [
		quests.get("current", "Aucune"),
		array_to_lines(quests.get("available", []))
	]

	var lore_text := array_to_lines(inv.get("lore", []))
	lore_label.text = lore_text if lore_text != "" else "Aucun fragment d'histoire trouvé."


func dict_to_lines(data: Dictionary) -> String:
	if data.is_empty():
		return "Vide."

	var output := ""
	for key in data.keys():
		output += "%s : %s\n" % [key, data[key]]

	return output.strip_edges()


func array_to_lines(data: Array) -> String:
	if data.is_empty():
		return "Vide."

	var output := ""
	for item in data:
		output += "- %s\n" % item

	return output.strip_edges()


func _on_close_button_pressed() -> void:
	close_menu()
