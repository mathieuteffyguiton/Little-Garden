extends CanvasLayer

@onready var root: Control = $Root

@onready var master_slider: HSlider = $Root/Center/Panel/VBox/Tabs/Audio/AudioGrid/MasterSlider
@onready var master_value: Label = $Root/Center/Panel/VBox/Tabs/Audio/AudioGrid/MasterValue
@onready var music_slider: HSlider = $Root/Center/Panel/VBox/Tabs/Audio/AudioGrid/MusicSlider
@onready var music_value: Label = $Root/Center/Panel/VBox/Tabs/Audio/AudioGrid/MusicValue
@onready var sfx_slider: HSlider = $Root/Center/Panel/VBox/Tabs/Audio/AudioGrid/SfxSlider
@onready var sfx_value: Label = $Root/Center/Panel/VBox/Tabs/Audio/AudioGrid/SfxValue
@onready var fullscreen_check: CheckButton = $Root/Center/Panel/VBox/Tabs/Audio/FullscreenCheck

@onready var controls_grid: GridContainer = $Root/Center/Panel/VBox/Tabs/Touches/ControlsScroll/ControlsGrid
@onready var keyboard_label: Label = $Root/Center/Panel/VBox/Tabs/Touches/KeyboardLabel
@onready var wait_label: Label = $Root/Center/Panel/VBox/Tabs/Touches/WaitLabel

@onready var language_option: OptionButton = $Root/Center/Panel/VBox/Tabs/Langues/LanguageOption


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("settings_overlay")
	root.visible = false

	InputManager.controls_changed.connect(refresh_controls)
	InputManager.waiting_for_key.connect(_on_waiting_for_key)

	language_option.clear()
	language_option.add_item("Français")
	language_option.add_item("English")


func open_menu() -> void:
	root.visible = true
	get_tree().paused = true
	refresh()


func close_menu() -> void:
	root.visible = false
	get_tree().paused = false


func refresh() -> void:
	refresh_audio()
	refresh_controls()


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


func _on_waiting_for_key(action: String) -> void:
	wait_label.text = "Appuie sur une touche pour : %s" % InputManager.action_names_fr.get(action, action)


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


func _on_close_button_pressed() -> void:
	close_menu()
