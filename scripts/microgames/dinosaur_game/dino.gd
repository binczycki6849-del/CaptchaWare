extends KinematicBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -1300.0

var velocity = Vector2.ZERO
var buffer_jump_timer = 0.0

onready var anim = $anim

signal killed

var is_dead = false

onready var jump_sound = $sounds/jump
onready var hit_sound = $sounds/hit

func get_gravity() -> float:
	if ProjectSettings.has_setting("physics/2d/default_gravity"):
		return float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	return 98.0

func timers(delta : float) -> void:
	if buffer_jump_timer >= 0:
		buffer_jump_timer -= delta

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	timers(delta)
	
	if not is_on_floor():
		velocity.y += (get_gravity() * 6.0) * delta

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("Left Click"):
		buffer_jump_timer = 0.5
	
	if is_on_floor() and buffer_jump_timer > 0:
		jump_sound.play()
		buffer_jump_timer = 0
		velocity.y = JUMP_VELOCITY

	velocity = move_and_slide(velocity, Vector2.UP)

func _on_cactus_detector_area_entered(area: Area2D) -> void:
	if not (area.get_parent() is cactus):
		return
	area.get_parent().speed_set = 0
	dead()

func dead() -> void:
	hit_sound.play()
	is_dead = true
	anim.play("dead")
	killed.emit()
