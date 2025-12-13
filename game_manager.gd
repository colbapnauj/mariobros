extends Node

signal cambiar_escena(escena_path: String)

var modo_juego: String = "1_player"
var nivel_actual: Node = null

func _ready():
	# Cargar menú de inicio
	cargar_menu_inicio()

func cargar_menu_inicio():
	"""Carga el menú de inicio"""
	var menu_scene = load("res://ESCENAS/UI/menu_inicio.tscn")
	if menu_scene:
		var menu = menu_scene.instantiate()
		add_child(menu)
		
		# Conectar señales del menú
		menu.jugar_1_player.connect(_on_jugar_1_player)
		menu.jugar_online.connect(_on_jugar_online)

func _on_jugar_1_player():
	"""Inicia el juego con 1 jugador"""
	modo_juego = "1_player"
	cargar_nivel()

func _on_jugar_online():
	"""Inicia el juego en modo online"""
	modo_juego = "online"
	cargar_nivel()

func cargar_nivel():
	"""Carga el nivel con el modo de juego configurado"""
	# Limpiar menú si existe
	for child in get_children():
		if "MenuInicio" in child.name or child.name == "MenuInicio":
			child.queue_free()
	
	# Cargar nivel
	var nivel_scene = load("res://ESCENAS/Nivel_1/nivel_1.tscn")
	if nivel_scene:
		nivel_actual = nivel_scene.instantiate()
		nivel_actual.modo_juego = modo_juego
		add_child(nivel_actual)
		
		# Si hay win_ui, conectar su señal
		var win_ui = nivel_actual.get_node_or_null("WinUI")
		if win_ui:
			win_ui.volver_menu.connect(_on_volver_menu)
		
		# Ocultar player2 si es modo 1 jugador
		if modo_juego == "1_player":
			var player2_node = nivel_actual.get_node_or_null("Player2")
			if player2_node:
				player2_node.visible = false

func _on_volver_menu():
	"""Vuelve al menú principal"""
	if nivel_actual:
		nivel_actual.queue_free()
		nivel_actual = null
	
	cargar_menu_inicio()

