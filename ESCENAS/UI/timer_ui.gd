extends CanvasLayer

signal tiempo_agotado

@export var tiempo_inicial: float = 300.0  # 300 segundos
var tiempo_restante: float = 300.0
var timer_activo: bool = false
var velocidad_aumentada: bool = false

@onready var timer_label = $VBoxContainer/TimerLabel
@onready var titulo_label = $VBoxContainer/TituloLabel
@onready var audio_inicio = $AudioInicio

func _ready():
	tiempo_restante = tiempo_inicial
	actualizar_label()
	# Conectar la señal para que el audio se repita en bucle
	if audio_inicio:
		audio_inicio.finished.connect(_on_audio_finished)
		audio_inicio.play()
	# Iniciar el timer automáticamente
	iniciar_timer()
	# Asegurar que la velocidad inicial sea normal
	Engine.time_scale = 1.0

func _on_audio_finished():
	"""Se llama cuando el audio termina, lo reproduce nuevamente para crear un bucle"""
	if audio_inicio and timer_activo:
		audio_inicio.play()

func _process(delta):
	if timer_activo:
		tiempo_restante -= delta
		
		# Aumentar velocidad cuando queden 60 segundos o menos
		if tiempo_restante <= 60.0 and not velocidad_aumentada:
			Engine.time_scale = 1.25
			velocidad_aumentada = true
		
		if tiempo_restante <= 0:
			tiempo_restante = 0
			timer_activo = false
			tiempo_agotado.emit()
		
		actualizar_label()

func actualizar_label():
	"""Actualiza el label con el tiempo formateado (solo segundos)"""
	var segundos = int(tiempo_restante)
	timer_label.text = str(segundos)

func iniciar_timer():
	"""Inicia el timer"""
	timer_activo = true
	tiempo_restante = tiempo_inicial

func detener_timer():
	"""Detiene el timer"""
	timer_activo = false
	# Detener el audio cuando se detiene el timer
	if audio_inicio and audio_inicio.playing:
		audio_inicio.stop()

func reiniciar_timer():
	"""Reinicia el timer"""
	tiempo_restante = tiempo_inicial
	timer_activo = true
	# Restaurar velocidad normal al reiniciar
	Engine.time_scale = 1.0
	velocidad_aumentada = false
	# Reproducir audio al reiniciar (se repetirá en bucle automáticamente)
	if audio_inicio:
		audio_inicio.play()

