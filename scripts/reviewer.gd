extends Node2D
signal menu

var save_file
var file_name = ""
var initial
var sequences = []
var sequence = []
var color
var index = 0
var preferences
var time
var indexes_to_review = []
var good_int = 0


func _ready():
	randomize()
	center()
	get_tree().get_root().connect("size_changed", self, "center")
	$center/game.mode = "review"
	#load_game()
	$center/game/AnimationPlayer.play("fadein")
	var file = File.new()
	file.open("user://preferences.text", File.READ)
	preferences = parse_json(file.get_line())
	file.close()
	
	time = OS.get_datetime()
	var day = time.day
	time.hour = 0
	time.minute = 0
	time.second = 0
	print(time)
	time = OS.get_unix_time_from_datetime(time)

func center():
	$center.position.x = get_viewport().size.x/2 - (50*8)/2
	$center.position.y = get_viewport().size.y/2 - (50*8)/2 #5
	$center.position.y -= 30


func load_game():
	read_cards()
	print("file loaded")
	print("CURRENT INDEX " + str(index))
	print("size " +str(sequences.size()))
	$center/game.pause = false
	$center/game.connect("card_finished", self, "on_card_finished")
	$center/game.point_of_view = sequences[index]["color"]
	$center/game.turn = sequences[index]["color"]
	$center/game.sequence = sequences[index]["sequence"]
	$CanvasLayer/Control2/CenterContainer/Label_name.text = sequences[index]["name"]
	$center/game.start()
	$center/game.set_initial(sequences[index]["initial"])

func read_cards():
	sequences = Database.get_deck_cards(file_name)
	print("initial sequences size "+ str(sequences.size()))
	
	var news_count = 0
	var rev_count = 0
	#var ind = 0
	for i in range(sequences.size()):
		print("i loop = " +str(i))
		var card = sequences[i]
		card.initial = parse_json(card.initial)
		card.sequence = parse_json(card.sequence)
		if (card.mode == "new" or card.mode == "learning") and news_count<preferences.newCards:
			indexes_to_review.append(i)
			print("new appeded")
			news_count += 1
	
	for i in range(sequences.size()):
		var card = sequences[i]
		if (card.mode == "toReview" or card.mode == "relearning") and rev_count<preferences.maxReviews - news_count:
			if get_days_from_unix(time - card.last_review) >= card.current_interval:
				print("days passed for this card " + str(get_days_from_unix(time - card.last_review)))
				indexes_to_review.append(i)
				rev_count += 1
	print("size of indexes " + str(indexes_to_review.size()))
	next_card()


func on_card_finished():
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/hard.disabled = false
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/easy.disabled = false
	var again = "<1m"
	var hard = ""
	var good = "<10m"
	var easy = str(preferences.easyInterval)+"d"
	var good_int = 0
	
	var card = sequences[index]
	print("card ease: " + str(card.ease))
	print("card mode: " + card.mode)
	#print("card date: " + str(OS.get_datetime_from_unix_time(card.last_review)))
	if card.mode == "new":
		good = "<10m"
	elif card.mode == "learning":
		good = str(preferences.graduatingInterval) + "d"
	elif card.mode == "relearning":
		good = str(preferences.graduatingInterval) + "d"
		$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/easy.disabled = true
	elif card.mode == "toReview":
		good = floor(card.current_interval * (card.ease/100)*(preferences.intervalModifier/100))
		good_int = good
		if good >= 30:
			good = good/30
			good = str("%.1f" % good)+"mo"
		else:
			good = str(good) + "d"
		hard = floor(card.current_interval * 1.2 *(preferences.intervalModifier/100))
		if hard >= 30:
			hard = hard/30
			hard = str("%.1f" % hard)+"mo"
		else:
			hard = str(hard) + "d"
		easy = floor(card.current_interval * (card.ease/100)*(preferences.intervalModifier/100)*(preferences.easyBonus/100))
		if easy == good_int:
			easy += 1
		if easy >= 30:
			easy = easy/30
			easy = str("%.1f" % easy)+"mo"
		else:
			easy = str(easy) + "d"
	
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/labelagain.text = str(again)
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/labelhard.text = str(hard)
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/labelgood.text = str(good)
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/labeleasy.text = str(easy)
	
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/hard.disabled = hard == ""
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons/easy.disabled = easy == ""
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons.visible = true

