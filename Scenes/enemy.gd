extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
#@onready var death_plane: Area2D = $"../Death Plane"
@onready var player: CharacterBody2D = $"../Player"
@onready var world: Node2D = get_tree().root.get_node("World")
@onready var navigation_agent = $NavigationAgent2D

@export var MAX_SPEED := 150
@export var JUMP_VELOCITY := -350



var SPEED = 100
var ACCELERATION = 100
var CLIMB_SPEED = 200.0
var lastX = 0
var lastY = 0
var climbing: bool
var game_paused = false
var animation_finished = null

func _ready() -> void:
	randomize()
	

func flip(direction):
	if direction == -1:
		return true
	else:
		return false

func _physics_process(delta: float) -> void:
	navigation_agent.target_position = player.position
	if world.enable_enemy_pathfinding:
		var next_path_position = navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(next_path_position)
		
		if player.position.x == position.x or player.position.y < position.y-50:
			pass
		
		if Input.is_action_pressed("pause"):
			game_paused = not game_paused
		

		# Add the gravity.
		if not is_on_floor() and not game_paused:
			velocity += get_gravity() * delta

		# Handles respawn/ restart
		if Input.is_action_just_pressed("restart"):
			velocity = Vector2(0, 0)
			death('respawn')

		# Get the input direction and handle the movement/deceleration.
		if velocity and not game_paused: # Adjust the threshold (0.1) as needed:
			#$AnimatedSprite2D.flip_h = flip(direction)
			
			velocity = direction * SPEED
			
			
			if not game_paused:
				anim.pause()
				anim.play("Walk")
		
		else:
			if not game_paused: velocity.x = move_toward(velocity.x, 0, SPEED)
			if not game_paused:
				anim.pause()
				anim.play("Idle")

		if not game_paused and navigation_agent.is_navigation_finished():
			move_and_slide()
			return
		if Input.is_action_just_pressed("quit"): get_tree().quit()
	else:
		# Stop enemy movement if pathfinding is disabled
		velocity = Vector2.ZERO
		anim.pause()
		anim.play("Idle")
	
func death(death_message):
	print(r"Died to " + str(death_message) + " :(")
	
	if death_message == "void":
		await get_tree().create_timer(0.75).timeout

	elif death_message == "lava":
		anim.pause()
		anim.play("Death")
		
		game_paused = true
		await get_tree().create_timer(1.25).timeout
	get_tree().reload_current_scene()

func _on_death_plane_body_entered(_body: CharacterBody2D) -> void:
	death("void")

# Lava func

func _entered_lava(_body: Node2D) -> void:
	death("lava")

func _on_animated_sprite_2d_animation_finished(anim_name) -> void:
	print("finished animation")
	animation_finished = anim_name
