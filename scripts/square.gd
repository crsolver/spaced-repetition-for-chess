extends Node2D

var is_valid = false
var color

func _ready():
	$Sprite.visible = false
	$Sprite2.visible = false
	color = $AnimatedSprite.animation


func select():
	$AnimatedSprite.animation = "selected"


func deselect():
	$AnimatedSprite.animation = color


func mark_as_valid(grid):
	$AnimationPlayer.play("1")
	var pos = position / 50
	if grid[pos.x][pos.y]:
		$Sprite2.visible = true
	else:
		$Sprite.visible = true
	is_valid = true


func quit_mark():
	$Sprite.visible = false
	$Sprite2.visible = false
	is_valid = false
