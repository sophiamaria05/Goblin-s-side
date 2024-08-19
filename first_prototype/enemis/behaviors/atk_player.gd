extends Enemy

@export var atk_damage = 2
@export var atk_speed_percent: float = 0.25
@export var atk_cooldown: float = 1

var enemy: Enemy
var sprite: Sprite2D
var animation_player: AnimationPlayer
var atk_area: Area2D
var velocity: Vector2
var position: Vector2

const MOD_SPEED = GameManager.MOD_SPEED

var player_position: Vector2 = Vector2(0, 0)
var input_vector: Vector2 = Vector2(0,0)
var player_direction: Vector2
var is_attacking: bool = false
var was_attacking: bool = false
var cooldown: float = 0

func _ready() -> void:
	enemy = get_parent()
	sprite = enemy.get_node("Sprite2D")
	animation_player = enemy.get_node("AnimationPlayer")
	atk_area = enemy.get_node("AtkArea")
	velocity = enemy.velocity
	position = enemy.position

func _process(delta):
	if GameManager.is_game_over: return
	
	
	#Try and execute attack
	cooldown -= delta
	if cooldown <= atk_cooldown - animation_player.get_animation("atk_side").length:
		animation_player.play("run")
		if is_attacking:
			is_attacking = false
			was_attacking = true
		if cooldown <= 0:
			var bodies = atk_area.get_overlapping_bodies()
			for body in bodies:
				if body.is_in_group("player"):
					player_direction = (position - body.position).normalized()
					attack()

func attack() -> void:
	is_attacking = true
	cooldown = atk_cooldown
	animation_player.play("atk_side")

func deal_damage_to_enemies() -> void:
	var bodies = atk_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			var attack_direction = enemy_direction(player_direction)
			var dot_product = player_direction.dot(attack_direction)
			if dot_product >= 0:
				body.damage(atk_damage)

func enemy_direction(player_direction: Vector2) -> Vector2:
	if player_direction == Vector2.UP and animation_player.get_queue().has("atk_up"):
		animation_player.play("atk_up")
	elif player_direction == Vector2.DOWN and animation_player.get_queue().has("atk_down"):
		animation_player.play("atk_down")
	elif animation_player.get_queue().has("atk_side"):
		animation_player.play("atk_side")
	return player_position
