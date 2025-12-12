extends Node2D

@onready var player = $pj_shinobi
@onready var game_over_ui = $GameOverUI
@onready var timer_ui = $TimerUI

func _ready():
	# Conectar la señal de respawn del jugador
	if player:
		player.respawn_ocurrido.connect(_on_player_respawn)
	
	# Conectar la señal de reintentar de la UI
	if game_over_ui:
		game_over_ui.reintentar_presionado.connect(_on_reintentar_presionado)
	
	# Conectar la señal de tiempo agotado del timer
	if timer_ui:
		timer_ui.tiempo_agotado.connect(_on_tiempo_agotado)

func _on_player_respawn():
	"""Se llama cuando el jugador hace respawn"""
	# Bloquear el movimiento del jugador
	if player:
		player.bloquear_movimiento()
	
	# Detener el timer durante el game over
	if timer_ui:
		timer_ui.detener_timer()
	
	# Notificar a la UI para que muestre y reproduzca los audios
	if game_over_ui:
		game_over_ui.mostrar()

func _on_reintentar_presionado():
	"""Se llama cuando se presiona el botón de reintentar"""
	# Desbloquear el movimiento del jugador
	if player:
		player.desbloquear_movimiento()
	
	# Reiniciar el timer (esto también restaurará la velocidad)
	if timer_ui:
		timer_ui.reiniciar_timer()

func _on_tiempo_agotado():
	"""Se llama cuando el timer llega a 0"""
	# Ejecutar respawn del jugador (muerte por tiempo agotado)
	if player:
		player.ejecutar_respawn()

