extends Control

func _input(_event):
	if Input.is_action_just_pressed("ui_exit"):
		get_tree().quit()
