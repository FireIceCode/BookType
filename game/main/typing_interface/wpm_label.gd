extends Label

@export var UPDATE_INTERVAL: int = 1000
@export var typing_controler: TypingControler

var last_update: int = 0


func _physics_process(_delta: float) -> void:
	var time = Time.get_ticks_msec()
	
	# Update Interval check
	if time >= last_update + UPDATE_INTERVAL:
		last_update = time
		
		var WPM = typing_controler.get_wpm()
		text = str(snapped(WPM, 1)) + " WMP" # Display Text
