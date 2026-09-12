extends Control

var correct_one = false

var cur_number_text = ""

onready var phone_number_node = $PhoneNumber
onready var anim = $anim

onready var phone_audio = $phoneAudio

onready var answer = $sounds/answer
onready var decline = $sounds/decline
onready var ringing = $sounds/ringing

onready var ring_time = $ring_time

var declined = false

signal call_answered
signal call_declined

var answered = false

func _on_decline_pressed():
	ring_time.stop()
	ringing.stop()
	decline.play()

	emit_signal("call_declined")
	end_call()

func _on_accept_pressed():
	if answered:
		end_call()
		return

	answered = true

	ring_time.stop()
	ringing.stop()

	anim.play("answered")
	answer.play()

	yield(get_tree().create_timer(0.5), "timeout")

	if declined: return
	phone_audio.play()


func _on_phone_audio_finished():
	end_call()

func end_call():
	declined = true
	
	phone_audio.stop()
	decline.play()
	
	if answered:
		anim.play("answered_end")
		emit_signal("call_answered")
	else:
		anim.play("ignored")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	queue_free()

func _on_ring_time_timeout():
	emit_signal("call_declined")
	end_call()


func _on_x_pressed():
	ring_time.stop()

	if answered:
		emit_signal("call_answered")
	else:
		emit_signal("call_declined")
	
	queue_free()
