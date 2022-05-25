extends Node2D
signal selected(piece)

var over_piece = null


func _process(delta):
	if Input.is_action_just_pressed("click") and over_piece:
		emit_signal("selected", over_piece)


func _on_king_mouse_entered():
	over_piece = "queen"
	$king/Sprite.modulate = Color(0.62,0.84,0.17,1)


func _on_king_mouse_exited():
	over_piece = null
	$king/Sprite.modulate = Color(0.38,0.44,0.27,1)


func _on_knight_mouse_entered():
	over_piece = "knight"
	$knight/Sprite.modulate = Color(0.62,0.84,0.17,1)


func _on_knight_mouse_exited():
	over_piece = null
	$knight/Sprite.modulate = Color(0.38,0.44,0.27,1)


func _on_rook_mouse_entered():
	over_piece = "rook"
	$rook/Sprite.modulate = Color(0.62,0.84,0.17,1)


func _on_rook_mouse_exited():
	over_piece = null
	$rook/Sprite.modulate = Color(0.38,0.44,0.27,1)


func _on_bishop_mouse_entered():
	over_piece = "bishop"
	$bishop/Sprite.modulate = Color(0.62,0.84,0.17,1)


func _on_bishop_mouse_exited():
	over_piece = null
	$bishop/Sprite.modulate = Color(0.38,0.44,0.27,1)
