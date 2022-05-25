extends Node2D


export(String) var color
var current_pos
var id = "bishop"

func _ready():
	current_pos = position / 50
	$AnimatedSprite.animation = color

func show_valid_moves(grid, squares):
	current_pos = position / 50
	
	for r in range(8):
			for c in range(8):
				squares[c][r].quit_mark()
	current_pos = position / 50
	#up right
	var r = current_pos.y-1
	var c = current_pos.x+1

	while c <= 7 and r >= 0:
		if grid[c][r] == null:
			squares[c][r].mark_as_valid(grid)
		else:
			if grid[c][r].color != color:
				squares[c][r].mark_as_valid(grid)
			break
		c += 1
		r -= 1
	
	#up left
	r = current_pos.y-1
	c = current_pos.x-1
	
	while c >= 0 and r >= 0:
		if grid[c][r] == null:
			squares[c][r].mark_as_valid(grid)
		else:
			if grid[c][r].color != color:
				squares[c][r].mark_as_valid(grid)
			break
		c -= 1
		r -= 1
	
	#down right
	r = current_pos.y+1
	c = current_pos.x+1
	
	while c <= 7 and r <= 7:
		if grid[c][r] == null:
			squares[c][r].mark_as_valid(grid)
		else:
			if grid[c][r].color != color:
				squares[c][r].mark_as_valid(grid)
			break
		c += 1
		r += 1

	#down left
	r = current_pos.y+1
	c = current_pos.x-1
	
	while c >= 0 and r <= 7:
		if grid[c][r] == null:
			squares[c][r].mark_as_valid(grid)
		else:
			if grid[c][r].color != color:
				squares[c][r].mark_as_valid(grid)
			break
		c -= 1
		r += 1
