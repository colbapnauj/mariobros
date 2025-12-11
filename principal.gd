extends Node2D

@onready var player = $Player
@onready var game_over_ui = $GameOverUI

func _ready():
	# Conectar la señal de respawn del jugador
	if player:
		player.respawn_ocurrido.connect(_on_player_respawn)
	
	# Conectar la señal de reintentar de la UI
	if game_over_ui:
		game_over_ui.reintentar_presionado.connect(_on_reintentar_presionado)

func _on_player_respawn():
	"""Se llama cuando el jugador hace respawn"""
	# Bloquear el movimiento del jugador
	if player:
		player.bloquear_movimiento()
	
	# Notificar a la UI para que muestre y reproduzca los audios
	if game_over_ui:
		game_over_ui.mostrar()

func _on_reintentar_presionado():
	"""Se llama cuando se presiona el botón de reintentar"""
	# Desbloquear el movimiento del jugador
	if player:
		player.desbloquear_movimiento()
