class_name GameOverUI
extends CanvasLayer

@onready var timer_label: Label = %FinalTimer
@onready var monsters_label: Label = %FinalMonsters
@onready var gold_label: Label = %FinalGold
@onready var meat_label: Label = %FinalMeat
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var countdown: float

func _ready():
	GameManager.game_over_ui_template = self
	timer_label.text = GameManager.time_elapsed_str
	monsters_label.text = str(GameManager.monsters_defeated_counter)
	gold_label.text = str(GameManager.gold_counter)
	meat_label.text = str(GameManager.meat_counter)
	countdown = animation_player.current_animation_length

func _process(delta):
	countdown-=delta
	if Input.is_anything_pressed() and countdown<=0:
		restart_game()

func press_any():
	animation_player.play("press_any")

func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
