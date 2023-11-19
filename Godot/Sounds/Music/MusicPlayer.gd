extends Node2D

var flute : AudioStreamPlayer
var bassoon : AudioStreamPlayer
var drum : AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	flute =$Flute
	bassoon = $Bassoon
	drum =$Drum
	
	flute.volume_db = -80
	bassoon.volume_db = -80
	drum.volume_db = -80
	
	flute.playing = true
	bassoon.playing = true
	drum.playing = true
	
	pass # Replace with function body.

func menu():
	flute.volume_db = -80
	bassoon.volume_db = -80
	drum.volume_db = 1

func tutorial():
	flute.volume_db = 1
	bassoon.volume_db = -80
	drum.volume_db = 1

func level():
	flute.volume_db = 1
	bassoon.volume_db = 1
	drum.volume_db = 1
