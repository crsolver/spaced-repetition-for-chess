extends Control
signal click(name)

var file_name = ""
var due = 0
var new = 0

func _ready():
	start()

func start():
	$MarginContainer/HBoxContainer/CenterContainer/name.text = file_name
	$MarginContainer/HBoxContainer/HBoxContainer2/Due.text = str(due)
	$MarginContainer/HBoxContainer/HBoxContainer2/New.text = str(new)


func _on_name_pressed():
	print("click")
	emit_signal("click",file_name)
