extends Node2D

export(String) var color
var current_pos
var id = "king"

func _ready():
	$AnimatedSprite.animation = color

func show_valid_moves(grid, squares):
	current_pos = position / 50
	
	if current_pos.x == 4 and (current_pos.y==0 or current_pos.y==7):
		if grid[current_pos.x+1][current_pos.y] == null and grid[current_pos.x+2][current_pos.y] == null and grid[current_pos.x+3][current_pos.y] != null:
			if grid[current_pos.x+3][current_pos.y].name.find('rook') >=0:
				squares[current_pos.x+2][current_pos.y].mark_as_valid(grid)
		if grid[current_pos.x-1][current_pos.y] == null and grid[current_pos.x-2][current_pos.y] == null and grid[current_pos.x-3][current_pos.y] == null and grid[current_pos.x-4][current_pos.y] != null:
			if grid[current_pos.x-4][current_pos.y].name.find('rook') >=0:
				squares[current_pos.x-2][current_pos.y].mark_as_valid(grid)
				
	evaluate_square(-1,1, grid, squares)
	evaluate_square(-1,0, grid, squares)
	evaluate_square(-1,-1, grid, squares)
	evaluate_square(0,-1, grid, squares)
	evaluate_square(1,-1, grid, squares)
	evaluate_square(1,0, grid, squares)
	evaluate_square(1,1, grid, squares)
	evaluate_square(0,1, grid, squares)

func evaluate_square(x, y, grid, squares):
	var move = Vector2(current_pos.x+x, current_pos.y+y)
	if move.x >= 0 and move.x <=7 and move.y >= 0 and move.y <=7:
		if squares[move.x][move.y]:
					if grid[move.x][move.y] == null or grid[move.x][move.y].color != color:
						 squares[move.x][move.y].mark_as_valid(grid)
