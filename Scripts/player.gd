class_name Player extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
#@onready var death_plane: Area2D = $"../Death Plane"

@export var MAX_SPEED := 200
@export var JUMP_VELOCITY := -350
@export var MAX_HEALTH := 500
@export var slash_attack: PackedScene

var HEALTH = MAX_HEALTH
var SPEED = 0
var ACCELERATION = 500
var lastX = 0
var lastY = 0
var game_paused = false
var animation_finished = null
var isDashing := false
var canDash := false
var dash_dist = 450
var dash_time_max = 0.1
var dash_time = 0
var dash_cooldown_max = 0.4
var dash_cooldown = 0.0

func _ready() -> void:
	pass

func flip(direction):
	if direction == -1: return true
	else: return false

func _physics_process(delta: float) -> void:
	var did_move = (lastX == position.x) and (lastY == position.y)
	var direction := Input.get_axis("left", "right")
	if isDashing: direction = 0.0
	# Add the gravity.
	if not is_on_floor() and not game_paused and not isDashing:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !isDashing:
		velocity.y = JUMP_VELOCITY
	
	# Handle dash.
	if Input.is_action_just_pressed("dash") and dash_cooldown >= dash_cooldown_max and !isDashing and canDash:
		isDashing = true
		dash_cooldown = 0
		dash_time = 0
		velocity.y = 0
		canDash = false
	
	if !isDashing and dash_cooldown < dash_cooldown_max:
		dash_cooldown += delta
	
	if isDashing:
		var translation = dash_dist * delta
		if $AnimatedSprite2D.flip_h: translation *= -1
		position.x += translation
		dash_time += delta
		if dash_time >= dash_time_max:
			isDashing = false
	
	if is_on_floor() and !canDash:
		canDash = true
	
	# Handles respawn/ restart
	if Input.is_action_just_pressed("restart"):
		velocity = Vector2(0, 0)
		death('respawn')
		
	if Input.is_action_just_pressed("attack"):
		var atk = slash_attack.instantiate()
		add_child(atk)
		print(atk.get_tree_string())
		atk.scale.x = 1
		if $AnimatedSprite2D.flip_h: atk.scale.x = -1
		
		
		
	# Get the input direction and handle the movement/deceleration.
	if direction and not game_paused: # Adjust the threshold (0.1) as needed:
		$AnimatedSprite2D.flip_h = flip(direction)
		
		if did_move:
			SPEED = min(SPEED + ACCELERATION * delta, MAX_SPEED)
			
		velocity.x = direction * SPEED
		
		if not game_paused:
			anim.pause()
			anim.play("Walk")
		
	else:
		if not game_paused: velocity.x = move_toward(velocity.x, 0, SPEED)
		SPEED = 0
		if not game_paused:
			anim.pause()
			anim.play("Idle")
	
	if not game_paused: move_and_slide()
	lastY = position.y
	lastX = position.x
	if Input.is_action_just_pressed("quit"): get_tree().quit()
	
	
	
# handles death
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

func _on_animated_sprite_2d_animation_finished(anim_name) -> void:
	print("finished animation")
	animation_finished = anim_name
