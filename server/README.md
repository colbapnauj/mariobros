# Servidor Multiplayer para Mario

Este servidor permite que dos jugadores se conecten y jueguen juntos en tiempo real usando WebSockets.

## Instalación

1. Asegúrate de tener Node.js instalado (versión 14 o superior)

2. Instala las dependencias:
```bash
npm install
```

## Uso

Para iniciar el servidor:
```bash
npm start
```

El servidor se ejecutará en el puerto 8080 por defecto.

## Configuración

Puedes cambiar el puerto editando la variable `PORT` en `server.js`.

## Protocolo de Comunicación

### Mensajes del Cliente al Servidor

- `update_position`: Actualiza la posición y velocidad del jugador
- `update_input`: Actualiza el input del jugador
- `player_ready`: Indica que el jugador está listo

### Mensajes del Servidor al Cliente

- `connected`: Confirmación de conexión con el ID del jugador
- `player_joined`: Notificación de que un nuevo jugador se unió
- `player_left`: Notificación de que un jugador se desconectó
- `player_update`: Actualización de posición/velocidad de otro jugador
- `player_input`: Actualización de input de otro jugador
- `game_state`: Estado completo del juego (enviado periódicamente)

## Límites

- Máximo 2 jugadores por sesión
- Si se intenta conectar un tercer jugador, se rechazará la conexión

