extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.make_current()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tutorial_button_down():
	get_tree().change_scene("res://Levels/Level0.tscn")
func _on_Main_button_down():
	get_tree().change_scene("res://Menu/Main.tscn")
