extends RichTextLabel


@export var book_text: String = "Typing interface not connected." # Check TypingInterface
@export var untyped_color: String = "#808080"
@export var typed_color: String = "#dddddd"
@export var incorrect_color: String = "#cc8888"
@export var caret_highlight_color: String = "#509080"
@export var smooth_progress_bar: SmoothProgressBar
@export var smooth_scroll_container: SmoothScrollContainer

var character_index: int = 0
var number_incorrect: int = 0
var starting_timestamp = 0
var incorrect_list: Array[int] = []
var complete: bool = false

signal typing_complete


const vaild_characters: Array[String] = ['_', '-', '+', '=', '.', ',', ':', ';', '?', '!',
'@', '#', '$', '%', '^', '&', '*', '(', ')', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u',
'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', ' ']


func _ready() -> void:
	refresh_text()


## Restarts the current active text.
func setup_text(string: String) -> void:
	character_index = 0
	number_incorrect = 0
	incorrect_list = []
	book_text = string
	complete = false
	refresh_text()


## Takes the book text and formats it according to current index and incorrect characters.
func refresh_text() -> void:
	var display_text: String = book_text
	# Current character highlight
	if !complete:
		display_text = display_text.insert(character_index + 1, "[/bgcolor][color=" + untyped_color + "]")
		display_text = display_text.insert(character_index, "[bgcolor=" + caret_highlight_color + "]")
	# Incorrect character color
	incorrect_list.sort()
	incorrect_list.reverse()
	for index in incorrect_list:
		display_text = display_text.insert(index + 1, "[color=" + typed_color + "]")
		display_text = display_text.insert(index, "[color=" + incorrect_color + "]")
	
	display_text = display_text.insert(0, "[color=" + typed_color + "]")
	
	parse_bbcode(display_text)
	_update_scroll()


# Handle typing input, and feedback.
func _input(event: InputEvent) -> void:
	# Check for completion
	if complete == true:
		return
	
	# Ensure correct input type
	if event is InputEventKey and !event.is_echo() and !event.is_released():
		# Check for backspace
		if event.is_action("backspace"):
			character_index -= 1
			clamp(character_index, 0, -1)
			# Remove incorrect characters from list
			if incorrect_list.has(character_index):
				incorrect_list.erase(character_index)
			
			refresh_text()
			return
		
		# Get the typed character
		if event.unicode == 0:
			return
		var character: String = String.chr(event.unicode)
		
		# Test if next character needs to be validated
		if !vaild_characters.has(book_text[character_index]):
			
			# Completion check
			if character_index == book_text.length() - 1:
				complete = true
				emit_signal("typing_complete")
			
			character_index += 1
			refresh_text()
			_update_progress_bar()
			return
		else:
			if vaild_characters.has(character):
				
				# Test if character is incorrect
				if character != book_text[character_index]:
					incorrect_list.append(character_index)
					number_incorrect += 1
					
				# Completion check
				if character_index == book_text.length() - 1:
					complete = true
					emit_signal("typing_complete")
				
				character_index += 1
				refresh_text()
				_update_progress_bar()


# Move the progress bar to the correct percentage based on text completion.
func _update_progress_bar() -> void:
	if not smooth_progress_bar == null:
		smooth_progress_bar.set_progress(float(character_index) / book_text.length() * 100)


# Move scrolled area to be in a readable position.
func _update_scroll() -> void:
	if smooth_scroll_container == null:
		return
	
	var current_line: float = get_character_line(character_index)
	var max_line: float = get_line_count()
	
	var line_ratio: float = clampf((current_line / max_line * 100) - (5 / max_line * 100), 0, 100)
	smooth_scroll_container.set_progress(line_ratio)
