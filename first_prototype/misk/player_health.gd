extends ProgressBar

func _process(_delta: float):
	if GameManager.is_game_over: return
	
	
	max_value = GameManager.player_max_health
	value = GameManager.player_health
