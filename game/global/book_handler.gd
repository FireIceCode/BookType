extends Node

@export var max_page_length: int = 750


var terminating_characters: PackedStringArray = [" ", ".", ",", "
"]
var allowed_characters: String = "`1234567890-=~!@#$%^&*()_+qwertyuiop[]\\QWERTYUIOP}{|asdfghjkl;'ASDFGHJKL:\"zxcvbnm,./ZXCVBNM<>? 
"


## Creates a directory containing metadata and pages from a txt file and title.
func register_book(file_path_txt: String, book_title: String) -> void:
	var book_text: String = FileAccess.get_file_as_string(file_path_txt)
	if book_text == null:
		printerr("Unable to parse the provided file.")
		return
	book_text = _clean_text(book_text)
	
	# Prep directory
	var dir: String = "user://books/custom/" + book_title + "/"
	DirAccess.make_dir_recursive_absolute(dir)
	
	# Divide book into pages based on the max_page_length, ending on a whole word.
	var text_index = 0
	var page_index: int = 0
	while true:
		var page_len: int = max_page_length
		# Check begining for terminating character
		for i in range(10):
			if not text_index + 1 >= book_text.length(): # Ensure in String bounds
				if terminating_characters.has(book_text[text_index]):
					text_index += 1
				else:
					break
			else:
				break
		# Check ending for terminating character
		if not text_index + page_len + 1 > book_text.length(): # Ensure in String bounds
			for i in range(10):
				if terminating_characters.has(book_text[text_index + page_len]):
					page_len += 1
					break
				else:
					page_len -= 1
		else:
			_create_page(dir, page_index, book_text.substr(text_index, page_len))
			break
		_create_page(dir, page_index, book_text.substr(text_index, page_len))
		page_index += 1
		text_index += page_len
	
	# Create metadata JSON
	var metadata: Dictionary = {
		"version": 1,
		"title": book_title,
		"pages": page_index,
		"author":"",
	}
	var json_str: String = JSON.stringify(metadata)
	FileAccess.open(dir + "metadata.json", FileAccess.WRITE).store_string(json_str)


# Adds a page into the specified directory with the specified text
func _create_page(dir_path: String, page_index: int, page_text: String) -> void:
	var page: FileAccess = FileAccess.open(dir_path + str(page_index) + ".txt", FileAccess.WRITE)
	page.store_string(page_text)

# Removes dissalowed characters from provided text.
func _clean_text(text: String) -> String:
	var index = 0
	var length = text.length()
	while true:
		index += 1
		if index >= length:
			return text
		if not text[index] in allowed_characters:
			text = text.remove_chars(text[index])
			print(text[index])
			length = text.length()
	return text
