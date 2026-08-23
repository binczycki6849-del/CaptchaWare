extends Microgame

const POPUP_INSTANCE = preload("res://instances/closePopups/popup.tscn")
const BLOCKER_IMAGE_FILENAME := preload("res://sprites/close_popups/blocker.png")

const DIFFICULTY_POPUP_COUNT := [5, 6, 7, 8]

const AD_IMAGES_PATH := "res://sprites/close_popups/ads/"

onready var camera = get_tree().get_nodes_in_group("camera")[0] if get_tree().get_nodes_in_group("camera").size() > 0 else null

onready var pop_ups: Control = $popUps
onready var count_down: Label = $ad/CountDown
onready var timer: TextureProgress = $ad/timer
onready var pop_up_timer: Timer = $PopUpTimer
onready var crosshair_sprite: Sprite = $crosshair

onready var ticking_sound: AudioStreamPlayer = $sounds/tickingSound
onready var riflesounds_sound: AudioStreamPlayer = $sounds/riflesounds
onready var reload_sound: AudioStreamPlayer = $sounds/reload
onready var popup_close_sound: AudioStreamPlayer = $sounds/popupClose
onready var popup_sound: AudioStreamPlayer = $sounds/popup

var popup_amount := 5

var ad_images : Array = []
var cleared := false

const rand_pos_clamp = [Vector2(-246.0, 100.0), Vector2(611.0, 340.0)]

func _ready() -> void:
	popup_amount = DIFFICULTY_POPUP_COUNT[difficulty - 1]
	connect("end_microgame", self, "times_up")
	timer.max_value = pop_up_timer.wait_time

	var cur_image_paths := get_file_list(AD_IMAGES_PATH)

	for i in cur_image_paths:
		ad_images.append(load(AD_IMAGES_PATH + i))
	
	print_debug(ad_images)
	
	ad_images.shuffle()

func times_up() -> void:
	close_all_popups()

func spawn_popup(image, is_blocker : bool = false) -> void:
	var popup_instance = POPUP_INSTANCE.instance()

	var rand_x = int(rand_pos_clamp[0].x) + randi() % (int(rand_pos_clamp[1].x) - int(rand_pos_clamp[0].x) + 1)
	var rand_y = int(rand_pos_clamp[0].y) + randi() % (int(rand_pos_clamp[1].y) - int(rand_pos_clamp[0].y) + 1)

	popup_instance.position = Vector2(rand_x, rand_y)
	popup_instance.is_blocker = is_blocker

	if is_blocker:
		popup_instance.connect("block_popups", self, "popup_blocker_clicked")

	popup_instance.connect("popup_closed", self, "on_popup_closed")

	pop_ups.add_child(popup_instance)
	
	popup_instance.set_popup_image(image)

func _process(_delta: float) -> void:
	timer.value = pop_up_timer.time_left

func close_all_popups(destroyed := false) -> void:
	if cleared: return
	var popup_closing_sound = riflesounds_sound if destroyed else popup_close_sound

	for popup in pop_ups.get_children():
		if popup == null: continue
		popup_closing_sound.play()

		if destroyed:
			var crosshair_tween = Tween.new()
			add_child(crosshair_tween)
			crosshair_tween.interpolate_property(crosshair_sprite, "position", crosshair_sprite.position, popup.position, .07, Tween.TRANS_EXPO, Tween.EASE_OUT)
			crosshair_tween.start()

			emit_signal("set_camera_shake", 3, .2)
			popup.destroyed()
			yield(get_tree().create_timer(.07), "timeout")
		else:
			popup.queue_free()
			yield(get_tree().create_timer(.025), "timeout")

func _on_pop_up_timer_timeout() -> void:
	ticking_sound.stop()

	var cam_tween = Tween.new()
	add_child(cam_tween)
	cam_tween.interpolate_property(camera, "zoom", camera.zoom, Vector2.ONE * 1.43, .07, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	cam_tween.start()

	emit_signal("set_camera_shake", 5, .5)

	var pop_up_blocker_chance = 3 + randi() % (popup_amount - 4)

	for i in range(min(ad_images.size(), popup_amount)):
		popup_sound.play()

		if i == pop_up_blocker_chance:
			spawn_popup(BLOCKER_IMAGE_FILENAME, true)
		else:
			spawn_popup(ad_images[i])
		yield(get_tree().create_timer(.025), "timeout")
	
	ad_images.clear()

func on_popup_closed() -> void:
	if pop_ups.get_child_count() <= 1 && !cleared:
		win()

func popup_blocker_clicked() -> void:
	crosshair_sprite.visible = true
	
	var crosshair_tween = Tween.new()
	add_child(crosshair_tween)
	crosshair_tween.interpolate_property(crosshair_sprite, "position", crosshair_sprite.position, pop_ups.get_child(pop_ups.get_child_count() - 1).position, .5, Tween.TRANS_EXPO, Tween.EASE_OUT)
	crosshair_tween.start()

	reload_sound.play()
	emit_signal("freeze_timer_signal")

	yield(get_tree().create_timer(.5), "timeout")

	close_all_popups(true)

	yield(get_tree().create_timer(.5), "timeout")
	
	win()
	emit_signal("end_microgame")

func win() -> void:
	cleared = true
	emit_signal("skip_timer")

func on_transition_complete() -> void:
	ticking_sound.play()

	var cam_tween = Tween.new()
	add_child(cam_tween)
	cam_tween.interpolate_property(camera, "zoom", camera.zoom, Vector2.ONE * 1.80, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	cam_tween.start()

func _on_timer_value_changed(value: float) -> void:
	count_down.text = str(int(ceil(value)))

func isWinning() -> bool:
	return cleared
