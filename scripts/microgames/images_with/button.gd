extends Button

onready var check: Sprite = $check
onready var sprite_2d: Sprite = $Sprite2D
var cur_image : String = ""
var correct_option : bool = false
var cur_image_size : float = 0.087

signal gainPoints(yes)
signal count_selected(a)

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
	sprite_2d.texture = load("res://sprites/images_with/images/" + cur_image + ".png")

func _on_toggled(toggled_on: bool) -> void:
	cur_image_size = (0.075 if toggled_on else 0.087)
	
	_tween_property_compat(sprite_2d, "scale", Vector2.ONE * cur_image_size, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
	
	var add_point = 1 if (toggled_on and correct_option or (!correct_option and !toggled_on)) else -1
	emit_signal("gainPoints", add_point)
	
	emit_signal("count_selected", 1 if toggled_on else -1)
	
	check.visible = toggled_on
	pass # Replace with function body.
