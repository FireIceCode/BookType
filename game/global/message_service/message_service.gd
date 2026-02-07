extends Control
class_name MessageController

@export var container : VBoxContainer
@export var message_duration: float = 3

enum Style {
	INFO = 0,
	SUCCESS = 1,
	WARN = 2,
	ERROR = 3,
}


## Sends a temporary info message.
func message_info(title: String, body: String) -> void:
	_display_message(title, body, 0)


## Sends a temporary success message.
func message_success(title: String, body: String) -> void:
	_display_message(title, body, 1)


## Sends a temporary warning message.
func message_warn(title: String, body: String) -> void:
	_display_message(title, body, 2)


## Sends a temporary error message.
func message_error(title: String, body: String) -> void:
	_display_message(title, body, 3)



func _display_message(title: String, body: String, style: int = 0) -> void:
	var message_box: MessageBox = preload("res://game/global/message_service/message_box.tscn").instantiate()
	message_box.set_message(title, body, style)
	
	container.add_child(message_box)
	container.move_child(message_box, 0)
	
	await _timer(message_duration)
	message_box.fade_out()


func _timer(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
