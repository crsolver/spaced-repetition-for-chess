extends Node2D
signal main_menu

var file_name
var point_of_view = null
var color = "white"
var center = false


func _ready():
	print("addmoves ready")
	center()
	get_tree().get_root().connect("size_changed", self, "center")
	$game.point_of_view = point_of_view
	$game.add_piece = true
	$game.mode = "add"
	$game.pause = false
	$game.start()
	$saver.file_name = file_name


func center():
	$game.position.x = get_viewport().size.x/2 - (50*8)/2
	$game.position.y = get_viewport().size.y/2 - (50*8)/2 #5
	if not center:
		$game.position += Vector2(0,20)
	
	$add_layer/pieces_selector.position.x = get_viewport().size.x/2 - (55*6)/2
	$add_layer/pieces_selector.position.y = $game.position.y - 70
	$add_layer/pieces_selector.connect("selected", self, "select_piece")


func select_piece(piece):
	$game.add_piece = true
	if piece == "pawn":
		$game.select_pawn(color)
	elif piece == "knight":
		$game.select_knight(color)
	elif piece == "bishop":
		$game.select_bishop(color)
	elif piece == "rook":
		$game.select_rook(color)
	elif piece == "queen":
		$game.select_queen(color)
	elif piece == "king":
		$game.select_king(color)
	elif piece == "all":
		$game.add_piece = false
		$game.all_pieces()
		$game.create_pieces()


func _on_cancel_pressed():
	emit_signal("main_menu")


func _on_color_pressed():
	if color == "white":
		color = "black"
	else:
		color = "white"
	$add_layer/Control2/CenterContainer2/color.text = color


func _on_saveInitial_pressed():
	$game.turn = point_of_view
	$add_layer/pieces_selector.visible = false
	$add_layer/Control2/CenterContainer2/color.visible = false
	$saver.set_initial($game.grid, point_of_view)
	$add_layer/Control/CenterContainer/HBoxContainer/saveInitial.visible = false
	$game.position.y = get_viewport().size.y/2 - (50*8)/2 #5
	$game.save_moves = true
	$game.allow_delete = false
	center = true


func _on_save_pressed():
	$game.visible = false
	print("pressing")
	$game.pause = true
	$add_layer/Control3.visible = true
	print($add_layer/Control3.visible)


func _on_TextEdit_text_entered(new_text):
	print("saveing " + new_text)
	if new_text:
		$add_layer/Control3.visible = false
		$saver.save(new_text)
		emit_signal("main_menu")


func _on_save_with_name_pressed():
	_on_TextEdit_text_entered($add_layer/Control3/CenterContainer2/HBoxContainer/TextEdit.text)


func _on_game_first_move():
	$add_layer/Control/CenterContainer/HBoxContainer/save.disabled = false
