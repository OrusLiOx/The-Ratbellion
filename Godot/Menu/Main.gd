extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.make_current()
	$Main.visible=true
	$Settings.visible=false
	$Controls.visible=false

func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		$Controls.visible = false

func _on_Settings_button_down():
	$Settings.visible=true
	$Main.visible = false
func _on_Start_button_down():
	get_tree().change_scene("res://Menu/LevelSelect.tscn")

func _on_Controls_button_down():
	$Controls.visible = true
	$Main.visible = false

func _on_CloseControls_button_down():
	$Controls.visible = false
	$Main.visible = true


func _on_Settings_close_settings():
	$Main.visible = true
