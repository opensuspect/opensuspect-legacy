extends Camera2D

var zoom_speed = 0.2
var max_zoom = 0.2
var min_zoom = 2
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == 5: # Scroll Down
				if $".".zoom.x < min_zoom: #check to not zoom out too far
					$".".zoom.x += zoom_speed
					$".".zoom.y += zoom_speed

			if event.button_index == 4: # Scroll Up
				if $".".zoom.x > max_zoom: #check to not zoom in too close
					$".".zoom.x -= zoom_speed
					$".".zoom.y -= zoom_speed
