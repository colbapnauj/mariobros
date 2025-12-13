# Configuración del Servidor WebSocket

Este documento explica cómo cambiar la URL del servidor WebSocket para el modo multiplayer online.

## URL por Defecto

Por defecto, el juego está configurado para usar el servidor local:
- **URL por defecto:** `ws://localhost:8080`

Para usar ngrok u otro servidor remoto, consulta las secciones siguientes.

## Ubicación de la Configuración

La configuración se guarda automáticamente en un archivo persistente (equivalente a SharedPreferences):
- **Ubicación del archivo:** `user://server_config.cfg`
- **Ruta real:** Depende del sistema operativo:
  - **Windows:** `%APPDATA%/Godot/app_userdata/mario/server_config.cfg`
  - **macOS:** `~/Library/Application Support/Godot/app_userdata/mario/server_config.cfg`
  - **Linux:** `~/.local/share/godot/app_userdata/mario/server_config.cfg`

## Método 1: Desde el Código (Recomendado)

Puedes cambiar la URL del servidor llamando a la función pública desde cualquier script:

```gdscript
# Ejemplo: Cambiar la URL desde un script
ServerConfig.cambiar_url_servidor("wss://tu-nueva-url.ngrok-free.app")
```

### Ejemplo Completo

Crea un script temporal o agrega esto a cualquier script existente:

```gdscript
extends Node

func _ready():
	# Cambiar la URL del servidor
	ServerConfig.cambiar_url_servidor("wss://nueva-url.ngrok-free.app")
	# O con https (se convierte automáticamente a wss)
	ServerConfig.cambiar_url_servidor("https://nueva-url.ngrok-free.app")
```

## Método 2: Editar el Archivo de Configuración Directamente

1. **Encuentra el archivo de configuración:**
   - Ejecuta el juego al menos una vez para que se cree el archivo
   - Navega a la ruta según tu sistema operativo (ver arriba)

2. **Edita el archivo `server_config.cfg`:**
   ```
   [server]
   url="wss://tu-nueva-url.ngrok-free.app"
   ```

3. **Reinicia el juego** para que los cambios surtan efecto

## Método 3: Modificar el Valor por Defecto

Si quieres cambiar la URL por defecto permanentemente:

1. Abre el archivo: `res://server_config.gd`
2. Modifica la línea:
   ```gdscript
   var server_url: String = "wss://tu-nueva-url.ngrok-free.app"
   ```
3. Guarda el archivo

## Conversión Automática de URLs

El sistema convierte automáticamente:
- `https://` → `wss://` (WebSocket seguro)
- `http://` → `ws://` (WebSocket normal)
- Si no tiene protocolo, asume `wss://` para ngrok

**Ejemplos válidos:**
- `https://27877620085c.ngrok-free.app` → Se convierte a `wss://27877620085c.ngrok-free.app`
- `wss://27877620085c.ngrok-free.app` → Se usa tal cual
- `27877620085c.ngrok-free.app` → Se convierte a `wss://27877620085c.ngrok-free.app`

## Actualizar URL de ngrok

Cuando tu URL de ngrok cambia (cada vez que reinicias ngrok):

### Opción A: Desde el código
```gdscript
# En cualquier script, por ejemplo en game_manager.gd
func _ready():
	# Actualizar con tu nueva URL de ngrok
	ServerConfig.cambiar_url_servidor("https://nueva-url-ngrok.ngrok-free.app")
```

### Opción B: Editar el archivo
1. Abre `user://server_config.cfg`
2. Cambia la URL
3. Reinicia el juego

## Verificar la Configuración Actual

Para ver qué URL está configurada actualmente, puedes imprimirla:

```gdscript
print("URL del servidor actual: ", ServerConfig.server_url)
```

## Notas Importantes

- **La configuración se guarda automáticamente** cuando usas `cambiar_url_servidor()`
- **No necesitas reiniciar el juego** si cambias la URL antes de conectarte
- **Si ya estás conectado**, necesitarás desconectarte y reconectarte para usar la nueva URL
- **El archivo de configuración se crea automáticamente** la primera vez que ejecutas el juego

## Solución de Problemas

### El archivo no existe
- Ejecuta el juego al menos una vez
- El archivo se creará automáticamente con la URL por defecto

### Los cambios no se aplican
- Asegúrate de haber guardado el archivo correctamente
- Reinicia el juego
- Verifica que la URL tenga el formato correcto (wss:// o ws://)

### Error de conexión
- Verifica que la URL sea correcta
- Asegúrate de que el servidor esté ejecutándose
- Para ngrok, verifica que el túnel esté activo: `ngrok http 8080`

