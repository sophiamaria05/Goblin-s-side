class_name MobSpawner
extends Node2D

@onready var path_follow_2d = %PathFollow2D

@export var creatures: Array[PackedScene]
var mobs_cooldown: float

var cooldown: float = 0

func _process(delta):
	if GameManager.is_game_over: return
	
	
	cooldown -= delta
	if cooldown > 0: return
	cooldown = mobs_cooldown
	
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var paramaters = PhysicsPointQueryParameters2D.new()
	paramaters.position = point
	var result: Array = world_state.intersect_point(paramaters, 1)
	if not result.is_empty(): return
	
	var index = randi_range(0, creatures.size()-1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
