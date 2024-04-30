# Allows us to use AsteroidSize.LARGE/MEDIUM/SMALL in the game.gd
class_name Asteroid extends Area2D

signal exploded(pos, size, points)

var movement_vector := Vector2(0, -1)

enum AsteroidSize{LARGE = 0, MEDIUM = 1, SMALL = 2}
@export var size := AsteroidSize.LARGE
var speed := 50

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

# returns points depending on what asteroid is hit
var points: int:
	get:
		match size:
			AsteroidSize.LARGE:	
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 25
			_:
				return 0
func _ready():
	rotation = randf_range(0, 2*PI)
	
	# set the sprite and cshape depending on what asteroid is on screen
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50, 100)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorBrown_big4.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randf_range(100, 150)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorBrown_med1.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_med.tres"))
		AsteroidSize.SMALL:
			speed = randf_range(150, 200)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorBrown_tiny1.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_small.tres"))
			
	
# Allow for the asteroids to move in random directions
func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	# Prevents out of bounds in the y direction
	var screen_size = get_viewport_rect().size
	var radius = cshape.shape.radius
	if (global_position.y + radius) < 0:
		global_position.y = (screen_size.y + radius)
	elif (global_position.y - radius) > screen_size.y:
		global_position.y = -radius
	
	# Prevents out of bounds in the x direction
	if (global_position.x + radius) < 0:
		global_position.x = (screen_size.x + radius)
	elif (global_position.x - radius) > screen_size.x:
		global_position.x = -radius
	
# Explode if shot
func explode():
	emit_signal("exploded", global_position, size, points)
	queue_free()

# Kill player if hit
func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die()
