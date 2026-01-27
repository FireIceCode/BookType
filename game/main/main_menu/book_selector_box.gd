extends Control

@export var book_directory : String
@export var book_title : String

@onready var title_label : Label = $HBoxContainer/Title


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_label.text = book_title


func _on_button_pressed() -> void:
	Game.set_book_directory(book_directory)
	Game.transition_typing_interface()
