extends CharacterBody2D

class_name Fish

const FISH_IMAGE_DIR = "res://sprites/fishing_game/"
const HOOK_OFFSET = Vector2(-10, 50)

export(String, "fish", "shark") var fish_type = "fish"
export var speed := 300.0
onready var sprite = $sprite
onready var mouse_pos = get_node('../../boat/boat_sprite/mouse_pos')
var cur_dir := 1

var mouse_hovered := false
var grabbed := false

signal fish_grabbed(fish)
signal failed_microgame

func _ready() -> void:
	sprite.texture = get_fish_sprite()

	var rand_speed := rand_range(-20, 20)
	speed += rand_speed

func _physics_process(delta: float) -> void:
	if grabbed:
		return
	position.x += (speed * delta) * cur_dir

func _process(_delta: float) -> void:
	if not grabbed:
		return
	global_position = mouse_pos.global_position + HOOK_OFFSET

func get_fish_sprite():
	var fish_dir := FISH_IMAGE_DIR + fish_type + "/"
	var fish_sprite_list := ResourceLoader.list_directory(fish_dir)
	var random_image := fish_sprite_list[randi() % max(1, fish_sprite_list.size())]

	if cur_dir == 1:
		sprite.flip_h = true

	return load(fish_dir + random_image)

func run_away() -> void:
	if fish_type == "shark": 
		speed = 0
		sprite.modulate = Color.white
		return
	if grabbed:
		queue_free()
	cur_dir *= -1
	sprite.flip_h = not sprite.flip_h
	speed = 1000

func _on_input_event(_viewport, _event, _shape_idx) -> void:
	if grabbed or fish_type == "shark":
		return

	if Input.is_action_just_pressed("Left Click"):
		fish_grabbed.emit(self)

func _on_mouse_entered() -> void:
	if fish_type == "fish":
		return
	failed_microgame.emit()
