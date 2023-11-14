extends KinematicBody2D

export var speed = 500
export var jumpPower =-1000
export var gravity = 50
export var TimeToDie = 5
export var controlLock = false
var velocity = Vector2.ZERO
var fadeObjective
var paused = false

var walking = false
var climbing = false

var grounded = false
var numGroundsTouched = 0

var climbAnim = true
var canClimb = false

var safeZonesTouched = 0
var timer:Timer
var safe = true
var dead = false
var respawnPoint

var staticAnim : AnimatedSprite
var furAnim : AnimatedSprite
var wings : AnimatedSprite
var bodyCol: CollisionShape2D
var feetCol: CollisionShape2D
var rand: RandomNumberGenerator
var vignette : ColorRect
var objective : RichTextLabel

# cheat codes
var rainbowRat
var changeOnJump
var infiniteJump
var testAnims
var invincible

signal death( transform,  color)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.make_current()
	# get components
	# animation stuff
	staticAnim = $StaticSprite
	furAnim = $FurSprite
	wings = $Wings
	spritePlaying(true)
	# collider stuff
	bodyCol = $CollisionShape2D
	feetCol = $PlayerFeet/CollisionShape2D
	
	vignette = $Camera2D/ColorRect
	timer = $Timer
	respawnPoint = position
	
	objective = $Objective
	
	$Pause.visible = false
	$Settings.visible = false
	objective.visible = false
	# set cheat codes
	cheatCode("RainbowRat", false)
	cheatCode("Pidgeon", true)
	cheatCode("RainbowJump", false)
	cheatCode("LabRat", false)
	cheatCode("Catnip", false)
	cheatCode("GhostRat", false)
	
	rand = RandomNumberGenerator.new()
	rand.randomize()
	pickColor()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("Pause"):
		pause()
	# dying things
	if Input.is_action_just_pressed("Restart"):
		respawn()
	if dead and grounded:
		respawn()
	# vignette
	if !timer.is_stopped():
		vignette.modulate.a = (1.0-timer.time_left/5.0) *164.0/255.0
	if fadeObjective:
		objective.modulate.a -=.01
	# figure out movement
	determineFall()
	if !controlLock:
		determineWalk()
		determineClimb()
		determineJump()
		animate()
	# perform movement
	if !paused:
		velocity = move_and_slide(velocity)
		velocity.x = lerp(velocity.x,0,.5)
		if climbing:
			velocity.y = lerp(0,velocity.y,.5)

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
	if  Input.is_action_pressed("Jump") and Input.is_action_pressed("Down"):
			self.collision_mask =0b010
	else:
		self.collision_mask =0b110
		if 	Input.is_action_pressed("Jump") and (climbing or grounded or infiniteJump):
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
		if anim == "Run" or anim == "Jump":
			furAnim.animation = "TestRun"
		else:
			furAnim.animation = "TestIdle"
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

func respawn():
	setAnimation("Dead")
	controlLock = true
	dead = false
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("death", transform, furAnim.modulate)
	controlLock = false
	position = respawnPoint
	setAnimation("Idle")
	pickColor()
func pause():
	paused = !paused
	controlLock = paused
	$Pause.visible = paused

func startObjective(var text):
	objective.text = text
	yield(get_tree().create_timer(5.0), "timeout")
	objective.modulate.a = 1
	fadeObjective = true
# cheat codes
func cheatCode(var code, var active):
	match code:
		"RainbowRat" : 
			rainbowRat = active
		"Pidgeon" :
			infiniteJump = active
			wings.visible = active
		"RainbowJump":
			changeOnJump = active
		"LabRat":
			testAnims = active
			staticAnim.visible = !active
		"Catnip":
			invincible = active
		"GhostRat":
			furAnim.visible = !active
				
# collision triggers
func _on_Feet_area_entered(area):
	for g in area.get_groups():
		match(g):
			"Terrain":
				numGroundsTouched += 1
				grounded = true
			"Climbable":
				canClimb = true
			"SafeZone":
				safeZonesTouched += 1
				timer.stop()
				vignette.visible = false
			"Respawn":
				respawnPoint = area.global_position
func _on_Feet_area_exited(area):
	for g in area.get_groups():
		match(g):
			"Terrain":
				numGroundsTouched -= 1
				grounded = numGroundsTouched > 0
			"Climbable":
				canClimb = false
				climbing = false
			"SafeZone":
				safeZonesTouched -= 1
				if !safeZonesTouched > 0 and !invincible:
					timer.wait_time = TimeToDie
					timer.start()
					vignette.visible = true

func _on_Timer_timeout():
	if !invincible and !dead:
		setAnimation("Dead")
		dead = true
		controlLock = true
		timer.stop()

# pause menu buttons
func _on_Continue_button_down():
	pause()
func _on_Restart_button_down():
	pause()
	respawn()
func _on_Settings_button_down():
	$Settings.visible = true
func _on_Main_Menu_button_down():
	get_tree().change_scene("res://Menu/Main.tscn")
