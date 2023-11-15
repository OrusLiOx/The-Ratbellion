extends Node2D

export (PackedScene) var deadrat

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.startLevel("Unlock the gate")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_death(transform, color):
	var rat = deadrat.instance()
	$DeadRats.add_child(rat)
	rat.transform = transform
	rat.get_child(0).modulate = color
