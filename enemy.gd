extends CharacterBody2D

@export var PigRun: float = 90
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity.x = -PigRun
	$AnimatedSprite2D.play("run")

func _physics_process(delta):
	velocity.y += gravedad * delta

	# Si toca una pared, cambia la dirección
	if is_on_wall():
		velocity.x = -velocity.x

	# Actualizar flip según dirección
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true   # mirando a la izquierda
	else:
		$AnimatedSprite2D.flip_h = false  # mirando a la derecha

	move_and_slide()



func _on_Hitbox_body_entered(body):
	if body.is_in_group("Player"):  
		# Usar la función ejecutar_respawn del player para que emita la señal
		body.ejecutar_respawn()
