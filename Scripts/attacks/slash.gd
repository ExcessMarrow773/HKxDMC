class_name attack_slash extends Area2D

var damage = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)

	timer.wait_time = .25

	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	#print(body)
	if body.name == "Enemy":
		body.HEALTH -= damage
		print("did damage")
