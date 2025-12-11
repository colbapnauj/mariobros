extends CanvasLayer

signal reintentar_presionado

@onready var game_over_panel = $GameOverPanelContainer
@onready var audio_muerte = $AudioMuerte
@onready var audio_game_over = $AudioGameOver

func _ready():
	# Ocultar la UI al inicio
	game_over_panel.visible = false
	
	# Conectar el botón de reintentar
	var retry_button = game_over_panel.get_node("VBoxContainer/HBoxContainer/RetryButton")
	if retry_button:
		retry_button.pressed.connect(_on_retry_button_pressed)
	
	# Conectar la señal de finalización del audio de muerte para reproducir el game over
	if audio_muerte:
		audio_muerte.finished.connect(_on_audio_muerte_finished)

func mostrar():
	"""Muestra la UI de game over y reproduce los audios"""
	# Reproducir el audio de muerte primero
	if audio_muerte:
		audio_muerte.play()
	
	# La UI se mostrará cuando termine el audio de muerte

func ocultar():
	"""Oculta la UI de game over"""
	game_over_panel.visible = false

func _on_audio_muerte_finished():
	"""Se llama cuando termina el audio de muerte"""
	# Reproducir el audio de game over
	if audio_game_over:
		audio_game_over.play()
	
	# Mostrar la UI de game over después del audio de muerte
	game_over_panel.visible = true

func _on_retry_button_pressed():
	"""Se llama cuando se presiona el botón de reintentar"""
	# Detener los audios si están reproduciéndose
	if audio_muerte and audio_muerte.playing:
		audio_muerte.stop()
	if audio_game_over and audio_game_over.playing:
		audio_game_over.stop()
	
	ocultar()
	reintentar_presionado.emit()
