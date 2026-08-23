extends Button

onready var check: Sprite = $check
onready var sprite_2d: Sprite = $Sprite2D
var cur_image : String = ""
var correct_option : bool = false
var cur_image_size : float = 0.087

signal gainPoints(yes)
signal count_selected(a)

func _ready() -> void:
	sprite_2d.texture = load("res://sprites/images_with/images/" + cur_image + ".png")

func _on_toggled(toggled_on: bool) -> void:
	cur_image_size = (0.075 if toggled_on else 0.087)
	
	var shrinkAnim = Tween.new()
	add_child(shrinkAnim)
	shrinkAnim.interpolate_property(sprite_2d, "scale", sprite_2d.scale, Vector2.ONE * cur_image_size, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
	shrinkAnim.start()
	
	var add_point := 1 if (toggled_on && correct_option || (!correct_option && !toggled_on)) else -1
	emit_signal("gainPoints", add_point)
	
	emit_signal("count_selected", 1 if toggled_on else -1)
	
	check.visible = toggled_on
