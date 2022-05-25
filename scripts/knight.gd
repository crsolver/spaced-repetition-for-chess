extends Node2D

export(String) var color
var current_pos
var id = "knight"
func _ready():
	current_pos = position / 50
	$AnimatedSprite.animation = color

func show_valid_moves(grid, squares):
	current_pos = position / 50
	
	var valid_moves = [
		Vector2(-2, -1),
		Vector2(-1, -2),
		Vector2(1, -2),
		Vector2(2, -1),
		Vector2(2, 1),
		Vector2(1, 2),
		Vector2(-1, 2),
		Vector2(-2, 1)
	]
	
	for i in range(8):
		var valid_move = current_pos + valid_moves[i]
		if valid_move.x >= 0 and valid_move.x <= 7 and valid_move.y >= 0 and valid_move.y <= 7:
			if grid[valid_move.x][valid_move.y] == null or grid[valid_move.x][valid_move.y].color != color:
					 squares[valid_move.x][valid_move.y].mark_as_valid(grid)
