extends Area2D

# Laser variables
@export var speed := 500.0
var movement_vector := Vector2(0, -1)

# function to handle laser movement
func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta

# Makes sure to delete lasers when they exit screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()
