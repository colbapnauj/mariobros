extends CharacterBody2D

@onready var anin = $AnimatedSprite2D
const GRAVITY = 10

func _physics_process(delta):
	
	# Aplicar gravedad
	if !is_on_floor():
		velocity.y += GRAVITY
	anin.play("Idle")
	anin.flip_h = 1
	move_and_slide()
	
