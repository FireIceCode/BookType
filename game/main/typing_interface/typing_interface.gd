extends Control


@onready var title_node : Label = $VBoxContainer/Topbar/VBoxContainer/HBoxContainer/TitleLabel
@onready var page_label : Label = $VBoxContainer/Topbar/VBoxContainer/HBoxContainer/PageLabelMarginContainer/PageLabel
@onready var main_textbox : RichTextLabel = $VBoxContainer/Body/HBoxContainer/SmoothScrollContainer/TypingLabel


@export var book_title : String = "Title Undefined"
@export var page_text : String = "Undefined Text"
@export var page_number : int = 1
@export var max_page_number : int = 1

signal typing_complete(page_number: int)


func _ready() -> void:
	main_textbox.connect("typing_complete", _page_complete)
	setup_book()


func setup_book() -> void:
	title_node.text = book_title
	main_textbox.setup_text(page_text)
	page_label.text = str(page_number) + "/" + str(max_page_number)


func _page_complete():
	emit_signal("typing_complete", page_number)
	print("page " + str(page_number) + " complete.")
