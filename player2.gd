extends CharacterBody2D

signal respawn_ocurrido

@export var velocidad: float = 150.0
@export var fuerza_salto: float = 350.0
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var respawn_point = get_parent().get_node("RespawnPoint").global_position

var movimiento_bloqueado: bool = false
var is_remote_player: bool = false  # Si es true, se controla por WebSocket
var remote_position: Vector2 = Vector2.ZERO
var remote_velocity: Vector2 = Vector2.ZERO
var remote_input: Dictionary = {"left": false, "right": false, "jump": false}

func jump():
	velocity.y = fuerza_salto

func _physics_process(delta):
	# Si es un jugador remoto, usar datos del servidor
	if is_remote_player:
		# Interpolación más rápida para mejor sincronización
		global_position = global_position.lerp(remote_position, 0.5)
		velocity = remote_velocity
		
		# Actualizar animación basada en velocidad remota
		var input_dir = 0.0
		if remote_velocity.x > 0:
			input_dir = 1.0
		elif remote_velocity.x < 0:
			input_dir = -1.0
		update_animation(input_dir)
		move_and_slide()
		return
	
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

	# Movimiento horizontal - usar teclas alternativas para player 2
	var input_dir := Input.get_axis("move_left_p2", "move_right_p2")
	velocity.x = input_dir * velocidad

	# Saltar - tecla alternativa para player 2
	if Input.is_action_just_pressed("jump_p2") and is_on_floor():
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

func set_remote_data(pos: Vector2, vel: Vector2, input_data: Dictionary):
	"""Actualiza la posición y velocidad del jugador remoto"""
	remote_position = pos
	remote_velocity = vel
	remote_input = input_data
