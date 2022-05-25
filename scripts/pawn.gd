extends Node2D

export(String) var color
var point_of_view = "white"
var moved_two_squares = false
var id = "pawn"

func _ready():
	$AnimatedSprite.animation = color

func show_valid_moves(grid, squares):
	moved_two_squares = false
	var current_pos = position / 50
	
	var go_up = false
	if point_of_view == "white" and color == "white":
		go_up = true
	
	if point_of_view == "black" and color == "black":
		go_up = true
	
	if go_up and current_pos.y > 0:
		if grid[current_pos.x][current_pos.y-1] == null:
			squares[current_pos.x][current_pos.y-1].mark_as_valid(grid)
			if current_pos.y == 6 and grid[current_pos.x][current_pos.y-2] == null:
				squares[current_pos.x][current_pos.y-2].mark_as_valid(grid)
		if current_pos.x > 0 and grid[current_pos.x-1][current_pos.y-1] != null and grid[current_pos.x-1][current_pos.y-1].color != color:
			squares[current_pos.x-1][current_pos.y-1].mark_as_valid(grid)
		if current_pos.x < 7 and grid[current_pos.x+1][current_pos.y-1] != null and grid[current_pos.x+1][current_pos.y-1].color != color:
			squares[current_pos.x+1][current_pos.y-1].mark_as_valid(grid)
		if current_pos.x < 7 and grid[current_pos.x+1][current_pos.y-1] == null:
			if grid[current_pos.x+1][current_pos.y] != null and grid[current_pos.x+1][current_pos.y].name.find("pawn") >0:
				if grid[current_pos.x+1][current_pos.y].moved_two_squares:
					squares[current_pos.x+1][current_pos.y-1].mark_as_valid(grid)
		if current_pos.x>0 and grid[current_pos.x-1][current_pos.y-1] == null:
			if grid[current_pos.x-1][current_pos.y] != null and grid[current_pos.x-1][current_pos.y].name.find("pawn")>0:
				if grid[current_pos.x-1][current_pos.y].moved_two_squares:
					squares[current_pos.x-1][current_pos.y-1].mark_as_valid(grid)
	elif (not go_up) and current_pos.y < 7:
		if grid[current_pos.x][current_pos.y+1] == null:
			squares[current_pos.x][current_pos.y+1].mark_as_valid(grid)
			if current_pos.y == 1 and grid[current_pos.x][current_pos.y+2] == null:
				squares[current_pos.x][current_pos.y+2].mark_as_valid(grid)
		if current_pos.x > 0 and grid[current_pos.x-1][current_pos.y+1] != null and grid[current_pos.x-1][current_pos.y+1].color != color:
			squares[current_pos.x-1][current_pos.y+1].mark_as_valid(grid)
		if current_pos.x < 7 and grid[current_pos.x+1][current_pos.y+1] != null and grid[current_pos.x+1][current_pos.y+1].color != color:
			squares[current_pos.x+1][current_pos.y+1].mark_as_valid(grid)
		if current_pos.x>0 and grid[current_pos.x-1][current_pos.y+1] == null:
			if grid[current_pos.x-1][current_pos.y] != null and grid[current_pos.x-1][current_pos.y].name.find("pawn")>0:
				if grid[current_pos.x-1][current_pos.y].moved_two_squares:
					squares[current_pos.x-1][current_pos.y+1].mark_as_valid(grid)
		if current_pos.x<7 and grid[current_pos.x+1][current_pos.y+1] == null:
			if grid[current_pos.x+1][current_pos.y] != null and grid[current_pos.x+1][current_pos.y].name.find("pawn")>0:
				if grid[current_pos.x+1][current_pos.y].moved_two_squares:
					squares[current_pos.x+1][current_pos.y+1].mark_as_valid(grid)
