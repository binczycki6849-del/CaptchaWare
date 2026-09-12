extends Button

onready var check: Sprite = $check
onready var sprite_2d: Sprite = $Sprite2D
var cur_frame: int = 0
var cur_size: float = 0.155
var selection_type : int = 0 # 0 = no, 1 = mandatory, 2 = optional

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
	sprite_2d.texture = get_parent().cur_image
	sprite_2d.frame = cur_frame

func _on_toggled(toggled_on: bool) -> void:
	cur_size = (0.13 if toggled_on else 0.155)
	_tween_property_compat(sprite_2d, "scale", Vector2.ONE * cur_size, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
	
	var add_point : int = 0
	
	if (toggled_on and [1, 2].has(selection_type)) or (selection_type == 0 and !toggled_on):
		if selection_type == 2:
			add_point = 0
		else:
			add_point = 1
	else:
		if selection_type != 2:
			add_point = -1
	
	emit_signal("gainPoints", add_point)
	emit_signal("count_selected", 1 if toggled_on else -1)
	
	check.visible = toggled_on
	pass # Replace with function body.
