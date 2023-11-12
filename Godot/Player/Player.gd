extends KinematicBody2D

export var speed = 500
export var jumpPower =-1000
export var gravity = 50

var velocity = Vector2.ZERO
var walking = false
var climbing = false
var climbAnim = true
var grounded = false
var numGroundsTouched = 0
var canClimb = false

var staticAnim : AnimatedSprite
var furAnim : AnimatedSprite
var wings : AnimatedSprite
var bodyCol: CollisionShape2D
var feetCol: CollisionShape2D
var rand: RandomNumberGenerator

# cheat codes
var rainbowRat = false
var changeOnJump = false
var infiniteJump = true
var testAnims = false
var invincible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.make_current()
	
	staticAnim = $StaticSprite
	furAnim = $FurSprite
	wings = $Wings
	spritePlaying(true)
	
	bodyCol = $CollisionShape2D
	feetCol = $PlayerFeet/CollisionShape2D
	
	rand = RandomNumberGenerator.new()
	rand.randomize()
	pickColor()

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
	
	animate()

# determine movement functions
func determineWalk():
	if Input.is_action_pressed("Left"): 
		if !Input.is_action_pressed("Right"):
			flip(true)
			velocity.x = -speed
			walking = true
		else:
			walking = false
	elif Input.is_action_pressed("Right"): 
		flip(false)
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
				climbAnim = true
			else:
				climbAnim = false
		elif Input.is_action_pressed("Down"): 
			velocity.y = speed
			climbing = true
			climbAnim = true
		else:
			climbAnim = false
func determineJump():
	if Input.is_action_pressed("Jump") and (climbing or grounded or infiniteJump):
		velocity.y = jumpPower
		climbing = false
		if changeOnJump:
			pickColor()
	elif Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0
func determineFall():
	if !climbing:
		velocity.y = velocity.y + gravity
		
# animation things
func animate():
	# set proper animation
	if climbing:
		if(climbAnim):
			setAnimation("Climb")
		else:
			setAnimation("ClimbStationary")
	elif !grounded:
		setAnimation("Jump")
	elif walking:
		setAnimation("Run")
	else:
		setAnimation("Idle")
func setAnimation(var anim):
	if infiniteJump:
		if anim == "Run" or anim == "Jump":
			wings.animation = "One"
		else:
			wings.animation = "Two"
	if testAnims:
		if anim == "Idle":
			furAnim.animation = "TestIdle"
		else:
			furAnim.animation = "TestRun"
	else:
		staticAnim.animation = anim
		furAnim.animation = anim
func spritePlaying(var playing):
	staticAnim.playing = playing
	furAnim.playing = playing

# misc
func flip(var flipped):
	staticAnim.flip_h = flipped
	furAnim.flip_h = flipped
	wings.flip_h = flipped
func pickColor():
	var color = Color.white
	if rainbowRat:
		color = Color(rand.randf(),rand.randf(),rand.randf(),1)
	elif !testAnims:
		var val
		match(rand.randi_range(0,2)):
			0: # gray
				val = float(rand.randi_range(64,255))/255.0
				color = (Color(val,val,val,1))
			1: # brown
				val = float(rand.randi_range(0,38))/255.0
				color = Color(	79.0/255.0+val*24.0/38.0,
								61.0/255.0+val*31.0/38.0,
								38.0/255.0+val,
								1)
			2: # blue
				val = float(rand.randi_range(0,39))/255.0
				color = Color(	51.0/255.0+val,
								58.0/255.0+val*34.0/39.0,
								83.0/255.0+val*20.0/39.0,
								1)
			
	# brown
	
	furAnim.modulate = color
	wings.modulate = color

# cheat codes
func cheatCode(var code, var active):
	match code:
		"RainbowRat" : 
			rainbowRat = active
		"Pigeon" :
			infiniteJump = active
			wings.visible = active
		"RainbowJump":
			changeOnJump = active
		"LabRat":
			testAnims = active
			staticAnim.visible = !active
		"Catnip":
			invincible = active
				
# collision triggers
func _on_Feet_area_entered(area):
	if(area.is_in_group("Terrain")):
		numGroundsTouched += 1
		grounded = numGroundsTouched > 0
	elif(area.is_in_group("Climbable")):
		canClimb = true
func _on_Feet_area_exited(area):
	if(area.is_in_group("Terrain")):
		numGroundsTouched -= 1
		grounded = numGroundsTouched > 0
	elif(area.is_in_group("Climbable")):
		canClimb = false
		climbing = false
