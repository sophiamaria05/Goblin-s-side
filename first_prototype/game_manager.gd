extends Node

signal game_over

var is_game_over: bool = false
var player_position: Vector2
var player_max_health: int
var player_health: int
var player: Player
var game_ui: CanvasLayer
var game_over_ui_template: GameOverUI

var time_elapsed: float = 0
var time_elapsed_int: int
var min: int
var sec: int
var time_elapsed_str: String
var meat_counter: int = 0
var gold_counter: int = 0
var monsters_defeated_counter: int = 0

const MOD_SPEED: int = 50

func _process(delta: float):
	if GameManager.is_game_over: return
	
	time_elapsed += delta
	time_elapsed_int = floori(time_elapsed)
	sec = time_elapsed_int%60
	min = floori(time_elapsed_int/60)
	time_elapsed_str = "%02d:%02d" % [min, sec]

func end_game():
	if is_game_over: return
	
	is_game_over = true
	game_over.emit()

func reset():
	is_game_over = false
	player_position = Vector2(0, 0)
	player_max_health = 0
	player_health = 0
	player = null
	game_ui = null
	
	time_elapsed = 0
	time_elapsed_int = 0
	min = 0
	sec = 0
	time_elapsed_str = "00:00"
	meat_counter = 0
	gold_counter = 0
	monsters_defeated_counter = 0
	
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
