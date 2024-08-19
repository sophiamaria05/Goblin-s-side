extends Enemy

@export var speed: float = 2
@export_range(0, 1) var lerp_weight = 0.25

const MOD_SPEED = GameManager.MOD_SPEED

var sprite: Sprite2D
var enemy: Enemy
var danger_area: Area2D
var alert_area: Area2D
var animation_player: AnimationPlayer
var player_position: Vector2 = Vector2(0, 0)
var input_vector: Vector2 = Vector2(0,0)
var target_velocity: Vector2 = Vector2(0, 0)
var is_running: bool = false
var danger: bool = false

func _ready() -> void:
	enemy = get_parent()
	sprite = enemy.get_node("Sprite2D")
	danger_area = enemy.get_node("DangerArea")
	alert_area = enemy.get_node("AlertArea")
	animation_player = enemy.get_node("AnimationPlayer")

func _physics_process(_delta: float) -> void:
	if GameManager.is_game_over:
		enemy.velocity = Vector2(0, 0)
		enemy.move_and_slide()
		return
	
	
	if !is_running:
		var bodies = danger_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				#Start running
				run(true)
				is_running = true
		if !is_running:
			run(false)
	else:
		danger = false
		var bodies = alert_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				danger = true
		if !danger:
			#Stop running
			run(false)
			is_running = false
		else:
			run(true)

func run(run: bool) -> void:
	if run:
		if animation_player.current_animation != "run":
			animation_player.play("run")
		
		player_position = GameManager.player_position
		input_vector = (enemy.position - player_position).normalized()
		target_velocity = input_vector * speed * MOD_SPEED
		enemy.velocity = lerp(enemy.velocity, target_velocity, lerp_weight)
		enemy.move_and_slide()
		
		#Check horizontal flip
		if enemy.velocity.x < 0 and not sprite.is_flipped_h():
			sprite.set_flip_h(true)
		elif enemy.velocity.x > 0 and sprite.is_flipped_h():
			sprite.set_flip_h(false)
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		
		enemy.velocity = lerp(enemy.velocity, Vector2(0, 0), lerp_weight)
		enemy.move_and_slide()
