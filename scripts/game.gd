extends Node2D
signal card_finished
signal first_move

var square_scene = preload("res://scenes/square.tscn")
var pawn_scene = preload("res://scenes/pawn.tscn")
var queen_scene = preload("res://scenes/queen.tscn")
var bishop_scene = preload("res://scenes/bishop.tscn")
var rook_scene = preload("res://scenes/rook.tscn")
var king_scene = preload("res://scenes/king.tscn")
var knight_scene = preload("res://scenes/knight.tscn")
var promotion_scene = preload("res://scenes/promotion.tscn")

var size = 50
var grid
var squares
var clicked_pos = null
var selected_piece = null
var turn = "white"
var point_of_view = "white"
var pause = false
var promotion = null
var piece_to_pro_pos = null
var mode = null
var automatic = false
var first_moved = false
var add_piece = false
var saver = null
var save_moves = false
var sequence
var from
var to
var sequence_index = 0
var allow_delete = false
var piece_moving = false
var piece_deleted


func _ready():
	pass

func start():
	sequence_index = 0
	from = null
	to = null
	piece_moving = false
	if grid:
		for r in range(8):
			for c in range(8):
				if grid[c][r]:
					grid[c][r].queue_free()
					
	if mode == "add":
		allow_delete = true
		saver = get_parent().get_child(2)
	grid = create_grid(8,8)
	squares = create_grid(8,8)
	
	if mode == "review" and sequence.size() >0:
		from = Vector2(sequence[0]["from"][0], sequence[0]["from"][1])
		to = Vector2(sequence[0]["to"][0], sequence[0]["to"][1])
	if not squares[0][0]:
		create_board()
	create_pieces()
	if automatic:
		pause = true
	else:
		pause = false

func set_initial(arr):
	var i = 0
	for r in range(8):
		for c in range(8):
			if arr[i]:
				var piece = create_piece(arr[i]["piece"], arr[i]["color"])
				grid[c][r] = piece
				piece.position = Vector2(c,r) * size
				add_child(piece)
			i += 1

func create_piece(p, c):
	var obj = null
	if p == "pawn":
		obj = pawn_scene.instance()
		obj.point_of_view = point_of_view
	elif p == "knight":
		obj = knight_scene.instance()
	elif p == "rook":
		obj = rook_scene.instance()
	elif p == "bishop":
		obj = bishop_scene.instance()
	elif p == "queen":
		obj = queen_scene.instance()
	elif p == "king":
		obj = king_scene.instance()
	obj.color = c
	return obj


func all_pieces():
	quit_marks()
	for r in range(8):
		for c in range(8):
			if grid[c][r] != null:
				grid[c][r].queue_free()
			grid[c][r] = null
	
	var i = 6
	var j = 1
	if point_of_view == "black":
		j = 6
		i = 1
	for c in range(8):
			grid[c][i] = pawn_scene.instance()
			grid[c][i].color = "white"
			grid[c][j] = pawn_scene.instance()
			grid[c][j].color = "black"
			if point_of_view == "black":
				grid[c][i].point_of_view = "black"
				grid[c][j].point_of_view = "black"
	
	i = 7
	j = 0
	if point_of_view == "black":
		i = 0
		j = 7
	grid[0][j] = rook_scene.instance()
	grid[0][j].color = "black"
	grid[0][i] = rook_scene.instance()
	grid[0][i].color = "white"
	grid[7][j] = rook_scene.instance()
	grid[7][j].color = "black"
	grid[7][i] = rook_scene.instance()
	grid[7][i].color = "white"
	grid[1][j] = knight_scene.instance()
	grid[1][j].color = "black"
	grid[1][i] = knight_scene.instance()
	grid[1][i].color = "white"
	grid[6][j] = knight_scene.instance()
	grid[6][j].color = "black"
	grid[6][i] = knight_scene.instance()
	grid[6][i].color = "white"
	grid[2][i] = bishop_scene.instance()
	grid[2][i].color = "white"
	grid[2][j] = bishop_scene.instance()
	grid[2][j].color = "black"
	grid[5][i] = bishop_scene.instance()
	grid[5][i].color = "white"
	grid[5][j] = bishop_scene.instance()
	grid[5][j].color = "black"
	grid[3][i] = queen_scene.instance()
	grid[3][i].color = "white"
	grid[3][j] = queen_scene.instance()
	grid[3][j].color = "black"
	grid[4][i] = king_scene.instance()
	grid[4][i].color = "white"
	grid[4][j] = king_scene.instance()
	grid[4][j].color = "black"
	turn = "white"

