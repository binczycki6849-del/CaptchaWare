extends Node2D

var mouse_hovering : bool = false
var set_click_offset : Vector2 = Vector2.ZERO
var selected : bool = false

var cur_puzzle_hole : Node2D = null
var cur_index : int = 0

onready var check: Sprite = $check

onready var puzzle_piece_mask: Sprite = $puzzlePieceMask
onready var click_shape: CollisionShape2D = $clickArea/clickShape

onready var puzzle_place: AudioStreamPlayer = $PuzzlePlace
onready var puzzle_grab: AudioStreamPlayer = $puzzleGrab
onready var point_hitbox: RayCast2D = $RayCast2D

signal count_puzzles

func _tween_property_compat(target: Object, property: String, final_value, duration: float, trans_type: int = Tween.TRANS_LINEAR, ease_type: int = Tween.EASE_IN_OUT, initial_value = null, use_initial_value: bool = false) -> Tween:
	var tween = Tween.new()
	add_child(tween)
	if use_initial_value:
		target.set(property, initial_value)
		tween.interpolate_property(target, property, initial_value, final_value, duration, trans_type, ease_type)
	else:
		tween.interpolate_property(target, property, target.get(property), final_value, duration, trans_type, ease_type)
	tween.connect("tween_all_completed", tween, "queue_free")
	tween.start()
	return tween

func set_puzzle_texture(puzzleMaskIndex: int = 0, puzzleTexture: Texture = null, puzzleTexturePos : Vector2 = Vector2.ZERO) -> void:
	
	puzzle_piece_mask.texture = load("res://sprites/puzzle_piece/masks/puzzle" + str(puzzleMaskIndex) + ".png")
	
	var puzzle_mask_shader = puzzle_piece_mask.material as ShaderMaterial
	puzzle_mask_shader.set_shader_parameter("base_texture", puzzleTexture)
	puzzle_mask_shader.set_shader_parameter("base_texture_offset", Vector2(50, 50) - puzzleTexturePos)
	
	cur_index = puzzleMaskIndex

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Left Click") and mouse_hovering:
			selected = true
			set_click_offset = global_position - get_global_mouse_position()
			puzzle_grab.play()
			check.visible = false
			
			_tween_property_compat(self, "scale", Vector2.ONE * 1.2, .3, Tween.TRANS_EXPO, Tween.EASE_OUT)
		
		if Input.is_action_just_released("Left Click") and selected:
			selected = false
			puzzle_place.play()
			hole_check()
			
			_tween_property_compat(self, "scale", Vector2.ONE * 1.0, .3, Tween.TRANS_EXPO, Tween.EASE_OUT, Vector2.ONE * 0.9, true)
	
	if event is InputEventMouseMotion and (selected and Input.is_action_pressed("Left Click")):
		global_position = get_global_mouse_position() + set_click_offset

func hole_check() -> void:
	var collider = point_hitbox.get_collider()
	if collider == null or collider.get_parent() != cur_puzzle_hole: return
	
	var hole : Node2D = collider.get_parent()
	global_position = hole.global_position
	check.visible = true
	lock_puzzle_piece()
	emit_signal("count_puzzles")

func lock_puzzle_piece() -> void:
	click_shape.disabled = true

func _on_click_area_mouse_entered() -> void:
	mouse_hovering = true

func _on_click_area_mouse_exited() -> void:
	mouse_hovering = false
