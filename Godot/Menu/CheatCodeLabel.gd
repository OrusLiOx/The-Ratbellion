extends Label

signal toggle_code
func _on_Button_button_down():
	emit_signal("toggle_code")
