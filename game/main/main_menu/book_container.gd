extends VBoxContainer


var book_selector_box = preload("res://game/main/main_menu/book_selector_box.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_books()


func load_books() -> void:
	# Clear old children
	for child in self.get_children():
		child.queue_free()
	
	# Find custom books
	var dirs: PackedStringArray = DirAccess.get_directories_at("user://books/custom")
	for i : int in range(dirs.size()):
		dirs[i] = "user://books/custom/" + dirs[i]
	_create_child_book_selector_boxes(dirs)
	
	dirs = DirAccess.get_directories_at("user://books/builtin")
	for i: int in range(dirs.size()):
		dirs[i] = "user://books/builtin/" + dirs[i]
	_create_child_book_selector_boxes(dirs)


# Takes in a list of folders, and gets the metadata of the book from the metadata.json file.
func _create_child_book_selector_boxes(directories : PackedStringArray) -> void:
	# Ensure correct format.
	var metadatas: Array[Dictionary]
	for dir : String in directories:
		if FileAccess.file_exists(dir + "/metadata.json"):
			var json_string =  FileAccess.get_file_as_string(dir + "/metadata.json")
			var metadata: Dictionary = JSON.parse_string(json_string)
			metadata.set("directory", dir)
			metadatas.append(metadata)
		else:
			printerr("Book metadata not found!")
	
	
	# Load title and other relevant information into book selector box
	for metadata: Dictionary in metadatas:
		var child = book_selector_box.instantiate()
		
		# Metadata loading
		child.book_directory = metadata.get("directory", "user://books/builtin/ArtofWar")
		child.book_title = metadata.get("title", "Title metadata not found!")
		child.max_pages = maxi(1, metadata.get("pages", 1)) # Max ensures > 0
		
		# Get save data
		var save: Dictionary
		var json_string: String = FileAccess.get_file_as_string("user://saves/" + metadata.get("title") + ".save")
		if not json_string == "":
			save = JSON.parse_string(json_string)
		var page = save.get("page", 0)
		
		# Load save data
		child.complete = save.get("complete", false)
		child.current_page = page
		
		if page == 0:
			child.button_text = "Start"
		else:
			child.button_text = "Resume"
		
		self.add_child(child)
