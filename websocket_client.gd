extends Node

signal connected
signal disconnected
signal player_joined(player_id)
signal player_left(player_id)
signal player_update(player_id, position, velocity)
signal player_input(player_id, input_data)

var ws_client: WebSocketPeer = null
var server_url: String = "ws://localhost:8080"
var is_connected: bool = false
var player_id: String = ""
var is_host: bool = false

func _ready():
	# Cargar URL desde la configuración
	if ServerConfig:
		server_url = ServerConfig.server_url

func connect_to_server(url: String = ""):
	# Si no se proporciona URL, usar la de la configuración
	if url.is_empty():
		if ServerConfig:
			server_url = ServerConfig.server_url
		else:
			server_url = "ws://localhost:8080"
	else:
		server_url = url
	ws_client = WebSocketPeer.new()
	var error = ws_client.connect_to_url(server_url)
	if error != OK:
		print("Error al conectar al servidor: ", error)
		return false
	print("Conectando a: ", server_url)
	return true

func disconnect_from_server():
	if ws_client:
		ws_client.close()
		is_connected = false
		player_id = ""
		disconnected.emit()

func _process(_delta):
	if ws_client == null:
		return
	
	ws_client.poll()
	
	var state = ws_client.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		# Recibir mensajes
		while ws_client.get_available_packet_count() > 0:
			var packet = ws_client.get_packet()
			handle_message(packet.get_string_from_utf8())
	
	elif state == WebSocketPeer.STATE_CLOSED:
		if is_connected:
			is_connected = false
			disconnected.emit()

func handle_message(message: String):
	var json = JSON.new()
	var error = json.parse(message)
	if error != OK:
		print("Error al parsear mensaje: ", message)
		return
	
	var data = json.data
	
	if not data.has("type"):
		print("Mensaje sin tipo: ", message)
		return
	
	match data["type"]:
		"connected":
			if data.has("playerId"):
				player_id = data["playerId"]
			if data.has("playerCount"):
				is_host = data["playerCount"] == 1
			print("Conectado como: ", player_id, " (Host: ", is_host, ")")
			# Emitir la señal connected DESPUÉS de establecer is_host
			if not is_connected:
				is_connected = true
			connected.emit()
		
		"player_joined":
			if data.has("playerId"):
				player_joined.emit(data["playerId"])
				print("Jugador unido: ", data["playerId"])
		
		"player_left":
			if data.has("playerId"):
				player_left.emit(data["playerId"])
				print("Jugador salió: ", data["playerId"])
		
		"player_update":
			if data.has("playerId") and data.has("position") and data.has("velocity"):
				var pos_dict = data["position"]
				var vel_dict = data["velocity"]
				player_update.emit(data["playerId"], Vector2(pos_dict["x"], pos_dict["y"]), Vector2(vel_dict["x"], vel_dict["y"]))
		
		"player_input":
			if data.has("playerId") and data.has("input"):
				player_input.emit(data["playerId"], data["input"])
		
		"game_state":
			# Actualizar estado del juego
			pass
		
		"error":
			if data.has("message"):
				print("Error del servidor: ", data["message"])

func send_position(position: Vector2, velocity: Vector2):
	if not is_connected or ws_client == null:
		return
	
	var message = {
		"type": "update_position",
		"position": {"x": position.x, "y": position.y},
		"velocity": {"x": velocity.x, "y": velocity.y}
	}
	
	var json_string = JSON.stringify(message)
	ws_client.send_text(json_string)

func send_input(input_data: Dictionary):
	if not is_connected or ws_client == null:
		return
	
	var message = {
		"type": "update_input",
		"input": input_data
	}
	
	var json_string = JSON.stringify(message)
	ws_client.send_text(json_string)

func send_ready():
	if not is_connected or ws_client == null:
		return
	
	var message = {
		"type": "player_ready"
	}
	
	var json_string = JSON.stringify(message)
	ws_client.send_text(json_string)
