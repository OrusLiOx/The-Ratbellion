extends Label

onready var LineEditRegEx = RegEx.new()
onready var line_edit = $LineEdit
onready var slider = $HSlider

export var audio_index : int

func _ready():
	LineEditRegEx.compile("^[0-9]*$")
	Update_Labels()

func Update_Labels():
	line_edit.text = str(Globals.vols[audio_index])
	line_edit.set_cursor_position(line_edit.text.length())
	slider.value = Globals.vols[audio_index]
	var decible = linear2db(float(Globals.vols[audio_index])/100.0)
	AudioServer.set_bus_volume_db(audio_index, decible)

func check_bounds(var num):
	if num > 100:
		num = 100
	if num < 0:
		num = 0

	Globals.vols[audio_index] = num
	Update_Labels()

func _on_LineEdit_text_changed(new_text):
	if LineEditRegEx.search(new_text):
		Globals.vols[audio_index] = int(new_text)
	check_bounds(Globals.vols[audio_index])

func _on_HSlider_value_changed(value):
	Globals.vols[audio_index] = int(value)
	check_bounds(Globals.vols[audio_index])
