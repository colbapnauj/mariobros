extends Camera2D

# Límites de la cámara
@export var limite_izquierdo: float = -10000
@export var limite_derecho: float = 10000
@export var limite_superior: float = -500
@export var limite_inferior: float = 250

var personaje: CharacterBody2D

func _ready():
	personaje = get_parent() as CharacterBody2D
	_aplicar_limites()
	make_current()
	
	global_position = personaje.global_position
	
func _aplicar_limites():
	limit_left = limite_izquierdo
	limit_right = limite_derecho
	limit_top = limite_superior
	limit_bottom = limite_inferior
