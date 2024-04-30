extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea


var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives = 3:
	set(value):
		lives = value
		hud.init_lives(lives) #tell the HUD how many lives to display

func _ready():
	game_over_screen.visible = false
	score = 0
	lives = 3
	# Connect the laser to the player
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	 # connect the funtionality for getting hit w/ laser to all asteroids
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
	
func _process(delta):
	if Input.is_action_just_pressed("reset"): # Press r to refresh game
		get_tree().reload_current_scene()
		
func _on_player_laser_shot(laser): # spawn laser when shooting
	$LaserSound.play()
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size, points):
	$AsteroidHitSound.play()
	score += points 
	for i in range(2):
		# When asteroid is destroyed, spawn smaller descendant until fully destroyed
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, size + 1)
			Asteroid.AsteroidSize.SMALL:
				pass
	print(score)

func spawn_asteroid(pos, size): # spawn asteroid after an explosion
	
	# Set the data for the astroid (position, size), connext the exploding function then add it to memory
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
	
# Function for when player dies
func _on_player_died():
	$PlayerDieSound.play()
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	if lives <= 0: # wait 2 seconds before letting player know game is over
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty: #while an asteroid is in safe spawn, don't spawn
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_pos.global_position)