var mouse_grid_pos

func _process(delta):
	piece_deleted = null
	if mode == "review":
		mouse_grid_pos = ((get_viewport().get_mouse_position() - get_parent().position)) / size
	else:
		mouse_grid_pos = ((get_viewport().get_mouse_position() - position)) / size
	mouse_grid_pos = Vector2(floor(mouse_grid_pos.x), floor(mouse_grid_pos.y))
	
	# If cursor inside the board
	if (mouse_grid_pos.x >= 0 and mouse_grid_pos.x <= 7 and mouse_grid_pos.y >= 0 and mouse_grid_pos.y <= 7 and not pause) or add_piece:
		if Input.is_action_just_pressed("click2") and add_piece == false and grid[mouse_grid_pos.x][mouse_grid_pos.y] != null and mode == "add" and allow_delete:
			grid[mouse_grid_pos.x][mouse_grid_pos.y].queue_free()
			grid[mouse_grid_pos.x][mouse_grid_pos.y] = null
			selected_piece = null
		if Input.is_action_just_pressed("click"):
			# If a piece is selected change its position to the clicked square
			if selected_piece:
				if squares[mouse_grid_pos.x][mouse_grid_pos.y].is_valid:
					$piece_placed_sound.pitch_scale = rand_range(1, 3)
					$piece_placed_sound.play()
					quit_marks()
					if grid[mouse_grid_pos.x][mouse_grid_pos.y] != null:
						if mode != "review" or (mode == "review" and clicked_pos == from and mouse_grid_pos == to):
							print("deleting a piece")
							grid[mouse_grid_pos.x][mouse_grid_pos.y].queue_free()
							grid[mouse_grid_pos.x][mouse_grid_pos.y] = null
							piece_deleted = mouse_grid_pos
					if mode == "review":
							if clicked_pos == from and mouse_grid_pos == to:
								move_piece()
								next_sequence()
							else:
								$Line2D.visible = true
								var offset = Vector2(size/2, size/2)
								$Line2D.points[1] = from * size
								$Line2D.points[1] += offset
								$Line2D.points[0] = to * size
								$Line2D.points[0] += offset
								selected_piece.position = clicked_pos * size
								selected_piece = null
					else:
						move_piece()
				elif mouse_grid_pos != clicked_pos:
					quit_marks()
					if grid[mouse_grid_pos.x][mouse_grid_pos.y] and grid[mouse_grid_pos.x][mouse_grid_pos.y].color == selected_piece.color:
						selected_piece = grid[mouse_grid_pos.x][mouse_grid_pos.y]
						selected_piece.show_valid_moves(grid, squares)
						clicked_pos = mouse_grid_pos
						squares[clicked_pos.x][clicked_pos.y].select()
					else:
						selected_piece = null
						quit_marks()
			#si no es valido

			# Else select the piece and save its current position
			elif (mouse_grid_pos.x >= 0 and mouse_grid_pos.x <= 7 and mouse_grid_pos.y >= 0 and mouse_grid_pos.y <= 7 and not pause) and grid[mouse_grid_pos.x][mouse_grid_pos.y] != null:
				quit_marks()
				if grid[mouse_grid_pos.x][mouse_grid_pos.y].color == turn:
					clicked_pos = mouse_grid_pos
					selected_piece = grid[clicked_pos.x][clicked_pos.y]
					squares[clicked_pos.x][clicked_pos.y].select()
					selected_piece.show_valid_moves(grid, squares)

		if Input.is_action_pressed("click"):
			# Drag the piece
			if (selected_piece and selected_piece.color == turn) or (selected_piece and add_piece):
				selected_piece.z_index = 10
				if mode == "review":
					selected_piece.position = (get_viewport().get_mouse_position() - get_parent().position) - Vector2(25,25)
				else:
					selected_piece.position = (get_viewport().get_mouse_position() - position) - Vector2(25,25)
		
		if Input.is_action_just_released("click") and selected_piece:
			# if a piece is being dragged and the mouse button is released
			# update its position and deselect it
			if add_piece and (mouse_grid_pos.x >= 0 and mouse_grid_pos.x <= 7 and mouse_grid_pos.y >= 0 and mouse_grid_pos.y <= 7 and not pause):
					place_added_piece()
			elif add_piece:
				selected_piece.queue_free()
				selected_piece = null
				add_piece = false
			else:
				if clicked_pos != mouse_grid_pos:
					if squares[mouse_grid_pos.x][mouse_grid_pos.y].is_valid:
						$piece_placed_sound.pitch_scale = rand_range(2, 4)
						$piece_placed_sound.play()
						quit_marks()
						if grid[mouse_grid_pos.x][mouse_grid_pos.y] != null:
							if mode != "review" or (mode == "review" and clicked_pos == from and mouse_grid_pos == to):
								print("deleting a piece")
								grid[mouse_grid_pos.x][mouse_grid_pos.y].queue_free()
								grid[mouse_grid_pos.x][mouse_grid_pos.y] = null
								piece_deleted = mouse_grid_pos
						if mode == "review":
							if clicked_pos == from and mouse_grid_pos == to:
								move_piece()
								next_sequence()
							else:
								$Line2D.visible = true
								var offset = Vector2(size/2, size/2)
								$Line2D.points[1] = from * size
								$Line2D.points[1] += offset
								$Line2D.points[0] = to * size
								$Line2D.points[0] += offset
								selected_piece.position = clicked_pos * size
								selected_piece = null
						else:
							move_piece()
					elif not add_piece:
						selected_piece.position = clicked_pos * size
						selected_piece.z_index = 2
						#selected_piece = null
					elif add_piece:
						selected_piece.queue_free()
						selected_piece = null
				else:
					# if is in the original position when is released leave it there
					selected_piece.position = mouse_grid_pos * size
					selected_piece.z_index = 2
	# if the selected piece is being dragged outside the board restore its original position
	elif selected_piece and not add_piece:
		selected_piece.z_index = 2
		selected_piece.position = clicked_pos * size
		selected_piece = null

