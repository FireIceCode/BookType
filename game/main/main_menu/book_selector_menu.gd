extends MenuButton

@export var BookSelectorBox : Control

enum Menu_Buttons{
	EDIT_TITLE = 1,
	EDIT_AUTHOR = 2,
	RESET = 3,
	DELETE = 4,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_popup().connect("id_pressed", _id_pressed)


# Called when a menu button is pressed.
func _id_pressed(id: int):
	match id:
		Menu_Buttons.EDIT_TITLE:
			print("TODO")
		Menu_Buttons.EDIT_AUTHOR:
			print("TODO")
		Menu_Buttons.RESET:
			if BookSelectorBox is Control:
				var book_title = BookSelectorBox.book_title
				DirAccess.remove_absolute("user://saves/" + book_title + ".save")
				MessageService.message_info("", "Cleared " + book_title + " save data.")
				Game.transition_main_menu()
		Menu_Buttons.DELETE:
			print("TODO")
		_: # Catch other potential cases.
			printerr("Button ID not assigned")
