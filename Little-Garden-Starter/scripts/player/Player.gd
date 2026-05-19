extends CharacterBody2D

@export var speed: float = 95.0
@export var dash_speed: float = 230.0
@export var dash_duration: float = 0.14

var last_direction := Vector2.DOWN
var is_attacking := false
var is_dashing := false
var dash_timer := 0.0

@onready var attack_area: Area2D = $AttackArea

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_actions()

func handle_movement(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		last_direction = input_vector

	if is_dashing:
		dash_timer -= delta
		velocity = last_direction * dash_speed
		if dash_timer <= 0:
			is_dashing = false
	else:
		velocity = input_vector * speed

	move_and_slide()

func handle_actions() -> void:
	if Input.is_action_just_pressed("attack"):
		attack()

	if Input.is_action_just_pressed("dash") and "shadow_dash" in GameManager.unlocked_abilities:
		start_dash()

func attack() -> void:
	if is_attacking:
		return

	is_attacking = true
	attack_area.rotation = last_direction.angle()
	attack_area.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack_area.monitoring = false
	is_attacking = false

func start_dash() -> void:
	if is_dashing:
		return
	is_dashing = true
	dash_timer = dash_duration
