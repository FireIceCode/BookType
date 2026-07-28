extends FileDialog
@onready var book_container: VBoxContainer = %BookContainer


func _on_file_selected(path: String) -> void:
	if path.get_extension() == "txt":
		var book_name: String = path.get_file().trim_suffix(".txt")
		BookHandler.register_book(path, book_name)
		
		if not book_container == null:
			book_container.load_books()
