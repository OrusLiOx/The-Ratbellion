extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.make_current()
	$Settings.visible=false
	pass # Replace with function body.

func _on_Settings_button_down():
	$Settings.visible=true
func _on_Start_button_down():
	get_tree().change_scene("res://Menu/LevelSelect.tscn")
