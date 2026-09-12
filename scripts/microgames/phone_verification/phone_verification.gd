extends Microgame

# Godot 3.5 compatibility pass
# NOTE: verify this path in-editor if the scene lives elsewhere.
const PHONE_CALL_WINDOW = preload("res://instances/phone_call_window.tscn")

onready var camera = get_tree().get_nodes_in_group("camera")[0] if get_tree().get_nodes_in_group("camera").size() > 0 else null
onready var phonenumber_label = $phonenumber

var phone_number = 0

var real_number_calling = false
var has_answered = false

var number_of_calls = 0
var how_many_fake_calls = 1

var fake_number_type = [
	"ding",
	"erynn",
	"hira",
	"jackson",
	"jam",
	"juhin",
	"julnz",
	"marcz",
	"miel",
	"mystery",
	"nonsense",
	"puppet",
	"zac",
	"lopil",
	"jemi"
]

onready var popup = $popup

func _ready() -> void:
	phonenumber_label.text = generate_number()
	how_many_fake_calls = randi_range(1, 3)

func pop_up_window() -> void:
	var phone_call_window = PHONE_CALL_WINDOW.instance()
	phone_call_window.connect("call_answered", self, "on_call_answered")
	phone_call_window.connect("call_declined", self, "on_call_declined")
	add_child(phone_call_window)

	emit_signal("set_camera_shake", 10, 0.5)
	popup.play()

	if how_many_fake_calls <= number_of_calls:
		phone_call_window.phone_number_node.text = phonenumber_label.text
		real_number_calling = true
	else:
		phone_call_window.phone_number_node.text = generate_number()
		phone_call_window.phone_audio.stream = get_phone_call_audio()
	number_of_calls += 1

func get_phone_call_audio():
	var path = "res://sounds/microgames/phone_verification/"
	if real_number_calling:
		path += "automated_message.mp3"
	else:
		path += "fake_numbers/" + fake_number_type[randi_range(0, fake_number_type.size() - 1)]
		var audio_phone_final = get_file_list(path, ".mp3")
		path += "/" + audio_phone_final[randi_range(0, audio_phone_final.size() - 1)]
	return load(path)

func generate_number() -> String:
	var number_text = ""
	phone_number = randi_range(1000000000, 9999999999)
	var number_array = str(phone_number).split("")
	number_text = "+1 ("
	for i in range(10):
		number_text += number_array[i] + get_phone_format(i)
	return number_text

func get_phone_format(i: int) -> String:
	match i:
		2:
			return ") "
		5:
			return "-"
		_:
			return ""

func canSkip() -> bool:
	return false

func isWinning() -> bool:
	return has_answered and real_number_calling

func on_call_answered() -> void:
	has_answered = true
	yield(get_tree().create_timer(0.5), "timeout")
	force_end_mircogame()

func _make_tween() -> Tween:
	var t = Tween.new()
	add_child(t)
	return t

func on_transition_complete() -> void:
	if camera != null:
		var cam_tween = _make_tween()
		cam_tween.interpolate_property(camera, "zoom", camera.zoom, Vector2.ONE * 1.80, 4.0, Tween.TRANS_CIRC, Tween.EASE_IN)
		cam_tween.start()
	yield(get_tree().create_timer(rand_range(2.0, 4.0)), "timeout")
	if camera != null:
		var cam_tween_back = _make_tween()
		cam_tween_back.interpolate_property(camera, "zoom", camera.zoom, Vector2.ONE * 1.43, 0.2, Tween.TRANS_EXPO, Tween.EASE_OUT)
		cam_tween_back.start()
	pop_up_window()

func on_call_declined() -> void:
	if real_number_calling:
		yield(get_tree().create_timer(0.5), "timeout")
		force_end_mircogame()
		return
	yield(get_tree().create_timer(1.5), "timeout")
	pop_up_window()
