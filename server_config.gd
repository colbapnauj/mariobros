extends Node

# Singleton para gestionar la configuración del servidor
# Equivalente a SharedPreferences en Android/iOS
const CONFIG_FILE = "user://server_config.cfg"

var server_url: String = "wss://27877620085c.ngrok-free.app"  # URL por defecto - ngrok

func _ready():
	cargar_configuracion()

## Función pública para cambiar la URL del servidor
## Esta función puede ser llamada desde código o desde el editor
## Ejemplo de uso:
##   ServerConfig.cambiar_url_servidor("wss://nueva-url.ngrok-free.app")
##   ServerConfig.cambiar_url_servidor("https://nueva-url.ngrok-free.app")  # Se convierte automáticamente
func cambiar_url_servidor(url: String):
	"""Cambia la URL del servidor y la guarda en la configuración persistente"""
	establecer_url(url)
	print("URL del servidor actualizada. Reinicia el juego o reconecta para aplicar los cambios.")

func guardar_configuracion():
	"""Guarda la configuración del servidor en un archivo"""
	var config = ConfigFile.new()
	config.set_value("server", "url", server_url)
	var error = config.save(CONFIG_FILE)
	if error != OK:
		print("Error al guardar configuración: ", error)
	else:
		print("Configuración guardada: ", server_url)

func cargar_configuracion():
	"""Carga la configuración del servidor desde un archivo"""
	var config = ConfigFile.new()
	var error = config.load(CONFIG_FILE)
	if error == OK:
		if config.has_section_key("server", "url"):
			var url_cargada = config.get_value("server", "url", server_url)
			# Convertir la URL si es necesario (por si se guardó con https)
			server_url = convertir_url_ngrok(url_cargada)
			print("Configuración cargada: ", server_url)
		else:
			# Si no tiene la clave, usar el valor por defecto
			server_url = convertir_url_ngrok(server_url)
			print("Usando URL por defecto: ", server_url)
	else:
		# Si no existe el archivo, usar el valor por defecto (ya convertido)
		server_url = convertir_url_ngrok(server_url)
		print("Usando configuración por defecto: ", server_url)

func convertir_url_ngrok(url: String) -> String:
	"""Convierte una URL de ngrok (https) a WebSocket (wss)"""
	if url.begins_with("https://"):
		return url.replace("https://", "wss://")
	elif url.begins_with("http://"):
		return url.replace("http://", "ws://")
	elif not url.begins_with("ws://") and not url.begins_with("wss://"):
		# Si no tiene protocolo, asumir wss para ngrok
		return "wss://" + url
	return url

func establecer_url(url: String):
	"""Establece la URL del servidor y la guarda"""
	var url_convertida = convertir_url_ngrok(url)
	server_url = url_convertida
	guardar_configuracion()
	print("URL del servidor establecida: ", server_url)
