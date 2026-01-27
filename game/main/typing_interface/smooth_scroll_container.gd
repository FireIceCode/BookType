extends ScrollContainer
class_name SmoothScrollContainer

@export var animation_speed: float = 5

var target_value: float = 0
var animated_value: float = 0


## Sets target progress on the SmoothProgressBar, and smoothly transitions to that value.
func set_progress(num: float) -> void:
	target_value = num


func reset_progress() -> void:
	animated_value = 0
	target_value = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animated_value = lerpf(animated_value, target_value, animation_speed * delta)
	scroll_vertical = _scroll_percent_pixels(animated_value)


# Convert scroll percent to direct scroll value
func _scroll_percent_pixels(percent: float) -> int:
	var scroll_bar: VScrollBar = get_v_scroll_bar()
	percent = percent / 100 # Convert to decimal percent
	
	if not scroll_bar == null:
		var pixels: int = int(scroll_bar.max_value * percent)
		return pixels
	return 0
