extends Node2D

const FAST_CAP = 0.35
const SLOW_CAP = 0.7

onready var reader_text: Label = $'../topPart/Label'
onready var lights: Sprite = $'../topPart/lights'
onready var sounds: Node = $'../sounds'

var mouse_prev_position_x = 0.0

var card_swipe_timer : float = 0.0

var card_hovered = false

var card_grabbed = false
var card_moving = false

var card_can_swipe = false
var card_tweening = false

var can_win_card = true

var tween_card_pos : Tween

signal swipe_completed

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

# x109.0 y371.265
func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Left Click") and card_hovered:
			if !card_tweening:
				sounds.get_node("insert").play()
				var tween_card_size = _tween_property_compat(self, "scale", Vector2.ONE * 1.36, .75)
				tween_card_pos = _tween_property_compat(self, "position", Vector2(6.0, 148.265), .75)

				tween_card_size.connect("tween_all_completed", self, "card_on_reader")

				card_tweening = true
				return

			if !card_can_swipe: return
			mouse_prev_position_x = get_global_mouse_position().x

			if tween_card_pos != null:
				tween_card_pos.queue_free()
				tween_card_pos = null
			card_grabbed = true
			sounds.get_node("swipe").play()

		if Input.is_action_just_released("Left Click") and card_grabbed:
			card_grabbed = false
			card_moving = false

			var success_check = check_card_reader()

			tween_card_pos = null
				
			if success_check:
				card_can_swipe = false
				lights.frame = 1
				sounds.get_node("accept").play()

				var tween_card_size = _tween_property_compat(self, "scale", Vector2.ONE * 1, .75)
				tween_card_pos = _tween_property_compat(self, "position", Vector2(109.0, 371.265), .75)
			else:
				sounds.get_node("denied").play()
				lights.frame = 0
				tween_card_pos = _tween_property_compat(self, "position", Vector2(6.0, 148.265), 1, Tween.TRANS_EXPO, Tween.EASE_OUT)
			
			card_swipe_timer = 0
	
	if event is InputEventMouseMotion:
		if !card_grabbed: return

		if !(mouse_prev_position_x + 10 < get_global_mouse_position().x or mouse_prev_position_x - 10 > get_global_mouse_position().x): return

		card_moving = !(position.x <= 6.0 or position.x >= 406.0)
		position = Vector2(clamp(get_global_mouse_position().x - 400, 6.0, 406.0) ,148.265)

func _process(delta):
	if card_moving:
		card_swipe_timer += delta

func check_card_reader() -> bool:
	if !can_win_card: return false
	
	if position.x < 406.0:
		reader_text.text = "BAD READ. TRY AGAIN."
		return false
	
	if card_swipe_timer < FAST_CAP:
		reader_text.text = "TOO FAST. TRY AGAIN."
		return false
	
	if card_swipe_timer > SLOW_CAP:
		reader_text.text = "TOO SLOW. TRY AGAIN."
		return false

	if card_swipe_timer >= FAST_CAP and card_swipe_timer <= SLOW_CAP:
		reader_text.text = "ACCEPTED CARD. THANK YOU."
		emit_signal("swipe_completed")
		return true
	
	return false

func card_on_reader() -> void:
	card_can_swipe = true

	reader_text.text = "PLEASE SWIPE CARD"
	lights.visible = true

func _on_card_texture_mouse_exited() -> void:
	card_hovered = false

func _on_card_texture_mouse_entered() -> void:
	card_hovered = true
