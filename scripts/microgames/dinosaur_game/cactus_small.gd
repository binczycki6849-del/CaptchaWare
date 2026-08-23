extends Sprite

class_name cactus

var speed_set := 800.0

func _ready() -> void:
	frame = randi() % hframes

func _process(delta: float) -> void:
	if speed_set == 0: return
	position += (Vector2.LEFT * speed_set) * delta
