extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
var db_name = "res://Datastore/database.db"

func _ready():
	randomize()
	db = SQLite.new()
	db.path = db_name
	db.open_db()


func close():
	db.close_db()

func insert_game(game):
	var table_name = "Games"
	db.insert_row(table_name, game)

func insert_deck(name):
	var data : Dictionary = Dictionary()
	data["name"] = name
	var table_name = "Decks"
	db.insert_row(table_name, data)

func get_decks_names():
	db.query("SELECT name FROM Decks")
	return db.query_result

func get_deck_cards(name):
	db.query('SELECT * FROM Games WHERE deck = "' + name+ '";')
	return db.query_result

func update_card(name, mode, eas, last_review, current_interval):
	var desface = floor(current_interval * 0.2)
	if desface >= 1:
		var arr = []
		var i = -desface
		while i <=desface:
			arr.append(i)
			i+=1
		
		var slt = arr[randi() % arr.size()]
		current_interval += slt
	
	var lr = (', last_review = ' + str(last_review)) if str(last_review) != "" else ""
	var query = 'UPDATE Games SET mode = "' + str(mode) + '", ease = ' + str(eas) + lr + ', current_interval = ' + str(current_interval) + ' WHERE name = "'+name+'"'
	print(query)
	db.query(query)
