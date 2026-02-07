extends Node

class_name MessageBox

@export var title_label: Label
@export var body_label: Label
@export var panel: PanelContainer
@export var fade_speed: int = 5

var fading: bool = false
var fade: float = 0.8


# Called every frame
func _process(delta: float) -> void:
	if fading == true:
		fade -= delta * fade_speed
		self.modulate = Color(1, 1, 1, fade)
		if fade <= 0:
			self.queue_free()


## Sets the message contents and style. INFO=0, SUCCESS=1, WARN=2, ERROR=3
func set_message(title: String, body: String, style: int = 0) -> void:
	match style:
		0: # INFO
			_set_stylebox_border_color(Color("#6a6a6a"))
		1: # SUCCESS
			_set_stylebox_border_color(Color("#79a271"))
		2: # WARN
			_set_stylebox_border_color(Color("c9ab5fff"))
		3: # ERROR
			_set_stylebox_border_color(Color(0.822, 0.383, 0.313, 1.0))
	
	if title == "":
		title_label.queue_free()
	else:
		title_label.text = title
	
	if body == "":
		body_label.queue_free()
	else:
		body_label.text = body


## Fades out the message over the specified duration, then calls queue_free() on self.
func fade_out() -> void:
	fading = true


func _set_stylebox_border_color(color: Color) -> void:
	var style_box: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	style_box.set("border_color", color)
	panel.add_theme_stylebox_override("panel", style_box)
