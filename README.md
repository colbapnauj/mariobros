# Mario Game - Sistema de Game Over, Respawn y Multiplayer

Este documento describe el flujo completo del sistema de game over, respawn y multiplayer implementado en el juego.

## 📋 Descripción General

El sistema permite que cuando el jugador muere (por caída o contacto con enemigo), se muestre una pantalla de game over que bloquea el movimiento del personaje hasta que el jugador presione el botón "Reintentar".

## 🎮 Flujo del Sistema

### 1. Eventos que Disparan el Respawn

El respawn se activa en dos situaciones:

- **Caída fuera de la pantalla**: Cuando el jugador cae más allá del límite inferior de la pantalla
- **Contacto con enemigo**: Cuando el jugador entra en contacto con un enemigo

### 2. Proceso de Respawn

```
┌─────────────────┐
│  Jugador Muere  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ ejecutar_respawn()      │
│ - Reposiciona jugador   │
│ - Resetea velocidad     │
│ - Emite señal           │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ Señal: respawn_ocurrido  │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ principal.gd recibe      │
│ la señal                 │
└────────┬────────────────┘
         │
         ├─────────────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐  ┌──────────────────┐
│ Mostrar UI      │  │ Bloquear         │
│ Game Over       │  │ Movimiento       │
└─────────────────┘  └──────────────────┘
```

### 3. Bloqueo de Movimiento

Cuando el movimiento está bloqueado:
- El jugador no puede moverse horizontalmente
- El jugador no puede saltar
- Solo se aplica gravedad mínima para mantener al personaje en el suelo
- La animación se mantiene en estado "idle"

### 4. Reintentar

```
┌──────────────────────┐
│ Usuario presiona     │
│ "Reintentar"         │
└──────────┬───────────┘
           │
           ▼
┌─────────────────────────┐
│ Señal: reintentar_      │
│ presionado              │
└──────────┬──────────────┘
           │
           ├─────────────────┐
           │                 │
           ▼                 ▼
┌─────────────────┐  ┌──────────────────┐
│ Ocultar UI      │  │ Desbloquear      │
│ Game Over       │  │ Movimiento       │
└─────────────────┘  └──────────────────┘
```

## 📁 Archivos del Sistema

### Scripts Principales

#### `player.gd`
- **Responsabilidades**:
  - Maneja el movimiento del jugador
  - Detecta cuando el jugador cae fuera de la pantalla
  - Ejecuta el respawn y emite la señal `respawn_ocurrido`
  - Controla el bloqueo/desbloqueo del movimiento

- **Señales**:
  - `respawn_ocurrido`: Se emite cuando el jugador hace respawn

- **Funciones principales**:
  - `ejecutar_respawn()`: Ejecuta el respawn y emite la señal
  - `bloquear_movimiento()`: Bloquea el movimiento del jugador
  - `desbloquear_movimiento()`: Desbloquea el movimiento del jugador

#### `principal.gd`
- **Responsabilidades**:
  - Conecta las señales entre el jugador y la UI
  - Coordina el flujo de game over y reintentar

- **Conexiones de señales**:
  - `player.respawn_ocurrido` → `_on_player_respawn()`
  - `game_over_ui.reintentar_presionado` → `_on_reintentar_presionado()`

#### `geme_over_ui.gd`
- **Responsabilidades**:
  - Controla la visibilidad de la UI de game over
  - Maneja el botón de reintentar

- **Señales**:
  - `reintentar_presionado`: Se emite cuando se presiona el botón de reintentar

- **Funciones principales**:
  - `mostrar()`: Muestra la UI de game over
  - `ocultar()`: Oculta la UI de game over

#### `enemy.gd`
- **Modificaciones**:
  - Ahora usa `body.ejecutar_respawn()` en lugar de hacer el respawn directamente
  - Esto asegura que se emita la señal correctamente

### Escenas

#### `principal.tscn`
- Contiene la escena principal del juego
- Instancia el jugador, enemigos y la UI de game over
- Tiene asignado el script `principal.gd`

#### `geme_over_ui.tscn`
- Contiene la UI de game over
- Incluye el panel, labels y el botón "Reintentar"
- Tiene asignado el script `geme_over_ui.gd`

## 🔧 Configuración

### Requisitos

1. El jugador debe tener el grupo `"Player"` asignado (ya está configurado en `player.tscn`)
2. El nodo `RespawnPoint` debe existir en la escena principal
3. La UI de game over debe estar instanciada en la escena principal como `CanvasLayer`

### Estructura de Nodos

