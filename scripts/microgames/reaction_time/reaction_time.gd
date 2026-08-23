extends Microgame

const REACTION_TIME = [
	2.0,
	1.8,
	1.6,
	1.4
]

onready var countdown_timer = $CountdownTimer
onready var reaction_timer = $ReactionTimer
onready var instruction_label = $instruction
onready var result_label = $result
onready var success_sound = $sounds/Success
onready var fail_sound = $sounds/Fail

var can_press = false
var pressed = false
var won = false
var lost = false

func _ready() -> void:
	instruction_label.text = "WAIT..."
	result_label.text = ""
	countdown_timer.wait_time = REACTION_TIME[difficulty - 1]
	countdown_timer.start()

func _input(event) -> void:
	if not (event is InputEventMouseButton):
		return
	if not event.pressed:
		return
	if event.button_index != BUTTON_LEFT:
		return

	if lost or won:
		return

	if not can_press:
		lost = true
		instruction_label.text = "TOO SOON"
		result_label.text = "FAILED"
		fail_sound.play()
		force_end_mircogame()
		return

	if pressed:
		return

	pressed = true
	won = true
	instruction_label.text = "CLICKED"
	result_label.text = "SUCCESS"
	success_sound.play()
	force_end_mircogame()

func _on_CountdownTimer_timeout() -> void:
	can_press = true
	instruction_label.text = "CLICK!"

	reaction_timer.wait_time = 0.75
	reaction_timer.start()

func _on_ReactionTimer_timeout() -> void:
	if pressed or won:
		return

	lost = true
	instruction_label.text = "TOO LATE"
	result_label.text = "FAILED"
	fail_sound.play()
	force_end_mircogame()

func isWinning() -> bool:
	return won

func canSkip() -> bool:
	return won or lost
