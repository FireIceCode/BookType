extends Panel
class_name SmoothCaret

@export var animation_speed: float = 25

var target_value: Vector2 = Vector2.ZERO
var animated_value: Vector2 = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animated_value = lerp(animated_value, target_value, animation_speed * delta)
	position = animated_value


## Sets target position on the SmoothCaret, and smoothly transitions to that value.
func set_target_position(num: Vector2) -> void:
	target_value = num


## Instantly returns the caret to 0,0 with no animation.
func reset_position() -> void:
	animated_value = Vector2.ZERO
	target_value = Vector2.ZERO


## Changes the color of the caret.
func set_color(color: Color) -> void:
	self.modulate = color
	
