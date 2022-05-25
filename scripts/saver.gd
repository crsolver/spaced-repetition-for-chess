extends Node2D

var file_name 
var save_file
var initial
var sequence = []
var sequences = []
var color


func _ready():
	save_file = File.new()
	initial = []


func add_move(from, to, promotion):
	print("adding move")
	sequence.append({
		"from": [from.x, from.y],
		"to": [to.x, to.y],
		"promotion": null
	})
	print(sequence)


func set_initial(grid, thecolor):
	color = thecolor
	for r in range(8):
		for c in range(8):
			if grid[c][r]:
				initial.append({
					"piece": grid[c][r].id,
					"color": grid[c][r].color
				})
			else:
				initial.append(null)

func save(name):
	var file = File.new()
	file.open("user://preferences.text", File.READ)
	var preferences = parse_json(file.get_line())
	file.close()
	
	var game : Dictionary = Dictionary()
	game["name"] = name
	game["color"] = color
	game["mode"] = "new"
	game["learning_steps"] = 0
	game["ease"] = preferences.startingEase
	game["last_review"] = ""
	game["current_interval"] = 1
	game["initial"] = to_json(initial)
	game["sequence"] = to_json(sequence)
	game["deck"] = file_name

	Database.insert_game(game)
	print("move saved")
	save_file.close()
