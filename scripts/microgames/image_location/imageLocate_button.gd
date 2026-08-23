extends Button

onready var check: Sprite = $check
onready var sprite_2d: Sprite = $Sprite2D
var cur_frame: int = 0
var cur_size: float = 0.155
var selection_type : int = 0 # 0 = no, 1 = mandatory, 2 = optional

signal gainPoints(yes)
signal count_selected(a)

func _ready() -> void:
	sprite_2d.texture = get_parent().cur_image
	sprite_2d.frame = cur_frame

func _on_toggled(toggled_on: bool) -> void:
	cur_size = (0.13 if toggled_on else 0.155)
	var shrinkAnim = Tween.new()
	add_child(shrinkAnim)
	shrinkAnim.interpolate_property(sprite_2d, "scale", sprite_2d.scale, Vector2.ONE * cur_size, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
	shrinkAnim.start()
	
	var add_point : int = 0
	
	if (toggled_on && [1, 2].has(selection_type)) || (selection_type == 0 && !toggled_on):
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
