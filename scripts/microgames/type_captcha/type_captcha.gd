extends Microgame

onready var line_edit: LineEdit = $LineEdit

var cur_text = ""

func _ready() -> void:
	var image_list : Array = get_file_list("res://sprites/type_captcha")
	cur_text = image_list[randi() % image_list.size()].replace(".png", "")
	
	emit_signal("override_instruction_text", "res://sprites/type_captcha/" + cur_text + ".png", "")
	
	line_edit.grab_focus.call_deferred()

func isWinning() -> bool:
	return line_edit.text.to_lower() == cur_text.to_lower()

func canSkip() -> bool:
	return line_edit.text.strip_edges() != ""

func _on_line_edit_text_changed(_new_text: String) -> void:
	if is_intro: return
	emit_signal("set_camera_shake", 3, 0.25)
