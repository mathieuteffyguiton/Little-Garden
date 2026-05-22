extends CanvasLayer
@onready var root=$Root
@onready var grid=$Root/Panel/VBox/Scroll/Grid
@onready var info=$Root/Panel/VBox/Info
var zones := [
	{"id":"village","name":"Village"},
	{"id":"zone_01","name":"Zone 1"},{"id":"zone_02","name":"Zone 2"},{"id":"zone_03","name":"Zone 3"},
	{"id":"zone_04","name":"Zone 4"},{"id":"zone_05","name":"Zone 5"},{"id":"zone_06","name":"Zone 6"},
	{"id":"zone_07","name":"Zone 7"},{"id":"zone_08","name":"Zone 8"},{"id":"zone_09","name":"Zone 9"},{"id":"zone_10","name":"Zone 10"}
]
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	add_to_group("zone_map_menu")
	root.visible=false
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_zone_map"):
		if root.visible: close_menu()
		else: open_menu()
func open_menu() -> void:
	if get_tree().paused and not root.visible: return
	root.visible=true; get_tree().paused=true; refresh()
func close_menu() -> void:
	root.visible=false; get_tree().paused=false
func refresh() -> void:
	for c in grid.get_children(): c.queue_free()
	var unlocked:Array=GameState.progression.get("unlocked_zones",[])
	for z in zones:
		var id:=str(z["id"])
		var b:=Button.new()
		b.custom_minimum_size=Vector2(170,70)
		if not unlocked.has(id):
			b.text="%s\nVERROUILLÉ" % z["name"]; b.disabled=true
		elif not GameState.has_zone_map(id):
			b.text="%s\nCarte inconnue" % z["name"]
		else:
			b.text="%s\nCarte trouvée" % z["name"]
		if id == GameState.current_zone: b.text += "\n[ACTUELLE]"
		b.pressed.connect(func(): select_zone(z))
		grid.add_child(b)
	info.text="Sélectionne une zone."
func select_zone(z:Dictionary) -> void:
	var id:=str(z["id"])
	info.text = "%s\nCarte %s." % [z["name"], "trouvée" if GameState.has_zone_map(id) else "non trouvée"]
func _on_close_button_pressed() -> void: close_menu()
