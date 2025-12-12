extends CharacterBody2D

@export var velocidad: float = 150.0
@export var fuerza_salto: float = 350.0
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var respawn_point = get_parent().get_node("RespawnPoint").global_position

func jump():
	velocity.y = fuerza_salto


func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta

	# Movimiento horizontal
	var input_dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * velocidad

	# Saltar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -fuerza_salto
		
		
	var screen_rect = get_viewport().get_visible_rect()

	if global_position.y > screen_rect.size.y + 50:
		global_position = respawn_point
		velocity = Vector2.ZERO


	# Animación + flip
	update_animation(input_dir)

	# Aplicar física
	move_and_slide()


func update_animation(input_dir):
	if !is_on_floor():
		if velocity.y < 0:
			anim.play("Jump")
		else:
			anim.play("Hurt")
		return

	if input_dir == 0:
		anim.play("Idle")
	else:
		anim.play("Run")
		anim.flip_h = input_dir < 0