func next_card():
	print("133 seqyebces " + str(sequences.size()))
	if indexes_to_review.size() > 0:
		index = indexes_to_review[randi() % indexes_to_review.size()]
		print("indexes " + str(indexes_to_review))
		print("sequences  "+ str(sequences.size()))
		print("selected index: " + str(index))
		print("indexes_to_rveiw size "+ str(indexes_to_review.size()))
		$center/game.point_of_view = sequences[index]["color"]
		$center/game.turn = sequences[index]["color"]
		$center/game.sequence = sequences[index]["sequence"]
		$center/game.start()
		$center/game.set_initial(sequences[index]["initial"])
		$CanvasLayer/Control2/CenterContainer/Label_name.text = sequences[index]["name"]
		$center/game/AnimationPlayer.play("fadein")
		$center/game.pause = false
	else:
		$CanvasLayer/end.visible = true


func _on_Button_pressed():
	emit_signal("menu")
	#$center/game.start()


func _on_reset_pressed():
	$center/game.turn = sequences[index]["color"]
	$center/game.start()
	$center/game.set_initial(sequences[index]["initial"])


func _on_again_pressed():
	print("173 seqyebces " + str(sequences.size()))
	var card = sequences[index]
	
	if card.mode == "toReview":
		card.mode = "relearning"
		var new_ease = card.ease - (card.ease * 0.20)
		if new_ease >= 130:
			card.ease = new_ease
		else:
			card.ease = 130
	print("184 seqyebces " + str(sequences.size()))
	var copy = [] + sequences
	Database.update_card(card.name, card.mode, card.ease, card.last_review, card.current_interval)
	sequences = copy
	#_on_reset_pressed()
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons.visible = false
	next_card()


func _on_hard_pressed():
	var card = sequences[index]
	card.last_review = time
	card.mode = "toReview"
	indexes_to_review.erase(index)
	
	var new_interval = floor(card.current_interval * 1.2 *(preferences.intervalModifier/100))
	if new_interval <= preferences.maxInterval:
		card.current_interval = new_interval
	var new_ease = card.ease - (card.ease * 0.15)
	if new_ease >= 130:
		card.ease = new_ease
	else:
		card.ease = 130
	
	var copy = [] + sequences
	Database.update_card(card.name, card.mode, card.ease, card.last_review, card.current_interval)
	sequences = copy
	
	#_on_reset_pressed()
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons.visible = false
	next_card()


func _on_good_pressed():
	var card = sequences[index]
	
	if card.mode == "new":
		card.mode = "learning"
	elif card.mode == "learning" or card.mode == "relearning":
		card.mode = "toReview"
		card.last_review = time
		card.current_interval = floor(preferences.graduatingInterval)
		indexes_to_review.erase(index)
	elif card.mode == "toReview":
		card.last_review = time
		indexes_to_review.erase(index)
		var new_interval = floor(card.current_interval * (card.ease/100)*(preferences.intervalModifier/100))
		if new_interval <= preferences.maxInterval:
			card.current_interval = new_interval
			
	var copy = [] + sequences
	Database.update_card(card.name, card.mode, card.ease, card.last_review, card.current_interval)
	sequences = copy
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons.visible = false
	#temporal
	#_on_reset_pressed()
	next_card()


func _on_easy_pressed():
	var card = sequences[index]
	indexes_to_review.erase(index)
	card.last_review = time
	if card.mode != "toReview":
		card.mode = "toReview"
		card.current_interval = 4
	else:
		print("ajusting ease")
		var new_interval = floor(card.current_interval * (card.ease/100)*(preferences.intervalModifier/100)*(preferences.easyBonus/100))
		if new_interval == good_int:
			new_interval += 1
		if new_interval <= preferences.maxInterval:
			card.current_interval = new_interval
	var new_ease = card.ease + (card.ease * 0.15)
	if new_ease < 1000:
		card.ease = new_ease
		print("new ease:" +str(card.ease))
	
	var copy = [] + sequences
	Database.update_card(card.name, card.mode, card.ease, card.last_review, card.current_interval)
	sequences = copy
	#_on_reset_pressed()
	$CanvasLayer/Control/VBoxContainer/CenterContainer/VBoxContainer/evaluationButtons.visible = false
	next_card()

# 4000 + 6000 = 10 000
# 5000

func get_days_from_unix(unix):
	var days = unix / (60*60*24)
	return(days)

func _on_endbutton_pressed():
	emit_signal("menu")
