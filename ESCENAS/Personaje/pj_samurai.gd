extends CharacterBody2D

signal jugador_tocado(jugador_nombre: String)

@onready var anin = $AnimatedSprite2D
@onready var area_deteccion = $Area2D
const GRAVITY = 10

func _ready():
	# Conectar la señal del Area2D si existe
	if area_deteccion:
		area_deteccion.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	
	# Aplicar gravedad
	if !is_on_floor():
		velocity.y += GRAVITY
	anin.play("Idle")
	anin.flip_h = 1
	move_and_slide()

func _on_body_entered(body: Node2D):
	"""Se llama cuando un cuerpo entra en el área de detección"""
	# Verificar si es un jugador
	if body.name == "pj_shinobi" or body.name == "Player2":
		var jugador_nombre = "Jugador 1" if body.name == "pj_shinobi" else "Jugador 2"
		jugador_tocado.emit(jugador_nombre)
	
