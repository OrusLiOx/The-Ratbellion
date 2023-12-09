extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicPlayer.menu()
	$Camera2D.make_current()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		queue_free()
		return get_tree().change_scene("res://Menu/Main.tscn")


func _on_Tutorial_button_down():
	queue_free()
	return get_tree().change_scene("res://Levels/Level0.tscn")
func _on_Level1_button_down():
	queue_free()
	return get_tree().change_scene("res://Levels/Level1.tscn")
func _on_Level2_button_down():
	queue_free()
	return get_tree().change_scene("res://Levels/Level2.tscn")

func _on_Main_button_down():
	queue_free()
	return get_tree().change_scene("res://Menu/Main.tscn")




