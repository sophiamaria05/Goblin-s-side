extends Enemy

@export var speed: float = 2

var enemy: Enemy
var sprite: Sprite2D

const MOD_SPEED = GameManager.MOD_SPEED

var player_position: Vector2 = Vector2(0, 0)
var input_vector: Vector2 = Vector2(0,0)

func _ready() -> void:
	enemy = get_parent()
	sprite = enemy.get_node("Sprite2D")

func _physics_process(_delta: float) -> void:
	if GameManager.is_game_over:
		enemy.velocity = Vector2(0, 0)
		enemy.move_and_slide()
		return
	
	
	player_position = GameManager.player_position
	input_vector = (player_position - enemy.position).normalized()
	enemy.velocity = input_vector * speed * MOD_SPEED
	enemy.move_and_slide()
	
	#Check horizontal flip
	if enemy.velocity.x < 0 and not sprite.is_flipped_h():
		sprite.set_flip_h(true)
	elif enemy.velocity.x > 0 and sprite.is_flipped_h():
		sprite.set_flip_h(false)
