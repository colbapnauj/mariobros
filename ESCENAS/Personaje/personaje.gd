extends CharacterBody2D

@onready var anin = $AnimationPlayer
const SPEED = 200
var movimientoInput = Vector2()

func _process(delta):
	if movimientoInput.length() >0:
		$AnimationPlayer.play("Walk")
	else:
		$AnimationPlayer.play("Idle")

func _physics_process(delta):
	anin.play("Idle")
	
	if !is_on_floor():
		velocity.y += 10
		
	var input_dir = Input.get_axis("ui_left","ui_right")
	velocity.x = input_dir*SPEED
	
	move_and_slide()
