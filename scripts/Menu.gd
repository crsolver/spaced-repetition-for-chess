extends CanvasLayer
signal add(color, file)
signal review(selected)
signal explore(selected)

var files = []
var selected = null
var preferences = null
var time
var file_to_delete

var deck_scene = preload("res://scenes/deckItem.tscn")

func _ready():
	time = OS.get_datetime()
	time.hour = 0
	time.minute = 0
	time.second = 0
	time = OS.get_unix_time_from_datetime(time)
	
	#si las preferencias no existen crearlas
	var file = File.new()
	if not file.file_exists("user://preferences.text"):
		file.open("user://preferences.text", File.WRITE)
		var data = {
			"maxReviews": 200,
			"easyBonus": 130,
			"intervalModifier": 100,
			"maxInterval": 36500,
			"newCards": 20,
			"graduatingInterval": 1,
			"easyInterval": 4,
			"startingEase": 250
		}
		preferences = data
		file.store_line(to_json(data))
		file.close()
	else:
		file.open("user://preferences.text", File.READ)
		preferences = parse_json(file.get_line())
		print("preference on ready")
		print(preferences)
	
	$config/CenterContainer/VBoxContainer/GridContainer/maxReviews.value = preferences.maxReviews
	$config/CenterContainer/VBoxContainer/GridContainer3/easyBonus.value = preferences.easyBonus
	$config/CenterContainer/VBoxContainer/GridContainer4/intervalModi.value = preferences.intervalModifier
	$config/CenterContainer/VBoxContainer/GridContainer5/maxInterval.value = preferences.maxInterval
	$config/CenterContainer/VBoxContainer/GridContainer6/newCards.value = preferences.newCards
	$config/CenterContainer/VBoxContainer/GridContainer7/graduatingInterval.value = preferences.graduatingInterval
	$config/CenterContainer/VBoxContainer/GridContainer8/easyInterval.value = preferences.easyInterval
	$config/CenterContainer/VBoxContainer/GridContainer9/startingEase.value = preferences.startingEase

	$CanvasLayer/CenterContainer.visible = false
	var dir = Directory.new()
	dir.make_dir("user://studies")
	dir_contents()


func _on_white_pressed():
	emit_signal("add","white", selected)


func _on_black_pressed():
	emit_signal("add", "black", selected)


func _on_create_pressed():
	$Control3.visible = true


func _on_cancel_create_pressed():
	$Control3.visible = false


func _on_create_LineEdit_text_entered(new_text):
	if new_text and files.find(new_text) == -1:
		print("saving file"+ new_text)
		save(new_text)
	else:
		print("existing file")
	$Control3/CenterContainer/VBoxContainer/HBoxContainer/create_LineEdit.text = ""


func save(name):	
	Database.insert_deck(name)
	dir_contents()
	$Control3.visible = false
	

func dir_contents():
	#get decks and info
	var children = $Control2/VBoxContainer/MarginContainer/VBoxContainer.get_children()
	for child in children:
		child.queue_free()
	
	var decks_names = Database.get_decks_names()
	print(decks_names)
	for d_name in decks_names:
		var deck = deck_scene.instance()
		deck.file_name = d_name["name"]
		deck.start()
		deck.connect("click", self, "on_file_clicked")
		deck.connect("delete_pressed", self, "delete_file")
		$Control2/VBoxContainer/MarginContainer/VBoxContainer.add_child(deck)
	
func delete_file(name):
	$DeletePopUp/CenterContainer/VBoxContainer/delete_label.text = "Are you sure you want to delete " + name + "?"
	file_to_delete = name
	$DeletePopUp.visible = true

