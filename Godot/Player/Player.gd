extends KinematicBody2D

export var step : AudioStream
export var checkpoint : AudioStream
export var win : AudioStream
export var slash : AudioStream

var speed = 500
var jumpPower =-1000
var gravity = 50
var TimeToDie = 4
var controlLock = false

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
var objective
var paw: AnimatedSprite
var audio : AudioStreamPlayer

# cheat codes
var rainbowRat
var changeOnJump
var infiniteJump
var testAnims
var invincible

signal death( transform,  color, flip)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.make_current()
	self.visible = true
	# get components
	# animation stuff
	staticAnim = $StaticSprite
	furAnim = $FurSprite
	wings = $Wings
	spritePlaying(true)
	paw = $CatPaw
	paw.visible = false

	bodyCol = $CollisionShape2D
	feetCol = $PlayerFeet/CollisionShape2D
	
	vignette = $Camera2D/ColorRect
	timer = $Timer
	
	objective = $Objective
	
	audio = $Audio
	
	rand = RandomNumberGenerator.new()
	rand.randomize()
	pickColor()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_just_pressed("Pause"):
		pause()
	# dying things
	if !paused and Input.is_action_just_pressed("Restart"):
		respawn()
	if dead and grounded:
		respawn()
	# things based on timer
	if !timer.is_stopped():
		vignette.modulate.a = 1.0/(timer.time_left+.8) #(1.0-timer.time_left/5.0) *164.0/255.0
		if timer.time_left < .7 and !paw.visible:
			pawAppear()
	if fadeObjective:
		objective.modulate.a -=.01
	# figure out movement
	if !paused:
		determineFall()
	if !controlLock:
		determineWalk()
		determineClimb()
		determineJump()
		animate()
	# perform movement
	if !paused:
		self.set_collision_mask_bit(3, climbing)
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
	if canClimb and !(Input.is_action_pressed("Jump") and velocity.y <-speed):
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
		self.set_collision_mask_bit(2, false)
	else:
		self.set_collision_mask_bit(2, true)
		if 	Input.is_action_just_pressed("Jump") and (climbing or grounded or infiniteJump):
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
		if climbAnim or walking:
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

func pawAppear():
	paw.visible = true
	match rand.randi_range(0,5):
		0:
			paw.get_child(0).modulate = Color(1,1,1)
		1:
			paw.get_child(0).modulate = Color(44.0/255,44.0/255,44.0/255)
		2:
			paw.get_child(0).modulate = Color(239.0/255,177.0/255,112.0/255)
		3:
			paw.get_child(0).modulate = Color(141.0/255,141.0/255,141.0/255)
		4:
			paw.get_child(0).modulate = Color(112.0/255,88.0/255,63.0/255)
		5:
			paw.get_child(0).modulate = Color(99.0/255,111.0/255,133.0/255)
	playAnim("Appear")
func playAnim(var anim):
	paw.play(anim)
	paw.get_child(0).play(anim)
	paw.frame=0
	paw.get_child(0).frame=0

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
			1: # blue
				var r = 58.0
				val = float(rand.randi_range(0,r))/255.0
				color = Color(	55.0/255.0+val,
								71.0/255.0+val*53.0/r,
								86.0/255.0+val*47.0/r,
								1)
			2: # brown
				var r = 90.0
				val = float(rand.randi_range(0,r))/255.0
				color = Color(	67.0/255.0+val*66.0/r,
								55.0/255.0+val*68.0/r,
								43.0/255.0+val,
								1)
			
	# brown
	
	furAnim.modulate = color
	wings.modulate = color

func pause():
	paused = !paused
	controlLock = paused
	$Pause.visible = paused
	if !paused:
		timer.paused = false
		loadCheats()
	else:
		$Pause/Main.visible = true
		$Settings/Main.visible = true
		$Settings/CheatCodes.visible = false
		timer.paused = true
func startLevel(var text):
	# set defaults
	$Pause.visible = false
	$Settings.visible = false
	objective.visible = true
	$Complete.visible = false
	controlLock = false
	safeZonesTouched = 0
	numGroundsTouched = 0
	respawnPoint = position
	
	loadCheats()
	# objective text
	objective.text = text
	yield(get_tree().create_timer(5.0), "timeout")
	objective.modulate.a = 1
	fadeObjective = true
func playSound(var sound):
	audio.stream = sound
	audio.play()

# cheat codes
func loadCheats():
	var active
	# catnip
	active = Globals.codes[0]
	invincible = active
	# pigeon
	active = Globals.codes[1]
	infiniteJump = active
	wings.visible = active
	# rainbow rat
	active = Globals.codes[2]
	rainbowRat = active
	# rainbow jump
	active = Globals.codes[3]
	changeOnJump = active
	# ghost
	active = Globals.codes[4]
	furAnim.visible = !active
	# lab rat
	active = Globals.codes[5]
	testAnims = active
	staticAnim.visible = !active
	if active and !rainbowRat:
		furAnim.modulate = Color.white

# collision triggers
func _on_Feet_area_entered(area):
	for g in area.get_groups():
		match g:
			"Terrain":
				numGroundsTouched += 1
				grounded = true
			"Climbable":
				canClimb = true
			"SafeZone":
				safeZonesTouched += 1
				timer.stop()
				vignette.visible = false
				paw.visible = false;
			"Respawn":
				if respawnPoint != area.global_position:
					playSound(checkpoint)
					respawnPoint = area.global_position
			"End":
				if paused:
					pause()
				playSound(win)
				$Complete.visible = true
				controlLock = true
				setAnimation("Idle")
				yield(get_tree().create_timer(2.0), "timeout")
				$Complete.visible = false
				return get_tree().change_scene("res://Menu/LevelSelect.tscn")
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

# die
func _on_Timer_timeout():
	if !invincible and !dead:
		playSound(slash)
		playAnim("Swipe")
		setAnimation("Dead")
		climbing = false
		dead = true
		controlLock = true
		timer.stop()
func respawn():
	setAnimation("Dead")
	controlLock = true
	dead = false
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("death", transform, furAnim.modulate, furAnim.flip_h)
	controlLock = false
	position = respawnPoint
	setAnimation("Idle")
	pickColor()

# pause menu buttons
func _on_Continue_button_down():
	pause()
func _on_Restart_button_down():
	pause()
	respawn()
func _on_Settings_button_down():
	$Settings.visible = true
	$Pause/Main.visible = false
func _on_Main_Menu_button_down():
	return get_tree().change_scene("res://Menu/Main.tscn")
func _on_Settings_close_settings():
	$Pause/Main.visible = true
