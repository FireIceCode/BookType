extends Node

enum Scene {MAIN_MENU, TYPING_INTERFACE}

@onready var scene_node: Control
@onready var animation_player: AnimationPlayer

var transitioning: bool = false

# Active book data
var book_page: int = 0
var book_directory: String = "user://books/builtin/ArtOfWar"
var book_metadata: Dictionary = {
	"title": "Art of War",
	"pages": 1,
	"author": "Sun Tzu"
}



# ----- Public Functions ----- #

## Transitions to main menu scene
func transition_main_menu() -> void:
	_transition_scene(Scene.MAIN_MENU)

## Transitions to typing interface
func transition_typing_interface() -> void:
	_transition_scene(Scene.TYPING_INTERFACE)

## Directory in which the metadata file, and the page texts exists.
func set_book_directory(dir: String) -> void:
	if FileAccess.file_exists(dir + "/metadata.json"):
		var json_string: String = FileAccess.get_file_as_string(dir + "/metadata.json")
		book_metadata = JSON.parse_string(json_string)
		book_directory = dir



# ----- Private Functions ----- #

## Called on game startup
func _ready() -> void:
	_create_directory()
	await _get_scene_manager()
	await _get_animation_player()

## Creates the main folders, and copies the built in files to the builtin folder
func _create_directory() -> void:
	# Main directory setup
	if DirAccess.dir_exists_absolute("user://books"):
		print("Book Directory found")
	else:
		DirAccess.make_dir_recursive_absolute("user://books/custom")
		print("Main directory created.")
	
	# Copy buit in books.
	DirAccess.make_dir_recursive_absolute("user://books/builtin")
	var files = DirAccess.get_files_at("res://books_builtin/")
	for file in files:
		DirAccess.copy_absolute("res://books_builtin/" + file, "user://books/builtin/" + file)
	print("Copy complete.")

## Use await keyword to continue code after supplied seconds
func _timer(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

## Gets the scence manager node
func _get_scene_manager() -> void:
	while true:
		scene_node = get_tree().get_first_node_in_group("scene_manager")	
		if scene_node is Control:
			break
		else:
			print("Scene Manager node not found! (retrying)")
			await _timer(0.1)

## Gets the scene animation player
func _get_animation_player() -> void:
	while true:
		animation_player = get_tree().get_first_node_in_group("scene_animation_player")	
		if animation_player is AnimationPlayer:
			break
		else:
			print("Animation Player not found! (retrying)")
			await _timer(0.1)

## Transitions to the requested scene with a short blackout animation.
func _transition_scene(scene: int) -> void:
	# Check for valid scene
	assert(scene in Scene.values(), "Scene must match with a scene in the Scene enum.")
	
	if transitioning:
		printerr("Already transitioning!")
		return
	transitioning = true
	
	# Transition animation
	animation_player.play("blackout")
	await animation_player.animation_finished
	
	# Clear children
	for child in scene_node.get_children():
		child.queue_free()
	
	# Load correct scene
	var child: Node
	match scene:
		Scene.MAIN_MENU:
			child = load("res://game/main/main_menu/main_menu.tscn").instantiate()
		Scene.TYPING_INTERFACE:
			child = load("res://game/main/typing_interface/typing_interface.tscn").instantiate()
			child.book_title = book_metadata.get("title", "Title not found - Invalid metadata?")
			child.page_number = str(book_page + 1)
			child.page_text = _get_current_book_page_text()
			
	scene_node.add_child(child)
	animation_player.play("clear")
	
	await animation_player.animation_finished
	transitioning = false


func _get_current_book_page_text() -> String:
	var page_path: String = book_directory + "/" + str(book_page) + ".txt"
	if not FileAccess.file_exists(page_path):
		return "Page not found."
	
	var text: String = FileAccess.get_file_as_string(page_path)
	
	if text == null:
		printerr(page_path + " returned null")
		return "File access error!"
	return text