func get_file_info(name):
	var due = 0
	var new = 0
	var save_file = File.new()
	if not save_file.file_exists("user://studies/"+name+".text"):
		return
	save_file.open("user://studies/"+name+".text", File.READ)
	var sequences = []
	while save_file.get_position() < save_file.get_len():
		sequences.append(parse_json(save_file.get_line()))
	
	var news_count = 0
	var rev_count = 0
	for i in range(sequences.size()):
		var card = sequences[i]
		if (card.mode == "new" or card.mode == "learning" or card.mode == "relearning") and news_count<preferences.newCards:
			news_count += 1

	for i in range(sequences.size()):
		var card = sequences[i]
		if card.mode == "toReview" and rev_count<preferences.maxReviews - news_count:
			if get_days_from_unix(time - card.last_review) >= card.current_interval:
				print("days passed for this card " + str(get_days_from_unix(time - card.last_review)))
				rev_count += 1
	save_file.close()
	var data = {
		"due": rev_count,
		"news": news_count
	}
	return data

func on_file_clicked(name):
	selected = name
	#selected = selected + ".save"
	$Control4/CenterContainer/VBoxContainer/review_b.disabled = false
	$Control4.visible = true
	$Control4/CenterContainer/VBoxContainer/Label.text = selected
	$Control2.visible = false
	$CenterContainer.visible = false

	#get the games with that deck and put them in the sequence array
	var sequences = Database.get_deck_cards(selected)
	
	print("initial sequences size "+ str(sequences.size()))
	
	var news_count = 0
	var rev_count = 0
	var count = 0
	#var ind = 0
	for i in range(sequences.size()):
		var card = sequences[i]
		if (card.mode == "new" or card.mode == "learning") and news_count<preferences.newCards:
			count+=1
			news_count += 1
	
	for i in range(sequences.size()):
		var card = sequences[i]
		if (card.mode == "toReview" or card.mode == "relearning") and rev_count<preferences.maxReviews - news_count:
			if get_days_from_unix(time - card.last_review) >= card.current_interval:
				count+=1
				rev_count += 1
	
	$Control4/CenterContainer/VBoxContainer/review_b.text = "Review ("+str(count)+")"
	if count == 0:
		$Control4/CenterContainer/VBoxContainer/review_b.disabled = true


func _on_add_move_pressed():
	$Control4.visible = false
	$CanvasLayer.layer = 1
	$CanvasLayer/CenterContainer.visible = true


func _on_cancel_pressed():
	$Control4.visible = false
	$Control2.visible = true
	$CenterContainer.visible = true


func _on_review_b_pressed():
	emit_signal("review", selected)


func _on_options_pressed():
	$config.visible = true


func _on_opt_save_pressed():
	preferences = {
		"maxReviews": $config/CenterContainer/VBoxContainer/GridContainer/maxReviews.value,
		"easyBonus": $config/CenterContainer/VBoxContainer/GridContainer3/easyBonus.value,
		"intervalModifier": $config/CenterContainer/VBoxContainer/GridContainer4/intervalModi.value,
		"maxInterval": $config/CenterContainer/VBoxContainer/GridContainer5/maxInterval.value,
		"newCards": $config/CenterContainer/VBoxContainer/GridContainer6/newCards.value,
		"graduatingInterval": $config/CenterContainer/VBoxContainer/GridContainer7/graduatingInterval.value,
		"easyInterval": $config/CenterContainer/VBoxContainer/GridContainer8/easyInterval.value,
		"startingEase": $config/CenterContainer/VBoxContainer/GridContainer9/startingEase.value
	}
	var save_file = File.new()
	save_file.open("user://preferences.text", File.WRITE)
	save_file.store_line(to_json(preferences))
	save_file.close()
	$config.visible = false


func _on_opt_cancel_pressed():
	$config.visible = false

func get_days_from_unix(unix):
	var days = unix / (60*60*24)
	return(days)


func _on_deleteF_pressed():
	var dir = Directory.new()
	dir.remove("user://studies/"+file_to_delete+".text")
	dir_contents()
	$DeletePopUp.visible = false


func _on_cancelDelete_pressed():
	$DeletePopUp.visible = false


func _on_save_deck_pressed():
	_on_create_LineEdit_text_entered($Control3/CenterContainer/VBoxContainer/HBoxContainer/create_LineEdit.text)


func _on_explore_button_pressed():
	print("explore pressed")
	emit_signal("explore", selected)


func _on_Button_pressed():
	get_tree().quit()
