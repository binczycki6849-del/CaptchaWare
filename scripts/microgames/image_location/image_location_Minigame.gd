extends Microgame

export var cur_image: Texture
onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const IMAGE_LOCATE_BUTTON = preload("res://instances/ImageLocate/ImageLocate_button.tscn")
const FILE_PATH: String = "res://sprites/locate_images/"

var min_points = 0
var points = 0
var selected = 0

var cur_object = ""

func _ready() -> void:
	set_image()

func set_image() -> void:
	var image_array : Array = get_file_list(FILE_PATH)
	var difficulty_2_images = ["1.png","8.png","10.png","11.png","waldo.png"]
	
	var cur_image_value : String
	
	while true:
		cur_image_value = image_array.pick_random()
		if (difficulty >= 2 or !difficulty_2_images.has(cur_image_value)): break
	
	#debug code
	#cur_image_value = "5.png"
	
	if cur_image == null:
		cur_image = load(FILE_PATH + cur_image_value)
	
	var correct_answers_file = File.new()
	correct_answers_file.open(FILE_PATH + cur_image_value.replace(".png", ".txt"), File.READ)
	
	var correct_answers : PoolStringArray = []
	var line : String = correct_answers_file.get_as_text()
	correct_answers_file.close()
	
	correct_answers = line.split(",", false)
	
	cur_object = correct_answers[16].strip_edges()
	emit_signal("override_instruction_text", cur_object)

	for button in range(16):
		var button_node : Button = IMAGE_LOCATE_BUTTON.instance()
		var button_type : int = int(correct_answers[button].strip_edges())
		button_node.cur_frame = (button)
	
		if ([1, 2].has(button_type)):
			button_node.selection_type = button_type
			if button_type == 1:
				min_points += 1
		
		#print_debug(button)
		add_child(button_node)
		
		button_node.connect("gainPoints", self, "pointManager")
		button_node.connect("count_selected", self, "count_selected")

func isWinning() -> bool:
	return points >= min_points

func canSkip() -> bool:
	return selected >= min(min_points,3)

func pointManager(add:int) -> void:
	points += add
	#print_debug(points)

func count_selected(point:int = 0) -> void:
	audio_stream_player.play()
	selected += point
