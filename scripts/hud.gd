extends Control

const INSTRUCTIONS_FILE_PATH = "res://scripts/instructions/"
const ERROR_OFFSET = 25

export var testing = false
export (NodePath) var main_code_path
export (NodePath) var timer_node_path
export (NodePath) var instructions_path
export (NodePath) var big_text_path
export (NodePath) var big_image_path
export (NodePath) var reference_image_path
export (NodePath) var error_label_path
export (NodePath) var captcha_window_path

onready var main_code = get_node(main_code_path) if main_code_path != null and str(main_code_path) != "" else null
onready var timer_node = get_node(timer_node_path) if timer_node_path != null and str(timer_node_path) != "" else null
onready var instructions = get_node(instructions_path) if instructions_path != null and str(instructions_path) != "" else null
onready var big_text = get_node(big_text_path) if big_text_path != null and str(big_text_path) != "" else null
onready var big_image = get_node(big_image_path) if big_image_path != null and str(big_image_path) != "" else null
onready var reference_image = get_node(reference_image_path) if reference_image_path != null and str(reference_image_path) != "" else null
onready var error_label = get_node(error_label_path) if error_label_path != null and str(error_label_path) != "" else null
onready var captcha_window = get_node(captcha_window_path) if captcha_window_path != null and str(captcha_window_path) != "" else null

onready var captcha_count: Label = $captcha_window/lowbar/captchaCount

onready var cur_game: ColorRect = $captcha_window/curGame
onready var progress_bar: ProgressBar = $captcha_window/blueBorder/instructions/ProgressBar
var time_ui : float = 0.0

var prev_window_size : Vector2

func set_up_ui_data(data:Dictionary) -> void:
	if data.has("instructionsBig") and data.has("InstructionsSmall") and data.has("referenceImage"):
		_set_instructions(data.instructionsBig, data.InstructionsSmall, data.referenceImage)
	
	if data.has("windowSize"):
		set_captcha_window_size(data.windowSize, data.windowTween, data.tweenSpeed)

func set_score_num(score_num:int) -> void:
	captcha_count.text = str(score_num) + (" CAPTCHAS" if GameData.save_file.endless_mode else "/20 CAPTCHAS")

func _set_instructions(text_override_big: String = "..n", text_override_small: String = "..n", ref_image = null) -> void:
	var instructions_2nd : Label = instructions.get_node("instructions2")
	
	if big_image.texture != null:
		big_image.texture = null
	
	reference_image.visible = false
	
	if reference_image.texture != null:
		reference_image.texture = null
	
	if ref_image != null:
		reference_image.texture = ref_image
		reference_image.visible = true
	
	if text_override_small != "..n":
		if text_override_small.find("--") != -1:
			var small_txt_array = text_override_small.split("--")
			instructions.text = small_txt_array[0]
			instructions_2nd.text = small_txt_array[1]
		else:
			instructions.text = text_override_small
	
	if text_override_big != "..n":
		if text_override_big.find(".png") != -1:
			big_text.text = ""
			big_image.texture = load(text_override_big)
		else:
			big_text.text = text_override_big

func _display_error_text(errortxt:String = "", reset_error : bool = false) -> void:
	var error_displayed : bool = error_label.visible
	
	if reset_error and error_displayed:
		cur_game.rect_size += Vector2.DOWN * ERROR_OFFSET
		set_captcha_window_size(captcha_window.rect_size + (Vector2.UP * ERROR_OFFSET), false)
		error_label.visible = false
		return
	
	if not error_displayed and errortxt != "":
		cur_game.rect_size += Vector2.UP * ERROR_OFFSET
		set_captcha_window_size(captcha_window.rect_size + (Vector2.DOWN * ERROR_OFFSET), false)
		error_label.visible = true
		error_label.text = errortxt

func _create_tween_node() -> Tween:
	var t = Tween.new()
	add_child(t)
	return t

func set_captcha_window_size(set_window_size : Vector2 = Vector2.ZERO, do_tween : bool = true, anim_speed : float = 1.0) -> void:
	prev_window_size = captcha_window.rect_size
	var captcha_pos_math_y : float = 0
	var captcha_pos_math_x : float = 0
	
	captcha_pos_math_y = calculate_center_offset(prev_window_size.y, set_window_size.y, captcha_window.rect_position.y)
	captcha_pos_math_x = calculate_center_offset(prev_window_size.x, set_window_size.x, captcha_window.rect_position.x)
	
	var captcha_size_pos_offset : Vector2 = Vector2(captcha_pos_math_x, captcha_pos_math_y)
	
	if do_tween:
		var captcha_size_tween : Tween = _create_tween_node()
		var captcha_pos_tween : Tween = _create_tween_node()
		captcha_size_tween.interpolate_property(captcha_window, "rect_size", captcha_window.rect_size, set_window_size, 0.5 / max(anim_speed, 0.001), Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		captcha_pos_tween.interpolate_property(captcha_window, "rect_position", captcha_window.rect_position, captcha_size_pos_offset, 0.5 / max(anim_speed, 0.001), Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		captcha_size_tween.start()
		captcha_pos_tween.start()
	else:
		captcha_window.rect_size = set_window_size
		captcha_window.rect_position = captcha_size_pos_offset

func calculate_center_offset(a:float, b:float, c:float) -> float:
	return (((a - b) / 2.0) + c)

func _process(_delta: float) -> void:
	if testing or timer_node == null or main_code == null:
		return
	var denom = max(main_code.total_wait_time, 0.0001)
	time_ui = lerp(0.0, 100.0, timer_node.time_left / denom)
	progress_bar.value = lerp(progress_bar.value, time_ui, min(_delta * 20, 1))

func _on_verify_button_pressed() -> void:
	if main_code != null:
		main_code.skip_game()
