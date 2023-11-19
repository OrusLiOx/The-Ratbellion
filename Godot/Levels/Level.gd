extends Node2D

export (PackedScene) var deadrat
export var objective : String

# Called when the node enters the scene tree for the first time.
func _ready():
	if self.name == "Level0":
		MusicPlayer.tutorial()
	else:
		MusicPlayer.level()
	$Player.startLevel(objective)

func _on_Player_death(transform, color, flip):
	var rat = deadrat.instance()
	$DeadRats.add_child(rat)
	rat.transform = transform
	rat.get_child(0).flip_h = flip
	rat.get_child(1).flip_h = flip
	rat.get_child(0).modulate = color
