extends ProgressBar

var timer: Timer

func _process(_delta: float) -> void:
	if timer:
		value = 1 - timer.time_left / timer.wait_time
