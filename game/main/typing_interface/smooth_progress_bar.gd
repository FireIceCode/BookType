extends ProgressBar
class_name SmoothProgressBar

@export var animation_speed: float = 4

var target_value: float = 0
var animated_value: float = 0


## Sets target progress on the SmoothProgressBar, and smoothly transitions to that value.
func set_progress(num: float) -> void:
	target_value = num


func reset_progress() -> void:
	target_value = 0
	animated_value = 0
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animated_value = lerpf(animated_value, target_value, animation_speed * delta)
	value = animated_value
