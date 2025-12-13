extends Node2D

@onready var player = $pj_shinobi
@onready var player2 = get_node_or_null("Player2")
@onready var game_over_ui = $GameOverUI
@onready var timer_ui = $TimerUI
@onready var win_ui = get_node_or_null("WinUI")
@onready var pj_samurai = $pj_samurai

var modo_juego: String = "1_player"  # "1_player", "online"
var websocket_client: Node = null
var juego_terminado: bool = false  # Evitar mostrar win múltiples veces

func _ready():
	# Configurar player 2 según el modo de juego
	if modo_juego == "1_player":
		# Asegurar que player no sea remoto
		if player:
			player.is_remote_player = false
		if player2:
			player2.visible = false
			player2.set_process(false)
			player2.set_physics_process(false)
			player2.is_remote_player = false
	elif modo_juego == "online":
		# En modo online, inicialmente ambos son locales hasta que se conecte
		# Las cámaras se configurarán en _on_websocket_connected()
		if player:
			player.is_remote_player = false
		if player2:
			player2.visible = true
			player2.is_remote_player = false
			player2.set_process(true)
			player2.set_physics_process(true)
		setup_websocket()
	
	# Conectar la señal de respawn del jugador
	if player:
		player.respawn_ocurrido.connect(_on_player_respawn)
	
	# Conectar la señal de respawn del player 2 si existe
	if player2:
		player2.respawn_ocurrido.connect(_on_player2_respawn)
	
	# Conectar la señal de reintentar de la UI
	if game_over_ui:
		game_over_ui.reintentar_presionado.connect(_on_reintentar_presionado)
	
	# Conectar la señal de tiempo agotado del timer
	if timer_ui:
		timer_ui.tiempo_agotado.connect(_on_tiempo_agotado)
	
	# Conectar la señal del samurai (personaje final)
	if pj_samurai:
		pj_samurai.jugador_tocado.connect(_on_samurai_tocado)
	
	# Configurar cámaras iniciales (se ajustarán en modo online cuando se conecte)
	await get_tree().process_frame  # Esperar un frame para que las cámaras estén listas
	configurar_camaras()

func configurar_camaras():
	"""Configura qué cámara está activa según el modo de juego"""
	if modo_juego == "1_player":
		# Solo player tiene cámara activa
		if player:
			var camera = player.get_node_or_null("Camera2D")
			if camera:
				camera.enabled = true
				camera.make_current()
		if player2:
			var camera = player2.get_node_or_null("Camera2D")
			if camera:
				camera.enabled = false
	elif modo_juego == "online":
		# En modo online, las cámaras se configurarán cuando se conecte
		# Por ahora, desactivar ambas hasta que se conecte
		if player:
			var camera = player.get_node_or_null("Camera2D")
			if camera:
				camera.enabled = false
		if player2:
			var camera = player2.get_node_or_null("Camera2D")
			if camera:
				camera.enabled = false

func setup_websocket():
	"""Configura el cliente WebSocket"""
	var ws_script = load("res://websocket_client.gd")
	websocket_client = Node.new()
	websocket_client.set_script(ws_script)
	add_child(websocket_client)
	
	# Conectar señales
	websocket_client.connected.connect(_on_websocket_connected)
	websocket_client.disconnected.connect(_on_websocket_disconnected)
	websocket_client.player_update.connect(_on_remote_player_update)
	
	# Conectar al servidor
	await get_tree().process_frame
	websocket_client.connect_to_server()

func _on_websocket_connected():
	print("Conectado al servidor WebSocket")
	print("Es host: ", websocket_client.is_host)
	
	# Configurar qué jugador controla cada instancia y sus cámaras
	if websocket_client.is_host:
		# Host controla player, player2 es remoto
		if player:
			player.is_remote_player = false
			# Activar cámara del player
			var camera = player.get_node_or_null("Camera2D")
			if camera:
				camera.enabled = true
				camera.make_current()
		if player2:
			player2.is_remote_player = true
			# Desactivar cámara del player2
			var camera = player2.get_node_or_null("Camera2D")
			if camera:
				camera.enabled = false
	else:
		# Cliente controla player2, player es remoto
		if player:
			player.is_remote_player = true
			# Desactivar cámara del player
			var camera = player.get_node_or_null("Camera2D")
			if camera:
				camera.enabled = false
		if player2:
			player2.is_remote_player = false
			# Activar cámara del player2
			var camera = player2.get_node_or_null("Camera2D")
			if camera:
				camera.enabled = true
				camera.make_current()

