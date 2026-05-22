extends Control

@onready var main_panel = $Root/MainPanel
@onready var slots_panel = $Root/SlotsPanel
@onready var settings_panel = $Root/SettingsPanel

@onready var continue_button = $Root/MainPanel/ContinueButton
@onready var slot_title = $Root/SlotsPanel/Title
@onready var save_name_edit = $Root/SlotsPanel/SaveNameEdit
@onready var slot_list = $Root/SlotsPanel/SlotList
@onready var delete_button = $Root/SlotsPanel/DeleteSaveButton

@onready var master_slider = $Root/SettingsPanel/VBox/SettingsTabs/Audio/AudioGrid/MasterSlider
@onready var master_value = $Root/SettingsPanel/VBox/SettingsTabs/Audio/AudioGrid/MasterValue
@onready var music_slider = $Root/SettingsPanel/VBox/SettingsTabs/Audio/AudioGrid/MusicSlider
@onready var music_value = $Root/SettingsPanel/VBox/SettingsTabs/Audio/AudioGrid/MusicValue
@onready var sfx_slider = $Root/SettingsPanel/VBox/SettingsTabs/Audio/AudioGrid/SfxSlider
@onready var sfx_value = $Root/SettingsPanel/VBox/SettingsTabs/Audio/AudioGrid/SfxValue
@onready var fullscreen_check = $Root/SettingsPanel/VBox/SettingsTabs/Audio/FullscreenCheck

@onready var controls_grid = $Root/SettingsPanel/VBox/SettingsTabs/Touches/ControlsScroll/ControlsGrid
@onready var keyboard_label = $Root/SettingsPanel/VBox/SettingsTabs/Touches/KeyboardLabel
@onready var wait_label = $Root/SettingsPanel/VBox/SettingsTabs/Touches/WaitLabel

@onready var language_option = $Root/SettingsPanel/VBox/SettingsTabs/Langues/LanguageOption

var slot_mode := "new"
var selected_slot := -1


func _ready() -> void:
	get_tree().paused = false
	InputManager.controls_changed.connect(refresh_controls)
	InputManager.waiting_for_key.connect(_on_waiting_for_key)

	language_option.clear()
	language_option.add_item("Français")
	language_option.add_item("English")

	show_main()
	refresh()


func show_main() -> void:
	main_panel.visible = true
	slots_panel.visible = false
	settings_panel.visible = false


func show_slots() -> void:
	main_panel.visible = false
	slots_panel.visible = true
	settings_panel.visible = false


func show_settings() -> void:
	main_panel.visible = false
	slots_panel.visible = false
	settings_panel.visible = true


func refresh() -> void:
	continue_button.disabled = SaveManager.get_latest_save_slot() == -1
	refresh_audio()
	refresh_controls()
	refresh_slots()


func refresh_audio() -> void:
	master_slider.value = SettingsManager.settings["master_volume"]
	music_slider.value = SettingsManager.settings["music_volume"]
	sfx_slider.value = SettingsManager.settings["sfx_volume"]
	fullscreen_check.button_pressed = SettingsManager.settings["fullscreen"]

	master_value.text = "%d%%" % int(master_slider.value)
	music_value.text = "%d%%" % int(music_slider.value)
	sfx_value.text = "%d%%" % int(sfx_slider.value)


func refresh_controls() -> void:
	for child in controls_grid.get_children():
		child.queue_free()

	keyboard_label.text = "Clavier : " + InputManager.get_keyboard_status_text()

	for header in ["Action", "Touche", ""]:
		var label := Label.new()
		label.text = header
		controls_grid.add_child(label)

	for action in InputManager.action_order:
		var action_label := Label.new()
		action_label.text = InputManager.action_names_fr.get(action, action)
		controls_grid.add_child(action_label)

		var key_label := Label.new()
		key_label.text = InputManager.get_action_label(action)
		controls_grid.add_child(key_label)

		var button := Button.new()
		button.text = "Modifier"
		button.pressed.connect(func(): InputManager.start_rebind(action))
		controls_grid.add_child(button)

	wait_label.text = "Clique sur Modifier, puis appuie sur une touche."


func refresh_slots() -> void:
	slot_list.clear()
	for slot in range(1, SaveManager.SLOT_COUNT + 1):
		slot_list.add_item(SaveManager.get_slot_label(slot))


func _on_waiting_for_key(action: String) -> void:
	wait_label.text = "Appuie sur une touche pour : %s" % InputManager.action_names_fr.get(action, action)


func _on_continue_button_pressed() -> void:
	if SaveManager.continue_latest_game():
		get_tree().change_scene_to_file("res://scenes/game/TestScene.tscn")


func _on_new_game_button_pressed() -> void:
	slot_mode = "new"
	selected_slot = -1
	slot_title.text = "NOUVELLE PARTIE"
	save_name_edit.visible = true
	delete_button.visible = false
	save_name_edit.text = ""
	refresh_slots()
	show_slots()


func _on_load_game_button_pressed() -> void:
	slot_mode = "load"
	selected_slot = -1
	slot_title.text = "CHARGER UNE PARTIE"
	save_name_edit.visible = false
	delete_button.visible = true
	refresh_slots()
	show_slots()


func _on_settings_button_pressed() -> void:
	refresh()
	show_settings()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	show_main()
	refresh()


func _on_slot_list_item_selected(index: int) -> void:
	selected_slot = index + 1


func _on_slot_list_item_activated(index: int) -> void:
	var slot := index + 1
	if slot_mode == "new":
		SaveManager.new_game(slot, save_name_edit.text)
		get_tree().change_scene_to_file("res://scenes/game/TestScene.tscn")
	else:
		if SaveManager.load_game(slot):
			get_tree().change_scene_to_file("res://scenes/game/TestScene.tscn")


func _on_delete_save_button_pressed() -> void:
	if selected_slot != -1:
		SaveManager.delete_save(selected_slot)
		selected_slot = -1
		refresh()


func _on_master_slider_value_changed(value: float) -> void:
	SettingsManager.set_master_volume(value)
	refresh_audio()


func _on_music_slider_value_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)
	refresh_audio()


func _on_sfx_slider_value_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)
	refresh_audio()


func _on_fullscreen_check_toggled(value: bool) -> void:
	SettingsManager.set_fullscreen(value)


func _on_reset_controls_button_pressed() -> void:
	InputManager.reset_to_auto()


func _on_language_option_item_selected(index: int) -> void:
	SettingsManager.set_language("fr" if index == 0 else "en")


func _on_close_settings_button_pressed() -> void:
	show_main()
	refresh()
