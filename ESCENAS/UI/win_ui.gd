extends CanvasLayer

signal volver_menu

@onready var win_panel = $WinPanelContainer
@onready var titulo_label = $WinPanelContainer/VBoxContainer/TituloLabel
@onready var mensaje_label = $WinPanelContainer/VBoxContainer/MensajeLabel
@onready var volver_button = $WinPanelContainer/VBoxContainer/VolverButton

func _ready():
	# Ocultar la UI al inicio
	win_panel.visible = false
	
	# Conectar el botón de volver
	if volver_button:
		volver_button.pressed.connect(_on_volver_button_pressed)

func mostrar(mensaje: String = ""):
	"""Muestra la UI de win"""
	if mensaje != "":
		mensaje_label.text = mensaje
	else:
		mensaje_label.text = "¡Felicidades! Has completado el nivel!"
	
	win_panel.visible = true

func ocultar():
	"""Oculta la UI de win"""
	win_panel.visible = false

func _on_volver_button_pressed():
	"""Se llama cuando se presiona el botón de volver"""
	ocultar()
	volver_menu.emit()

