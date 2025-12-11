class_name Enemy extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../Player"
@onready var world: Node2D = get_tree().root.get_node("World")
@onready var navigation_agent = $NavigationAgent2D
@onready var scripts = "res://Scripts/contrib.gd"

@export var MAX_SPEED := 150
@export var JUMP_VELOCITY := -300
@export var MAX_HEALTH := 50

var HEALTH = MAX_HEALTH
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
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.timeout.connect(print_debug_info)
	timer.start()
	#queue_free()

func flip(direction):
	if direction.x < 0:
		return true
	else:
		return false

func _physics_process(delta: float) -> void:
	#navigation_agent.target_position = player.position
	var next_path_position = navigation_agent.get_next_path_position()
	var direction := global_position.direction_to(next_path_position)
	
	move_and_slide()
	
	velocity.x = (direction.x * SPEED)
	velocity += get_gravity() * delta
	anim.pause()
	anim.play("Walk")
	$AnimatedSprite2D.flip_h = flip(direction)
	
	if direction.y < -0.5 and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if velocity.x == 0.0:
		anim.pause()
		anim.play("Idle")
		
	if HEALTH <= 0:
		anim.play("Death")
		queue_free()
	
	if Input.is_action_just_pressed("restart"):
		velocity = Vector2(0, 0)
		scripts.restart()
		
	if Input.is_action_just_pressed("quit"): get_tree().quit()
func print_debug_info():
	print(velocity.y, ", ", HEALTH)
