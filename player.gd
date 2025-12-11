extends CharacterBody2D

signal respawn_ocurrido

@export var velocidad: float = 150.0
@export var fuerza_salto: float = 350.0
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D

@onready var respawn_point = get_parent().get_node("RespawnPoint").global_position

var movimiento_bloqueado: bool = false


func _physics_process(delta):
	# Si el movimiento está bloqueado, solo aplicar gravedad mínima y no procesar input
	if movimiento_bloqueado:
		# Aplicar gravedad mínima para mantener al personaje en el suelo
		if not is_on_floor():
			velocity.y += gravedad * delta
		else:
			velocity.y = 0
		
		velocity.x = 0
		update_animation(0)
		move_and_slide()
		return
	
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
		ejecutar_respawn()


	# Animación + flip
	update_animation(input_dir)

	# Aplicar física
	move_and_slide()

func ejecutar_respawn():
	"""Ejecuta el respawn y emite la señal"""
	global_position = respawn_point
	velocity = Vector2.ZERO
	respawn_ocurrido.emit()

func bloquear_movimiento():
	"""Bloquea el movimiento del jugador"""
	movimiento_bloqueado = true
	velocity = Vector2.ZERO

func desbloquear_movimiento():
	"""Desbloquea el movimiento del jugador"""
	movimiento_bloqueado = false


func update_animation(input_dir: float):
	if input_dir != 0:
		anim.flip_h = input_dir < 0

	if not is_on_floor():
		anim.play("jump")
	elif input_dir == 0:
		anim.play("idle")
	else:
		anim.play("run")
