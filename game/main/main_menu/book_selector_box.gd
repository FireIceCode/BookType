extends Control

@export var book_directory: String
@export var book_title: String
@export var button_text: String
@export var complete: bool = false

@onready var title_label: Label = $HBoxContainer/Title
@onready var button: Button = $HBoxContainer/MarginContainer/Button



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_label.text = book_title
	if complete:
		title_label.modulate = Color("e4c275ff")
	button.text = button_text


func _on_button_pressed() -> void:
	Game.set_book(book_directory)
	Game.transition_typing_interface()
