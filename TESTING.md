# Guía de Pruebas para WebSocket Multiplayer

## Opciones para Probar el Multiplayer

### Opción 1: Exportar y Ejecutar Dos Instancias (Recomendado)

1. **Exporta el juego:**
   - En Godot: `Project → Export`
   - Selecciona una plataforma (Windows, macOS, Linux)
   - Exporta el juego

2. **Inicia el servidor:**
   ```bash
   cd server
   npm install  # Solo la primera vez
   npm start
   ```

3. **Ejecuta dos instancias:**
   - Abre la primera instancia del juego exportado
   - Selecciona "Online (2P)" en el menú
   - Abre la segunda instancia del juego exportado
   - También selecciona "Online (2P)"
   - ¡Deberías ver ambos jugadores moviéndose!

### Opción 2: Editor + Exportado

1. **Inicia el servidor:**
   ```bash
   cd server
   npm start
   ```

2. **Ejecuta desde el editor:**
   - Presiona F5 en Godot
   - Selecciona "Online (2P)"

3. **Ejecuta una instancia exportada:**
   - Abre el juego exportado
   - Selecciona "Online (2P)"
   - Ambos deberían conectarse

### Opción 3: Usar el Script de Prueba

1. **Inicia el servidor:**
   ```bash
   cd server
   npm start
   ```

2. **En Godot:**
   - Abre `test_websocket.tscn` como escena principal temporalmente
   - O cambia `run/main_scene` en `project.godot` a `res://test_websocket.tscn`
   - Ejecuta (F5)
   - Verás en la consola si la conexión funciona

3. **Vuelve a la escena principal:**
   - Cambia `run/main_scene` de vuelta a `res://game_manager.tscn`

### Opción 4: Usar Herramientas Externas

Puedes usar herramientas como:
- **wscat**: `npm install -g wscat` luego `wscat -c ws://localhost:8080`
- **Postman**: Tiene soporte para WebSockets
- **Browser DevTools**: Abre la consola del navegador y usa `new WebSocket("ws://localhost:8080")`

## Verificar que el Servidor Funciona

1. **Inicia el servidor:**
   ```bash
   cd server
   npm start
   ```

2. **Deberías ver:**
   ```
   Servidor WebSocket iniciado en puerto 8080
   ```

3. **Cuando un cliente se conecta, verás:**
   ```
   Nuevo cliente conectado
   ```

## Verificar que el Cliente se Conecta

En la consola de Godot (Output), deberías ver:
```
Conectando a: ws://localhost:8080
Conectado como: player_XXXXX (Host: true/false)
```

## Solución de Problemas

### El servidor no inicia
- Verifica que Node.js esté instalado: `node --version`
- Verifica que el puerto 8080 no esté en uso
- Revisa los errores en la consola del servidor

### El cliente no se conecta
- Verifica que el servidor esté ejecutándose
- Verifica la URL en `websocket_client.gd` (debe ser `ws://localhost:8080`)
- Revisa la consola de Godot para ver errores

### Los jugadores no se ven
- Verifica que ambos clientes estén conectados (revisa la consola del servidor)
- Verifica que `player2` esté visible en el modo online
- Revisa los logs en la consola de Godot

## Notas Importantes

- **No puedes probar con dos pestañas del navegador** porque este es un juego de Godot, no una aplicación web
- **Necesitas dos instancias del juego** para probar el multiplayer
- **El servidor debe estar ejecutándose** antes de que los clientes se conecten
- **El primer jugador que se conecta es el host** (is_host = true)
- **El segundo jugador es el cliente remoto** (is_host = false)
