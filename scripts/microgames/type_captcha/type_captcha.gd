extends Microgame

onready var line_edit: LineEdit = $LineEdit

var cur_text = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var image_list : Array = get_file_list("res://sprites/type_captcha")
	cur_text = image_list.pick_random().replace(".png", "")
	
	emit_signal("override_instruction_text", "res://sprites/type_captcha/" + cur_text + ".png")
	
	line_edit.call_deferred("grab_focus")

func isWinning() -> bool:
	return line_edit.text.to_lower() == cur_text.to_lower()

func canSkip() -> bool:
	return line_edit.text.strip_edges() != ""

func _on_line_edit_text_changed(_new_text: String) -> void:
	if is_intro: return
	emit_signal("set_camera_shake", 3, 0.25)
