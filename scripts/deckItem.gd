extends Control
signal click(name)
signal delete_pressed(name)

var file_name = ""

func _ready():
	start()

func start():
	$MarginContainer/HBoxContainer2/file_button.text = file_name

func _on_file_button_pressed():
	emit_signal("click",file_name)


func _on_delete_pressed():
	emit_signal("delete_pressed", file_name)
