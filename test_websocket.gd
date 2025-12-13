extends Node

# Script de prueba para verificar la conexión WebSocket
# Ejecuta este script desde el editor para probar la conexión

var ws_client: WebSocketPeer = null
var server_url: String = "ws://localhost:8080"

func _ready():
	print("=== TEST WEBSOCKET ===")
	print("Conectando a: ", server_url)
	ws_client = WebSocketPeer.new()
	var error = ws_client.connect_to_url(server_url)
	if error != OK:
		print("ERROR: No se pudo conectar. Asegúrate de que el servidor esté ejecutándose.")
		print("Ejecuta: cd server && npm start")
		return
	print("Conectando...")

func _process(_delta):
	if ws_client == null:
		return
	
	ws_client.poll()
	
	var state = ws_client.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		print("✓ CONECTADO al servidor!")
		
		# Recibir mensajes
		while ws_client.get_available_packet_count() > 0:
			var packet = ws_client.get_packet()
			var message = packet.get_string_from_utf8()
			print("Mensaje recibido: ", message)
			
			# Parsear y mostrar información
			var json = JSON.new()
			if json.parse(message) == OK:
				var data = json.data
				if data.has("type"):
					match data["type"]:
						"connected":
							print("  → Tipo: CONECTADO")
							if data.has("playerId"):
								print("  → Player ID: ", data["playerId"])
							if data.has("playerCount"):
								print("  → Jugadores conectados: ", data["playerCount"])
						"player_joined":
							print("  → Tipo: JUGADOR UNIDO")
							if data.has("playerId"):
								print("  → Player ID: ", data["playerId"])
						"player_left":
							print("  → Tipo: JUGADOR SALIÓ")
						"player_update":
							print("  → Tipo: ACTUALIZACIÓN DE JUGADOR")
						"error":
							print("  → Tipo: ERROR")
							if data.has("message"):
								print("  → Mensaje: ", data["message"])
	
	elif state == WebSocketPeer.STATE_CLOSED:
		print("✗ DESCONECTADO del servidor")
		set_process(false)
	elif state == WebSocketPeer.STATE_CONNECTING:
		print("Conectando...")
