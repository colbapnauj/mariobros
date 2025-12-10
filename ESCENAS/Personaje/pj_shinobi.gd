extends CharacterBody2D

@onready var anin = $AnimatedSprite2D
const SPEED = 200
const JUMP_VELOCITY = -350 
const GRAVITY = 10


func _physics_process(delta):
	
	# Aplicar gravedad
	if !is_on_floor():
		velocity.y += GRAVITY
	
	# Obtener dirección de movimiento horizontal
	var input_dir = Input.get_axis("ui_left","ui_right")
	velocity.x = input_dir*SPEED
	
	# Manejar animaciones
	_handle_animations(input_dir)
	move_and_slide()
	
func _handle_animations(input_dir):
	# Si está en el aire
	if !is_on_floor():
		if velocity.y < 0:
			anin.play("Jump") # Animación de salto
		else:
			anin.play("Hurt") # Animación de caída
		return
		
	# Si está en el suelo
	if input_dir != 0:
		# Personaje se mueve
		anin.play("Run")
		# Voltear sprite según dirección
		if input_dir > 0:
			anin.flip_h = false # Mirando a la derecha
		elif input_dir < 0:
			anin.flip_h = true # Mirando a la izquierda
	else:
		# Personaje quieto
		anin.play("Idle")
