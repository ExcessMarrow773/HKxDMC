extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_plane: Area2D = $"../Death Plane"

@export var MAX_SPEED := 300
@export var JUMP_VELOCITY := -350



var SPEED = 0
var ACCELERATION = 500
var CLIMB_SPEED = 200.0
var lastX = 0
var lastY = 0
var on_ladder = false
var climbing: bool
var game_paused = false
var animation_finished = null

func _ready() -> void:
	pass

func flip(direction):
	if direction == -1:
		return true
	else:
		return false

func _physics_process(delta: float) -> void:
	var did_move = (lastX == position.x) and (lastY == position.y)
	var direction := Input.get_axis("left", "right")
	# Add the gravity.
	if not is_on_floor() and not game_paused:
		velocity += get_gravity() * delta

	if on_ladder:
		var vert_direction := Input.get_axis("jump" ,"down")
		if vert_direction:
			velocity.y = vert_direction * CLIMB_SPEED
			climbing = not is_on_floor()
		else:
			velocity.y = move_toward(velocity.y, 0, CLIMB_SPEED)
			if is_on_floor(): climbing = false
		

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handles respawn/ restart
	if Input.is_action_just_pressed("restart"):
		velocity = Vector2(0, 0)
		death('respawn')

	# Get the input direction and handle the movement/deceleration.
	$Camera2D/Label.text = "on ladder: " + str(on_ladder) + "\ndirection: " + str(direction)
	if direction and not game_paused: # Adjust the threshold (0.1) as needed:
		$AnimatedSprite2D.flip_h = flip(direction)
		
		if did_move:
			SPEED = min(SPEED + ACCELERATION * delta, MAX_SPEED)
			
		velocity.x = direction * SPEED
		
		if on_ladder: climbing = not is_on_floor()
		else: climbing = false
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

func _on_area_2d_body_exited(_body: Node2D) -> void:
	print("exited a ladder")
	on_ladder = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
	print("entered a ladder")
	on_ladder = true

func _on_animated_sprite_2d_animation_finished(anim_name) -> void:
	print("finished animation")
	animation_finished = anim_name
