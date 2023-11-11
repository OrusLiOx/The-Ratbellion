extends KinematicBody2D

export var speed = 500
export var jumpPower =-1000
export var gravity = 50

var velocity = Vector2.ZERO
var walking = false
var climbing = false
var grounded = false
var canClimb = false

var anim : AnimatedSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.make_current()
	anim = $AnimatedSprite
	anim.playing = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# figure out movement
	determineWalk()
	determineClimb()
	determineFall()
	determineJump()
	# perform movement
	velocity = move_and_slide(velocity)
	velocity.x = lerp(velocity.x,0,.5)
	if climbing:
		velocity.y = lerp(0,velocity.y,.5)
	
	# set proper animation
	if !grounded:
		anim.animation = "Walk"
	elif walking:
		anim.animation = "Walk"
	else:
		anim.animation = "Stand"
func determineWalk():
	if Input.is_action_pressed("Left"): 
		if !Input.is_action_pressed("Right"):
			anim.flip_h = true
			velocity.x = -speed
			walking = true
		else:
			walking = false
	elif Input.is_action_pressed("Right"): 
		anim.flip_h = false
		velocity.x = speed
		walking = true
	else:
		walking = false

func determineClimb():
	if canClimb:
		if Input.is_action_pressed("Up"): 
			if !Input.is_action_pressed("Down"):
				velocity.y = -speed
				climbing = true
		elif Input.is_action_pressed("Down"): 
			velocity.y = speed
			climbing = true

func determineJump():
	if Input.is_action_pressed("Jump") and (climbing or grounded):
		velocity.y = jumpPower
	elif Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0
		
func determineFall():
	if !climbing:
		velocity.y = velocity.y + gravity
		
func _on_Feet_area_entered(area):
	if(area.is_in_group("Terrain")):
		grounded = true
	elif(area.is_in_group("Climbable")):
		canClimb = true
		
func _on_Feet_area_exited(area):
	if(area.is_in_group("Terrain")):
		grounded = false
	elif(area.is_in_group("Climbable")):
		canClimb = false
		climbing = false
