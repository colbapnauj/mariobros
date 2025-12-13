const WebSocket = require('ws');

const PORT = 8080;
const wss = new WebSocket.Server({ port: PORT });

let players = {};
let playerCount = 0;
const MAX_PLAYERS = 2;

console.log(`Servidor WebSocket iniciado en puerto ${PORT}`);

wss.on('connection', (ws) => {
    console.log('Nuevo cliente conectado');
    
    // Asignar ID al jugador
    const playerId = `player_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    playerCount++;
    
    if (playerCount > MAX_PLAYERS) {
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Sala llena. Máximo 2 jugadores.'
        }));
        ws.close();
        return;
    }
    
    players[playerId] = {
        id: playerId,
        ws: ws,
        position: { x: 0, y: 0 },
        velocity: { x: 0, y: 0 },
        input: { left: false, right: false, jump: false }
    };
    
    // Enviar confirmación de conexión al cliente
    ws.send(JSON.stringify({
        type: 'connected',
        playerId: playerId,
        playerCount: playerCount
    }));
    
    // Notificar a otros jugadores sobre el nuevo jugador
    broadcast(JSON.stringify({
        type: 'player_joined',
        playerId: playerId,
        playerCount: playerCount
    }), ws);
    
    // Manejar mensajes del cliente
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            handleMessage(playerId, data);
        } catch (error) {
            console.error('Error al parsear mensaje:', error);
        }
    });
    
    // Manejar desconexión
    ws.on('close', () => {
        console.log(`Jugador ${playerId} desconectado`);
        delete players[playerId];
        playerCount--;
        
        // Notificar a otros jugadores
        broadcast(JSON.stringify({
            type: 'player_left',
            playerId: playerId,
            playerCount: playerCount
        }), ws);
    });
    
    ws.on('error', (error) => {
        console.error(`Error en conexión ${playerId}:`, error);
    });
});

function handleMessage(playerId, data) {
    if (!players[playerId]) return;
    
    switch (data.type) {
        case 'update_position':
            players[playerId].position = data.position;
            players[playerId].velocity = data.velocity;
            // Broadcast a todos los demás jugadores
            broadcast(JSON.stringify({
                type: 'player_update',
                playerId: playerId,
                position: data.position,
                velocity: data.velocity
            }), players[playerId].ws);
            break;
            
        case 'update_input':
            players[playerId].input = data.input;
            // Broadcast a todos los demás jugadores
            broadcast(JSON.stringify({
                type: 'player_input',
                playerId: playerId,
                input: data.input
            }), players[playerId].ws);
            break;
            
        case 'player_ready':
            broadcast(JSON.stringify({
                type: 'player_ready',
                playerId: playerId
            }), players[playerId].ws);
            break;
            
        default:
            console.log('Tipo de mensaje desconocido:', data.type);
    }
}

function broadcast(message, excludeWs = null) {
    wss.clients.forEach((client) => {
        if (client !== excludeWs && client.readyState === WebSocket.OPEN) {
            client.send(message);
        }
    });
}

// Enviar actualizaciones periódicas de estado
setInterval(() => {
    const state = {
        type: 'game_state',
        players: Object.values(players).map(p => ({
            id: p.id,
            position: p.position,
            velocity: p.velocity
        }))
    };
    
    broadcast(JSON.stringify(state));
}, 100); // Cada 100ms

