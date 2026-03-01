extends Node

enum Scene {MAIN_MENU, TYPING_INTERFACE}

@onready var scene_node: Control
@onready var animation_player: AnimationPlayer

var transitioning: bool = false

# Active book data
var book_directory: String = "user://books/builtin/Art of War"
var book_metadata: Dictionary = {
	"title": "Art of War",
	"pages": 0,
	"author": "Sun Tzu",
}
var book_page: int = 0
var page_WPM: float = 0.0


## Called on game startup
func _ready() -> void:
	_create_directory()
	await _get_scene_manager()
	await _get_animation_player()


## Transitions to main menu scene
func transition_main_menu() -> void:
	_transition_scene(Scene.MAIN_MENU)


## Transitions to typing interface
func transition_typing_interface() -> void:
	_transition_scene(Scene.TYPING_INTERFACE)


## Sets up the requested book, using the directory in which the metadata file, and the page texts exists.
func set_book(dir: String) -> void:
	if FileAccess.file_exists(dir + "/metadata.json"):
		var json_string: String = FileAccess.get_file_as_string(dir + "/metadata.json")
		book_metadata = JSON.parse_string(json_string)
		book_directory = dir
		var save_file: String = "user://saves/" + book_metadata.get("title") + ".save"
		if FileAccess.file_exists(save_file):
			var save: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(save_file))
			book_page = save.get("page", 0) #-1 ensures a completed book will start on page 0.
		else:
			book_page = 0


## Creates the main folders, and copies the built in files to the builtin folder
func _create_directory() -> void:
	# Main directory setup
	if DirAccess.dir_exists_absolute("user://books/custom"):
		print("Book Directory found!")
	else:
		DirAccess.make_dir_recursive_absolute("user://books/custom")
		print("Main directory created.")
	
	# Saves directory setup
	if DirAccess.dir_exists_absolute("user://saves"):
		print("Saves Directory found!")
	else:
		DirAccess.make_dir_absolute("user://saves")
		print("Saves directory created.")
	
	# Copy buit in books.
	DirAccess.make_dir_recursive_absolute("user://books/builtin")
	var dirs = DirAccess.get_directories_at("res://books_builtin/")
	for dir in dirs:
		DirAccess.make_dir_recursive_absolute("user://books/builtin/" + dir)
		var files = DirAccess.get_files_at("res://books_builtin/" + dir)
		for file in files:
			DirAccess.copy_absolute("res://books_builtin/" + dir + "/" + file, "user://books/builtin/" + dir + "/" + file)
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
			child.page_number = book_page
			child.max_page_number = book_metadata.get("pages", 0)
			child.page_text = _get_current_book_page_text()
			if child.has_signal("page_complete"):
				child.connect("page_complete", _page_complete)
			
	scene_node.add_child(child)
	animation_player.play("clear")
	
	await animation_player.animation_finished
	transitioning = false


## Returns the text of the currently selected book and page.
func _get_current_book_page_text() -> String:
	var page_path: String = book_directory + "/" + str(book_page) + ".txt"
	if not FileAccess.file_exists(page_path):
		return "Page not found."
	
	var text: String = FileAccess.get_file_as_string(page_path)
	
	if text == null:
		printerr(page_path + " returned null")
		return "File access error!"
	return text


## Marks the current page as finished, and transitions to the next page.
func _set_next_page() -> void:
	book_page += 1
	book_page = clampi(book_page, 0, book_metadata.get("pages", 0))
	# Get typing interface
	var typing_interface: TypingInterface = scene_node.get_child(0)
	if not typing_interface is TypingInterface:
		printerr("Typing interface not found!")
		return
	# Update typing interface
	var page_text: String = _get_current_book_page_text()
	typing_interface.page_number = book_page
	typing_interface.page_text = page_text
	typing_interface.setup_book()


func _page_complete(WPM: int = 0, incorrect: int = 0) -> void:
	_save_book_progress(WPM, incorrect)
	# Completion Check
	if book_page >= book_metadata.get("pages", 0):
		transition_main_menu()
		MessageService.message_success(book_metadata.get("title", "BookType"), "Book Completed! You're book has become gold.")
	else:
		_set_next_page()


func _save_book_progress(WPM: int = 0, incorrect: int = 0) -> void:
	var save: Dictionary
	var filepath = "user://saves/" + book_metadata.get("title") + ".save"
	# Check for existing file
	if FileAccess.file_exists(filepath):
		var json: String = FileAccess.get_file_as_string(filepath)
		save = JSON.parse_string(json)
	
	# Book completion check
	if book_page >= book_metadata.get("pages", 0): # Book complete
		save.set("complete", true)
		save.erase("page")
	else: # Book not complete
		save.set("page", book_page + 1)
	
	# Page data
	var page_data: Dictionary = {
		"incorrect" : incorrect,
		"WPM" : WPM,
	}
	save.set("page" + str(book_page), page_data)
	
	# Save data
	var json_string: String = JSON.stringify(save)
	FileAccess.open(filepath, FileAccess.WRITE).store_string(json_string)
	