func move():
	if piece_moving:
		return
	if sequence_index < sequence.size():
		print(sequence[sequence_index]["promotion"])
		piece_moving = true
		from = Vector2(sequence[sequence_index]["from"][0], sequence[sequence_index]["from"][1])
		to = Vector2(sequence[sequence_index]["to"][0], sequence[sequence_index]["to"][1])
		var xpiece = grid[from.x][from.y]
		xpiece.z_index = 11
		print("selected_piece " + str(from))
		$Tween.interpolate_property(xpiece, "position", xpiece.position, to * size, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		$Tween.start()
		#sequence_index += 1


func next_sequence():
	print("sequence.size " +str(sequence.size()))
	pause = false
	sequence_index += 1
	if sequence_index < sequence.size():
		print("current_sequence: " + str(sequence_index))
		piece_moving = true
		from = Vector2(sequence[sequence_index]["from"][0], sequence[sequence_index]["from"][1])
		to = Vector2(sequence[sequence_index]["to"][0], sequence[sequence_index]["to"][1])
		if turn != point_of_view:
			pause = true
			#selected_piece = grid[from.x][from.y]
			var xpiece = grid[from.x][from.y]
			xpiece.z_index = 11
			print("selected_piece " + str(from))
			$Tween.interpolate_property(xpiece, "position", xpiece.position, to * size, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Tween.start()
	else:
		pause = true
		emit_signal("card_finished")

func select_pawn(color):
	add_piece = true
	selected_piece = pawn_scene.instance()
	selected_piece.point_of_view = point_of_view
	selected_piece.color = color
	add_child(selected_piece)
	selected_piece.position = (get_viewport().get_mouse_position() - position) - Vector2(25,25)

func select_knight(color):
	add_piece = true	
	selected_piece = knight_scene.instance()
	selected_piece.color = color
	add_child(selected_piece)
	selected_piece.position = (get_viewport().get_mouse_position() - position) - Vector2(25,25)

func select_bishop(color):
	add_piece = true
	selected_piece = bishop_scene.instance()
	selected_piece.color = color
	add_child(selected_piece)
	selected_piece.position = (get_viewport().get_mouse_position() - position) - Vector2(25,25)

func select_rook(color):
	add_piece = true
	selected_piece = rook_scene.instance()
	selected_piece.color = color
	add_child(selected_piece)
	selected_piece.position = (get_viewport().get_mouse_position() - position) - Vector2(25,25)
	
func select_queen(color):
	add_piece = true
	selected_piece = queen_scene.instance()
	selected_piece.color = color
	add_child(selected_piece)
	selected_piece.position = (get_viewport().get_mouse_position() - position) - Vector2(25,25)

func select_king(color):
	add_piece = true
	selected_piece = king_scene.instance()
	selected_piece.color = color
	add_child(selected_piece)
	selected_piece.position = (get_viewport().get_mouse_position() - position) - Vector2(25,25)

func move_piece():
	$Line2D.visible = false
	print(selected_piece.name)
	for r in range(8):
			for c in range(8):
				if grid[c][r] != null:
					if grid[c][r].name.find("pawn") >=0:
						grid[c][r].moved_two_squares = false
	
	if selected_piece.name.find("pawn") >= 0 and piece_deleted != mouse_grid_pos:	
		#print(grid[mouse_grid_pos.x][mouse_grid_pos.y].name)
		print(mouse_grid_pos)
		print("peasant")
		passant()
	if selected_piece.name.find("king") >= 0:
		castle()

	if selected_piece:
		print("checking")
		grid[clicked_pos.x][clicked_pos.y] = null
		grid[mouse_grid_pos.x][mouse_grid_pos.y] = selected_piece
		if saver and save_moves:
			saver.add_move(clicked_pos, mouse_grid_pos, null)
			if not first_moved:
				emit_signal("first_move")
				first_moved = true
		selected_piece.position = mouse_grid_pos * size
		selected_piece.z_index = 2
		if mode == "review":
			print("suquencedata: " + str(sequence[sequence_index]))
			print("mouse_grid_pos "+str(mouse_grid_pos))
			print("color " + selected_piece.color)
			print("point_of_view " + point_of_view)
			print("mode " + mode)
			print("pawn in name " + str(selected_piece.name.find("pawn")>=0))
			print("current turn  " + turn)
			#print("intended new piece " + sequence[sequence_index]["promotion"])
		if selected_piece.name.find("pawn")>=0 and mouse_grid_pos.y == 0 and ((point_of_view == "white" and selected_piece.color == "white") or (point_of_view == "black" and selected_piece.color == "black")):
			if mode=="review":
				print("creating piece")
				var new_piece = create_piece(sequence[sequence_index]["promotion"], turn)
				new_piece.position = Vector2(mouse_grid_pos.x,mouse_grid_pos.y) * size
				grid[mouse_grid_pos.x][mouse_grid_pos.y].queue_free()
				grid[mouse_grid_pos.x][mouse_grid_pos.y] = new_piece
				add_child(new_piece)
			elif not automatic:
				print("creating promotion scene")
				promotion = promotion_scene.instance()
				promotion.position = mouse_grid_pos * size
				add_child(promotion)
				promotion.connect("selected", self, "on_promotion_selected")
				pause = true
				selected_piece = null
				return
		elif selected_piece.name.find("pawn")>=0 and mouse_grid_pos.y == 7 and ((point_of_view == "white" and selected_piece.color == "black") or (point_of_view == "black" and selected_piece.color == "white")):
			if mode=="review":
				print("creating piece")
				var new_piece = create_piece(sequence[sequence_index]["promotion"], turn)
				new_piece.position = Vector2(mouse_grid_pos.x,mouse_grid_pos.y) * size
				grid[mouse_grid_pos.x][mouse_grid_pos.y].queue_free()
				grid[mouse_grid_pos.x][mouse_grid_pos.y] = new_piece
				add_child(new_piece)
			elif not automatic:
				print("creating promotion scene")
				promotion = promotion_scene.instance()
				promotion.position = Vector2(mouse_grid_pos.x*50, (mouse_grid_pos.y*50)-(50*3))
				add_child(promotion)
				promotion.connect("selected", self, "on_promotion_selected")
				pause = true
				selected_piece = null
				return
			else:
				print("no no no")
		
		selected_piece = null
	if not automatic:
		next_turn()


func place_added_piece():
	if grid[mouse_grid_pos.x][mouse_grid_pos.y] == null:
		grid[mouse_grid_pos.x][mouse_grid_pos.y] = selected_piece
		selected_piece.position = mouse_grid_pos * size
		selected_piece.z_index = 2
		selected_piece = null
	else:
		selected_piece.queue_free()
		selected_piece = null
	add_piece = false


func passant():
	if mouse_grid_pos.x == clicked_pos.x and mouse_grid_pos.y == clicked_pos.y +2:
		selected_piece.moved_two_squares = true
	if mouse_grid_pos.x == clicked_pos.x and mouse_grid_pos.y == clicked_pos.y -2:
		selected_piece.moved_two_squares = true
	if mouse_grid_pos.x == clicked_pos.x+1 and mouse_grid_pos.y == clicked_pos.y-1:
		if grid[mouse_grid_pos.x][mouse_grid_pos.y+1] != null and grid[mouse_grid_pos.x][mouse_grid_pos.y+1].name.find("pawn") and grid[mouse_grid_pos.x][mouse_grid_pos.y+1].color != selected_piece.color:
			grid[mouse_grid_pos.x][mouse_grid_pos.y+1].queue_free()
			grid[mouse_grid_pos.x][mouse_grid_pos.y+1] = null
	if mouse_grid_pos.x == clicked_pos.x-1 and mouse_grid_pos.y == clicked_pos.y-1:
		if grid[mouse_grid_pos.x][mouse_grid_pos.y+1] != null and grid[mouse_grid_pos.x][mouse_grid_pos.y+1].name.find("pawn") and grid[mouse_grid_pos.x][mouse_grid_pos.y+1].color != selected_piece.color:
			grid[mouse_grid_pos.x][mouse_grid_pos.y+1].queue_free()
			grid[mouse_grid_pos.x][mouse_grid_pos.y+1] = null
	if mouse_grid_pos.x == clicked_pos.x-1 and mouse_grid_pos.y == clicked_pos.y+1:
		if grid[mouse_grid_pos.x][mouse_grid_pos.y-1] != null and grid[mouse_grid_pos.x][mouse_grid_pos.y-1].name.find("pawn") and grid[mouse_grid_pos.x][mouse_grid_pos.y-1].color != selected_piece.color:
			grid[mouse_grid_pos.x][mouse_grid_pos.y-1].queue_free()
			grid[mouse_grid_pos.x][mouse_grid_pos.y-1] = null
	if mouse_grid_pos.x == clicked_pos.x+1 and mouse_grid_pos.y == clicked_pos.y+1:
		if grid[mouse_grid_pos.x][mouse_grid_pos.y-1] != null and grid[mouse_grid_pos.x][mouse_grid_pos.y-1].name.find("pawn") and grid[mouse_grid_pos.x][mouse_grid_pos.y-1].color != selected_piece.color:
			grid[mouse_grid_pos.x][mouse_grid_pos.y-1].queue_free()
			grid[mouse_grid_pos.x][mouse_grid_pos.y-1] = null


func castle():
	if not first_moved:
				emit_signal("first_move")
				first_moved = true
	if (mouse_grid_pos.x == 6 and (mouse_grid_pos.y==0 or mouse_grid_pos.y==7)) and clicked_pos.x == 4 and (clicked_pos.y == 7 or clicked_pos.y == 0):
		if grid[clicked_pos.x+1][clicked_pos.y] == null and grid[clicked_pos.x+2][clicked_pos.y] == null and grid[clicked_pos.x+3][clicked_pos.y] != null:
			if grid[clicked_pos.x+3][clicked_pos.y].name.find('rook') >=0:
				grid[clicked_pos.x][clicked_pos.y] = null
				grid[clicked_pos.x+2][clicked_pos.y] = selected_piece
				if saver and save_moves:
					saver.add_move(clicked_pos, mouse_grid_pos, null)
				selected_piece.position = Vector2(6, mouse_grid_pos.y) * size
				grid[clicked_pos.x+1][clicked_pos.y] = grid[clicked_pos.x+3][clicked_pos.y]
				grid[clicked_pos.x+3][clicked_pos.y] = null
				grid[clicked_pos.x+1][clicked_pos.y].position = Vector2(5, mouse_grid_pos.y) * size
				selected_piece.z_index = 2
				selected_piece = null
	elif (mouse_grid_pos.x == 2 and (mouse_grid_pos.y==0 or mouse_grid_pos.y==7)) and clicked_pos.x == 4 and (clicked_pos.y == 7 or clicked_pos.y == 0):
		if grid[clicked_pos.x-1][clicked_pos.y] == null and grid[clicked_pos.x-2][clicked_pos.y] == null and grid[clicked_pos.x-3][clicked_pos.y] == null and grid[clicked_pos.x-4][clicked_pos.y] != null:
			if grid[clicked_pos.x-4][clicked_pos.y].name.find('rook') >=0:
				grid[clicked_pos.x][clicked_pos.y] = null
				grid[clicked_pos.x-2][clicked_pos.y] = selected_piece
				if saver and save_moves:
					saver.add_move(clicked_pos, mouse_grid_pos, null)
				selected_piece.position = Vector2(2, mouse_grid_pos.y) * size
				grid[clicked_pos.x-1][clicked_pos.y] = grid[clicked_pos.x-4][clicked_pos.y]
				grid[clicked_pos.x-4][clicked_pos.y] = null
				grid[clicked_pos.x-1][clicked_pos.y].position = Vector2(3, mouse_grid_pos.y) * size
				selected_piece.z_index = 2
				
				selected_piece = null


func on_promotion_selected(piece):
	if saver and saver.sequence.size()>0:
		saver.sequence[saver.sequence.size()-1]["promotion"] = piece
	var selected_pos = promotion.position / 50
	if selected_pos.y == 4:
		selected_pos.y = 7
	var color = grid[selected_pos.x][selected_pos.y].color
	grid[selected_pos.x][selected_pos.y].queue_free()
	var new_piece
	if piece == "queen":
		new_piece = queen_scene.instance()
	elif piece == "knight":
		new_piece = knight_scene.instance()
	elif piece == "rook":
		new_piece = rook_scene.instance()
	elif piece == "bishop":
		new_piece = bishop_scene.instance()
	new_piece.color = color
	new_piece.position = selected_pos * 50
	add_child(new_piece)
	grid[selected_pos.x][selected_pos.y] = new_piece
	promotion.queue_free()
	next_turn()
	pause = false

func next_turn():
	#sequence_index += 1
	if turn == "white":
		turn = "black"
	else:
		turn = "white"
	print("turn changed to " + turn)
	print("pause " + str(pause))



func quit_marks():
	for r in range(8):
		for c in range(8):
			squares[c][r].quit_mark()
			squares[c][r].deselect()


func create_board():
	var square 
	var create_white = false
	
	for row in range(8):
		create_white = not create_white
		for colum in range(8):
			square = square_scene.instance()
			if create_white:
				square.get_node("AnimatedSprite").animation = "white"
			else:
				square.get_node("AnimatedSprite").animation = "black"
			square.position = Vector2(colum, row) * size
			add_child(square)
			squares[colum][row] = square
			create_white = not create_white


func create_pieces():
	for r in range(8):
			for c in range(8):
				if not grid[c][r] == null:
					grid[c][r].z_index = 8
					grid[c][r].position = Vector2(c,r) * size
					add_child(grid[c][r])


func create_grid(r, c):
	var arr = []
	for x in range(r):
		arr.append([])
		arr[x]=[]        
		for y in range(c):
			arr[x].append([])
			arr[x][y] = null
	return arr


func _on_Tween_tween_completed(object, key):
	#$piece_placed_sound.pitch_scale = rand_range(1, 3)
	$piece_placed_sound.play()
	selected_piece = grid[from.x][from.y]
	selected_piece.z_index = 2
	if grid[to.x][to.y]:
		piece_deleted = to
		grid[to.x][to.y].queue_free()
		grid[to.x][to.y] = null
	clicked_pos = from
	mouse_grid_pos = to
	piece_moving = false
	move_piece()
	if automatic:
		sequence_index += 1
		next_turn()
	else:
		next_sequence()
