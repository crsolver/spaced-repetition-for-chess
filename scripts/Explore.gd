extends Node2D
signal menu

var file_name
var sequences = []
var card_scene = preload("res://scenes/cardItem.tscn")
var selected = null
onready var list = $CanvasLayer/Control/VBoxContainer2/VBoxContainer/Container/list

# Called when the node enters the scene tree for the first time.
func _ready():
	load_data()
	center()
	get_tree().get_root().connect("size_changed", self, "center")
	$game.start()
	
func center():
	$game.position.x = get_viewport().size.x/2 - (40*8)/2
	$game.position.y = get_viewport().size.y/3.4 - (40*8)/2 #5
	#$game.position.y = 30


func load_data():
	sequences = Database.get_deck_cards(file_name)
	print(file_name + " cards get")
	for i in range(sequences.size()):
		var data = sequences[i]
		#FIX
		data.initial = parse_json(data.initial)
		data.sequence = parse_json(data.sequence)
		
		var card = card_scene.instance()
		card.file_name = data.name
		card.interval = data.current_interval
		card.ease_porcentage = data.ease
		card.connect("clicked", self, "on_card_clicked")
		list.add_child(card)


func on_card_clicked(card_name):
	selected = card_name
	print("signal came: " + card_name)
	var index = 0
	for i in range(sequences.size()):
		if sequences[i].name == card_name:
			index = i
			break
	$game.mode = "review"
	$game.automatic = true
	#$game.connect("card_finished", self, "on_card_finished")
	$game.point_of_view = sequences[index]["color"]
	$game.turn = sequences[index]["color"]
	$game.sequence = sequences[index]["sequence"]
	$game.start()
	$game.set_initial(sequences[index]["initial"])


func _on_Button_pressed():
	emit_signal("menu")


func _on_move_pressed():
	if selected:
		$game.move()
