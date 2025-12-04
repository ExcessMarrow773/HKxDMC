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
		

		velocity += get_gravity() * delta
		move_and_slide()
		print(direction)
		# Handles respawn/ restart
		if Input.is_action_just_pressed("restart"):
			velocity = Vector2(0, 0)
			restart()

		# Get the input direction and handle the movement/deceleration.
		if not game_paused: # Adjust the threshold (0.1) as needed:
			
			velocity = direction * SPEED
			
			if not game_paused:
				anim.pause()
				anim.play("Walk")
		
		else:
			if not game_paused:
				anim.pause()
				anim.play("Idle")

		move_and_slide()
		
		if Input.is_action_just_pressed("quit"): get_tree().quit()
	else:
		# Stop enemy movement if pathfinding is disabled
		velocity = Vector2.ZERO
		anim.pause()
		anim.play("Idle")
	
func restart():
	get_tree().reload_current_scene()

func _on_animated_sprite_2d_animation_finished(anim_name) -> void:
	print("finished animation")
	animation_finished = anim_name
