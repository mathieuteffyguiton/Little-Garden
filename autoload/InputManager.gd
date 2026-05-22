extends Node
signal controls_changed
signal waiting_for_key(action_name)

const CONTROLS_PATH := "user://controls.json"
var waiting_action := ""

var action_names_fr := {
	"move_up":"Monter","move_down":"Descendre","move_left":"Gauche","move_right":"Droite",
	"attack":"Attaquer","interact":"Interagir","open_inventory":"Inventaire","open_zone_map":"Carte",
	"dash":"Dash","pause_menu":"Pause"
}

var action_order := ["move_up","move_down","move_left","move_right","attack","interact","open_inventory","open_zone_map","dash","pause_menu"]

var layouts := {
	"azerty":{"move_up":[KEY_Z],"move_down":[KEY_S],"move_left":[KEY_Q],"move_right":[KEY_D],"attack":[KEY_J],"interact":[KEY_E],"open_inventory":[KEY_I],"open_zone_map":[KEY_M],"dash":[KEY_K,KEY_SHIFT],"pause_menu":[KEY_ESCAPE]},
	"qwerty":{"move_up":[KEY_W],"move_down":[KEY_S],"move_left":[KEY_A],"move_right":[KEY_D],"attack":[KEY_J],"interact":[KEY_E],"open_inventory":[KEY_I],"open_zone_map":[KEY_M],"dash":[KEY_K,KEY_SHIFT],"pause_menu":[KEY_ESCAPE]}
}

func _ready() -> void:
	if FileAccess.file_exists(CONTROLS_PATH):
		load_custom_controls()
	else:
		apply_auto_keyboard()

func _input(event: InputEvent) -> void:
	if waiting_action == "":
		return
	if event is InputEventKey and event.pressed and not event.echo:
		rebind_action(waiting_action, event.keycode)
		waiting_action = ""
		get_viewport().set_input_as_handled()

func detect_keyboard_layout() -> String:
	var text := ""
	if DisplayServer.has_method("keyboard_get_layout_language"):
		var current_layout := 0
		if DisplayServer.has_method("keyboard_get_current_layout"):
			current_layout = DisplayServer.keyboard_get_current_layout()
		text = str(DisplayServer.keyboard_get_layout_language(current_layout)).to_lower()
	if text == "" or text == "null":
		text = OS.get_locale_language().to_lower()
	for marker in ["fr","be","azerty"]:
		if text.find(marker) != -1:
			return "azerty"
	return "qwerty"

func apply_auto_keyboard() -> void:
	var layout := detect_keyboard_layout()
	SettingsManager.set_detected_keyboard(layout)
	for action in action_order:
		set_action_keys(action, layouts[layout][action])
	add_attack_mouse()
	controls_changed.emit()

func set_action_keys(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	InputMap.action_erase_events(action)

	for keycode in keys:
		var ev := InputEventKey.new()
		ev.keycode = keycode as Key
		InputMap.action_add_event(action, ev)

func add_attack_mouse() -> void:
	if not InputMap.has_action("attack"):
		InputMap.add_action("attack")
	var has_mouse := false
	for ev in InputMap.action_get_events("attack"):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			has_mouse = true
	if not has_mouse:
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("attack", mouse)

func start_rebind(action: String) -> void:
	waiting_action = action
	waiting_for_key.emit(action)

func rebind_action(action: String, keycode: int) -> void:
	set_action_keys(action, [keycode])
	if action == "attack":
		add_attack_mouse()
	save_custom_controls()
	controls_changed.emit()

func reset_to_auto() -> void:
	if FileAccess.file_exists(CONTROLS_PATH):
		DirAccess.remove_absolute(CONTROLS_PATH)
	apply_auto_keyboard()

func save_custom_controls() -> void:
	var data := {}
	for action in action_order:
		data[action] = []
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				data[action].append(ev.keycode)
	var file := FileAccess.open(CONTROLS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func load_custom_controls() -> void:
	var file := FileAccess.open(CONTROLS_PATH, FileAccess.READ)
	if not file:
		apply_auto_keyboard()
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		apply_auto_keyboard()
		return
	var layout := detect_keyboard_layout()
	for action in action_order:
		var keys: Array = parsed.get(action, layouts[layout][action])
		set_action_keys(action, keys)
	add_attack_mouse()
	controls_changed.emit()

func get_action_label(action: String) -> String:
	if not InputMap.has_action(action):
		return "—"
	var labels: Array[String] = []
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			labels.append(OS.get_keycode_string(ev.keycode))
		elif ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			labels.append("Clic gauche")
	return " / ".join(labels) if not labels.is_empty() else "—"

func get_keyboard_status_text() -> String:
	if FileAccess.file_exists(CONTROLS_PATH):
		return "Personnalisé"
	return "Automatique : %s détecté" % str(SettingsManager.settings.get("detected_keyboard","unknown")).to_upper()
