extends Node2D
signal selected(piece)

var over_piece = null

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("click") and over_piece:
		print("emitting signal")
		emit_signal("selected", over_piece)


func _on_pawn_mouse_entered():
	print("hey")
	over_piece = "pawn"
func _on_pawn_mouse_exited():
	over_piece = null


func _on_knight_mouse_entered():
	over_piece = "knight"
func _on_knight_mouse_exited():
	over_piece = null


func _on_bishop_mouse_entered():
	over_piece = "bishop"
func _on_bishop_mouse_exited():
	over_piece = null


func _on_rook_mouse_entered():
	over_piece = "rook"
func _on_rook_mouse_exited():
	over_piece = null

func _on_queen_mouse_entered():
	over_piece = "queen"
func _on_queen_mouse_exited():
	over_piece = null

func _on_king_mouse_entered():
	over_piece = "king"
func _on_king_mouse_exited():
	over_piece = null


func _on_all_mouse_entered():
	over_piece = "all"
func _on_all_mouse_exited():
	over_piece = null
