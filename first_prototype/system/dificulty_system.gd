extends Node

@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 30
@export var increasse_spawn_rate_per_min: float = 30
@export var wave_duration: float = 60
@export var break_intensity: float = 0.5

var time: float =0

func _process(delta):
	if GameManager.is_game_over: return
	
	
	time+=delta
	var linear_spawn_rate = initial_spawn_rate + (increasse_spawn_rate_per_min * (time/60))
	
	var sin_wave = sin((time*TAU)/wave_duration)
	var wave_factor = remap(sin_wave, -1, 1, break_intensity, 1)
	
	var spawn_rate = linear_spawn_rate * wave_factor
	
	mob_spawner.mobs_cooldown = 60/spawn_rate
