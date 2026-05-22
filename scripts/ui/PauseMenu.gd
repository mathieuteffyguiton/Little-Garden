extends CanvasLayer

@onready var root: Control = $Root


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu"):
		toggle()


func toggle() -> void:
	root.visible = not root.visible
	get_tree().paused = root.visible


func close_menu() -> void:
	root.visible = false
	get_tree().paused = false


func _on_resume_button_pressed() -> void:
	close_menu()


func _on_save_button_pressed() -> void:
	var slot := GameState.current_slot if GameState.current_slot > 0 else 1
	SaveManager.save_game(slot)


func _on_inventory_button_pressed() -> void:
	close_menu()
	get_tree().call_group("inventory_menu", "open_menu")


func _on_map_button_pressed() -> void:
	close_menu()
	get_tree().call_group("zone_map_menu", "open_menu")


func _on_settings_button_pressed() -> void:
	close_menu()
	get_tree().call_group("settings_overlay", "open_menu")


func _on_save_and_menu_button_pressed() -> void:
	var slot := GameState.current_slot if GameState.current_slot > 0 else 1
	SaveManager.save_game(slot)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")


func _on_quit_without_save_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
