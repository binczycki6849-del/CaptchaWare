extends Control

const MAIN_SCENE_PATH = "res://scenes/Main.scn"

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var black: ColorRect = $ColorRect
onready var music: AudioStreamPlayer = $AudioStreamPlayer
onready var skip: Button = $skip

func _ready() -> void:
	if GameData.save_file.beaten_full_game: 
		skip.visible = true
		return
	
	GameData.save_file.beaten_full_game = true
	GameData.save_cur_data(GameData.GAME_SAVE_NAME)

func _on_animation_player_animation_finished(_anim_name: String) -> void:
	get_tree().change_scene(MAIN_SCENE_PATH)

func _on_skip_pressed() -> void:
	animation_player.play("end")
