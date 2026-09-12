extends Camera2D

class_name cam_effects

export var parallax_offset_amount : float = 0
export var shake_amount : float = 0

var shake_vector : Vector2 = Vector2.ZERO
var parallax_offset = Vector2.ZERO
onready var default_zoom :Vector2 = zoom

var force_pause : bool = false

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

func _ready() -> void:
	parallax_system()

#region Effects
func pause_game(paused : bool) -> void: #use this function to prevent hitstop from unpausing the tree
	force_pause = paused
	get_tree().paused = paused

func shake_camera(intensity:float, duration:float = 0) -> void:
	if duration == 0:
		shake_amount = intensity
		return
	_tween_property_compat(self, "shake_amount", 0, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT, shake_amount + intensity, true)

func camera_bop_in(zoom_amount: float, duration:float) -> void:
	_tween_property_compat(self, "zoom", default_zoom, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT, Vector2.ONE * zoom_amount, true)

func camera_shake_process() -> void:
	if shake_amount == 0: return
	var final_amount : float = shake_amount
	shake_vector = Vector2(rand_range(-final_amount,final_amount), rand_range(-final_amount,final_amount))

func parallax_system() -> void:
	if parallax_offset_amount == 0: return
	parallax_offset = lerp(Vector2.ZERO, get_local_mouse_position(), parallax_offset_amount / 100.0)

func hit_stop(duration: float) -> void:
	get_tree().paused = true
	yield(get_tree().create_timer(duration), "timeout")
	get_tree().paused = force_pause
#endregion

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		parallax_system()

func _physics_process(_delta: float) -> void:
	camera_shake_process()

func _process(_delta: float) -> void:
	offset = shake_vector + parallax_offset
