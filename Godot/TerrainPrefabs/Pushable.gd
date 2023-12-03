extends KinematicBody2D

var speed = 250
var onRight = false
var onLeft = false
var velocity = Vector2.ZERO

func _ready():
	$PushLeft/CollisionShape2D.scale.y -= .1/self.scale.y
	$PushLeft/CollisionShape2D.scale.x /= self.scale.x
	$PushRight/CollisionShape2D.scale.y -= .1/self.scale.y
	$PushRight/CollisionShape2D.scale.x /= self.scale.x


func _physics_process(_delta):
	if !Globals.paused :
		velocity.y = velocity.y + 50
		if onRight and Input.is_action_pressed("Left"):
			Globals.pushing = true
			velocity.x = -speed
		elif onLeft and Input.is_action_pressed("Right"):
			Globals.pushing = true
			velocity.x = speed
		else:
			Globals.pushing = false
		velocity = move_and_slide(velocity)
		velocity.x = 0


func _on_PushRight_area_entered(area):
	if area.name == "PlayerFeet":
		onRight = true

func _on_PushLeft_area_entered(area):
	if area.name == "PlayerFeet":
		onLeft = true

func _on_PushRight_area_exited(area):
	if area.name == "PlayerFeet":
		onRight = false

func _on_PushLeft_area_exited(area):
	if area.name == "PlayerFeet":
		onLeft = false
