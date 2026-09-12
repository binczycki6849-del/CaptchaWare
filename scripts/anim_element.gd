extends Sprite

export var shake_amount = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if shake_amount <= 0: return
	var shake_x = rand_range(-shake_amount, shake_amount)
	var shake_y = rand_range(-shake_amount, shake_amount)
	offset = Vector2.ZERO + Vector2(shake_x, shake_y)
