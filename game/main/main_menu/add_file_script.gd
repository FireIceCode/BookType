extends Button

@onready var file_dialog : FileDialog = $FileDialog


func _on_pressed() -> void:
	file_dialog.visible = true
