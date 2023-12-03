extends Node
# saves cheat codes across scenes
var codes = [false,false,false,false,false,false]
var foundCodes = [false,false,false,false,false,false]

# sound
var vols = [50,40,60]

# misc
var paused = false
var pushing = false
var speed = 500

# level
var level = 0
var playMode

func nextLevel():
	if playMode and level < 2:
		level+=1
		return get_tree().change_scene("res://Levels/Level"+ str(level)+".tscn")
	else :
		return get_tree().change_scene("res://Menu/Main.tscn")