func _on_websocket_disconnected():
	print("Desconectado del servidor WebSocket")

func _on_remote_player_update(player_id: String, position: Vector2, velocity: Vector2):
	# Ignorar nuestras propias actualizaciones
	if player_id == websocket_client.player_id:
		return
	
	# Actualizar el jugador remoto
	if websocket_client.is_host:
		# Host recibe actualizaciones del player2 remoto
		if player2 and player2.is_remote_player:
			player2.set_remote_data(position, velocity, {})
	else:
		# Cliente recibe actualizaciones del player remoto
		if player and player.is_remote_player:
			player.set_remote_data(position, velocity, {})

func _process(_delta):
	# Enviar actualizaciones al servidor si es modo online
	if modo_juego == "online" and websocket_client and websocket_client.is_connected:
		if websocket_client.is_host:
			# Host envía posición del player
			if player and not player.is_remote_player:
				websocket_client.send_position(player.global_position, player.velocity)
		else:
			# Cliente envía posición del player2
			if player2 and not player2.is_remote_player:
				websocket_client.send_position(player2.global_position, player2.velocity)

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

func _on_player2_respawn():
	"""Se llama cuando el player 2 hace respawn"""
	if player2:
		player2.bloquear_movimiento()
	
	if timer_ui:
		timer_ui.detener_timer()
	
	if game_over_ui:
		game_over_ui.mostrar()

func _on_reintentar_presionado():
	"""Se llama cuando se presiona el botón de reintentar"""
	# Desbloquear el movimiento del jugador
	if player:
		player.desbloquear_movimiento()
	
	if player2:
		player2.desbloquear_movimiento()
	
	# Reiniciar el timer (esto también restaurará la velocidad)
	if timer_ui:
		timer_ui.reiniciar_timer()

func _on_tiempo_agotado():
	"""Se llama cuando el timer llega a 0"""
	# Ejecutar respawn del jugador (muerte por tiempo agotado)
	if player:
		player.ejecutar_respawn()
	if player2:
		player2.ejecutar_respawn()

func _on_samurai_tocado(jugador_nombre: String):
	"""Se llama cuando un jugador toca al samurai (personaje final)"""
	# Evitar mostrar win múltiples veces
	if juego_terminado:
		return
	
	juego_terminado = true
	
	# Detener el timer
	if timer_ui:
		timer_ui.detener_timer()
	
	# Bloquear el movimiento de los jugadores
	if player:
		player.bloquear_movimiento()
	if player2:
		player2.bloquear_movimiento()
	
	# Determinar el mensaje de ganador
	var mensaje_ganador = ""
	if modo_juego == "online":
		# En modo online, mostrar quién ganó
		if websocket_client and websocket_client.is_host:
			# Host controla player (Jugador 1)
			if jugador_nombre == "Jugador 1":
				mensaje_ganador = "¡Has ganado!"
			else:
				mensaje_ganador = "El otro jugador ha ganado"
		else:
			# Cliente controla player2 (Jugador 2)
			if jugador_nombre == "Jugador 2":
				mensaje_ganador = "¡Has ganado!"
			else:
				mensaje_ganador = "El otro jugador ha ganado"
	else:
		# Modo 1 jugador
		mensaje_ganador = "¡Felicidades! Has completado el nivel!"
	
	# Mostrar la UI de win
	mostrar_win(mensaje_ganador)

func mostrar_win(ganador: String = ""):
	"""Muestra la UI de win"""
	if win_ui:
		win_ui.mostrar(ganador)
