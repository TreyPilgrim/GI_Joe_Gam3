class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

# Movement Variables
@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0


# Shooting/Muzzle Variables
@onready var muzzle = $Muzzle
var laser_scene = preload("res://scenes/laser.tscn")
var shoot_cd = false
var rate_of_fire = 0.15

# Death Variables
@onready var cshape = $CollisionShape2D
@onready var sprite = $Sprite2D
var alive := true
	
func _process(delta):
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false
		
func _physics_process(delta):
	if !alive: return # don't allow user to move if dead
	# Handle movement
	var input_vector := Vector2(0, Input.get_axis("move_forward", "move_backward")) 
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	# Handle roation
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
		
	# give a floaty effect (doesn't make player come to sudden stop)
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 4)
	move_and_slide()
	
	# Prevents out of bounds in the y direction
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	
	# Prevents out of bounds in the x direction
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

# Logic for shooting
func shoot_laser():
	if !alive: return
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position 
	l.rotation = rotation
	emit_signal("laser_shot", l)

# logic for dying
func die():
	if alive == true:
		alive = false 
		# Hide the sprite and don't take damage while dead
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		emit_signal("died")

# Logic for respawning
func respawn(pos):
	if alive == false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		cshape.set_deferred("disabled", false)



