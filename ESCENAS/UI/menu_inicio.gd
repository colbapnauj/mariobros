extends CanvasLayer

signal jugar_1_player
signal jugar_online

@onready var titulo_sprite = $VBoxContainer/TituloSprite
@onready var boton_1_player = $VBoxContainer/HBoxContainer/Boton1Player
@onready var boton_online = $VBoxContainer/HBoxContainer/BotonOnline

func _ready():
	# Conectar botones
	boton_1_player.pressed.connect(_on_boton_1_player_pressed)
	boton_online.pressed.connect(_on_boton_online_pressed)
	
	# La imagen del título ya está cargada en la escena

func _on_boton_1_player_pressed():
	jugar_1_player.emit()
	ocultar()

func _on_boton_online_pressed():
	jugar_online.emit()
	ocultar()

func mostrar():
	visible = true

func ocultar():
	visible = false

