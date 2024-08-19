extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel
@onready var gold_label: Label = %GoldLabel


func _ready():
	GameManager.game_ui = self

func _process(delta: float):
	if GameManager.is_game_over: return
	
	
	timer_label.text = GameManager.time_elapsed_str
	meat_label.text = str(GameManager.meat_counter)
	gold_label.text = str(GameManager.gold_counter)
