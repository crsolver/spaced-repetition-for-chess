extends MarginContainer
signal clicked(f_name)

var file_name
var interval
var ease_porcentage


# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/Button.text = file_name
	$HBoxContainer/GridContainer/interva.text = str(interval)
	$HBoxContainer/GridContainer/ease.text = str(ease_porcentage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	emit_signal("clicked", file_name)
