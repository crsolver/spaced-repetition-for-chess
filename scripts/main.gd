extends Node2D


func _ready():
	center()
	get_tree().get_root().connect("size_changed", self, "center")

func center():
	$game.position.x = get_viewport().size.x/2 - (50*8)/2
	$game.position.y = get_viewport().size.y/2 - (50*8)/2 #5