```
Principal (Node2D)
├── RespawnPoint (Node2D)
├── Player (CharacterBody2D) [grupo: "Player"]
├── Enemy (CharacterBody2D)
└── CanvasLayer (geme_over_ui.tscn)
    └── GameOverPanelContainer
        └── VBoxContainer
            ├── PanelContainer
            ├── GameOverLabel
            ├── Spacer
            └── HBoxContainer
                └── RetryButton
```

## 🎯 Uso

El sistema funciona automáticamente una vez configurado. No se requiere código adicional para usar el sistema básico.

### Personalización

Si deseas personalizar el comportamiento:

1. **Cambiar el texto del botón**: Edita `geme_over_ui.tscn` y modifica el texto del `RetryButton`
2. **Cambiar la posición del respawn**: Modifica la posición del nodo `RespawnPoint` en `principal.tscn`
3. **Agregar efectos adicionales**: Conecta señales adicionales en `principal.gd` para agregar sonidos, animaciones, etc.

## 🔄 Diagrama de Flujo Completo

```
INICIO DEL JUEGO
       │
       ▼
┌──────────────────┐
│ Jugador Juega    │
└────────┬─────────┘
         │
         ├─── Caída ───┐
         │             │
         └─── Enemigo ─┘
                 │
                 ▼
         ┌──────────────────┐
         │ ejecutar_respawn()│
         └────────┬──────────┘
                  │
                  ▼
         ┌──────────────────┐
         │ respawn_ocurrido  │
         └────────┬──────────┘
                  │
                  ▼
    ┌──────────────────────────┐
    │ principal.gd recibe      │
    │ señal                     │
    └────────┬──────────────────┘
             │
             ├─────────────────────┐
             │                     │
             ▼                     ▼
    ┌──────────────┐    ┌──────────────────┐
    │ Mostrar UI   │    │ Bloquear          │
    │ Game Over    │    │ Movimiento        │
    └──────────────┘    └──────────────────┘
             │
             │ [Jugador presiona "Reintentar"]
             │
             ▼
    ┌──────────────────┐
    │ reintentar_      │
    │ presionado       │
    └────────┬─────────┘
             │
             ├─────────────────────┐
             │                     │
             ▼                     ▼
    ┌──────────────┐    ┌──────────────────┐
    │ Ocultar UI   │    │ Desbloquear       │
    │ Game Over    │    │ Movimiento        │
    └──────────────┘    └──────────────────┘
             │
             ▼
    ┌──────────────────┐
    │ Jugador puede    │
    │ jugar de nuevo   │
    └──────────────────┘
```

## 🎮 Sistema Multiplayer

El juego ahora soporta tres modos de juego:

### 1. Un Jugador
- Solo el jugador principal está activo
- Controles: Flechas izquierda/derecha y Espacio/Enter para saltar

### 2. Dos Jugadores Locales
- Ambos jugadores juegan en la misma máquina
- Player 1: Flechas izquierda/derecha y Espacio/Enter
- Player 2: A/D para moverse y W para saltar

### 3. Online (2 Jugadores)
- Dos jugadores se conectan a través de un servidor WebSocket
- Requiere que el servidor esté ejecutándose (ver `server/README.md`)
- El primer jugador que se conecta es el host
- El segundo jugador se conecta como cliente remoto

### Servidor WebSocket

Para jugar en modo online, necesitas iniciar el servidor:

```bash
cd server
npm install
npm start
```

El servidor se ejecutará en `ws://localhost:8080` por defecto.

## 📝 Notas Técnicas

- El sistema usa señales de Godot para comunicación entre nodos
- El bloqueo de movimiento se implementa mediante una variable booleana `movimiento_bloqueado`
- La UI se oculta por defecto al inicio del juego
- El respawn siempre reposiciona al jugador en el `RespawnPoint` y resetea su velocidad
- El sistema multiplayer usa WebSockets para sincronización en tiempo real
- El jugador remoto se actualiza mediante interpolación suave para una mejor experiencia

## 🐛 Solución de Problemas

### La UI no se muestra
- Verifica que el script `geme_over_ui.gd` esté asignado a la escena
- Verifica que la ruta del nodo `GameOverPanelContainer` sea correcta

### El movimiento no se bloquea
- Verifica que la señal `respawn_ocurrido` esté conectada correctamente
- Verifica que `principal.gd` esté asignado a la escena principal

### El botón no funciona
- Verifica que el botón tenga el nombre correcto: `RetryButton`
- Verifica que la ruta del botón en `geme_over_ui.gd` sea correcta

