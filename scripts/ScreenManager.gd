extends Node2D

var minX = 510
var minY = 560

var menu_scene = preload("res://scenes/Menu.tscn")
var main_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root").connect("size_changed", self, "resize")
	var main_menu = menu_scene.instance()
	main_menu.connect("add", self, "add_moves_of_color")
	main_menu.connect("review", self, "review")
	main_menu.connect("explore", self, "load_explore")
	$currentScene.add_child(main_menu)


func load_explore(file_name):
	print("loading " + file_name)
	var explore = load("res://scenes/Explore.tscn").instance()
	explore.connect("menu", self, "main_menu")
	explore.file_name = file_name
	$currentScene.get_child(0).queue_free()
	$currentScene.add_child(explore)


func add_moves_of_color(color, selected):
	var game = load("res://scenes/add_moves.tscn").instance()
	game.connect("main_menu", self, "main_menu")
	game.point_of_view = color
	game.file_name = selected
	$currentScene.get_child(0).queue_free()
	$currentScene.add_child(game)


func review(selected):
	print("review " + selected)
	var game = load("res://scenes/reviewer.tscn").instance()
	game.file_name = selected
	game.connect("menu", self, "main_menu")
	$currentScene.get_child(0).queue_free()
	$currentScene.add_child(game)
	game.load_game()


func main_menu():
	var main_menu = menu_scene.instance()
	main_menu.connect("add", self, "add_moves_of_color")
	main_menu.connect("review", self, "review")
	main_menu.connect("explore", self, "load_explore")
	$currentScene.get_child(0).queue_free()
	$currentScene.add_child(main_menu)


func resize():
	var currentSize = OS.get_window_size()

	if(currentSize.x < minX):
		OS.set_window_size(Vector2(minX, currentSize.y))

	if(currentSize.y < minY):
		OS.set_window_size(Vector2(currentSize.x, minY))
