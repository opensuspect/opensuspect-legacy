extends Polygon2D

func _on_gasvalve_updateGauge(value):
	self.position.y = clamp(200 - int(value*200), 0, 200)
