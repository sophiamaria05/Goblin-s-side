class_name Player
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var sword_area: Area2D= $SwordArea

@export_category("Life")
@export var health_max: int = 100
@export var health: int = 100
@export var death_prefab: PackedScene
@export_category("Movement")
@export var speed = 4
@export var atk_speed_percent: float = 0.25
@export_range(0,1) var lerp_weight: float = 0.25
@export_category("Equipment")
@export var sword_damage = 2
@export_range(-1, 1) var dot_for_atk = -0.10
@export_category("Magic")
@export var magic_damage: int = 5
@export var magic_cure: int = 3
@export var magic_interval = 45
@export var magic_scene: PackedScene
@export_category("Regeneration")
@export var meat_regeneration_amount: int = 20



const MOD_SPEED = GameManager.MOD_SPEED
const DEADZONE = 0.15

var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var was_attacking: bool = false
var atk_cooldown: float = 0
var magic_cooldown: float = 0
var input_vector: Vector2 = Vector2(0, 0)
var target_velocity: Vector2 = Vector2(0, 0)

signal meat_collected()
signal meat_eaten()
signal gold_collected()

func _ready():
	GameManager.player = self
	GameManager.player_max_health = health_max
	GameManager.player_health = health
	
	meat_collected.connect(func(): GameManager.meat_counter+=1)
	meat_eaten.connect(func(): GameManager.meat_counter-=1)
	gold_collected.connect(func(): GameManager.gold_counter+=1)

func _process(delta: float) -> void:
	GameManager.player_position = position
	
	#Recive input from user
	get_input_vector()
	
	#Check horizontal flip
	if !is_attacking:
		rotate_sprite()
	
	#Try and execute attack
	atk_cooldown -= delta
	if atk_cooldown <= 0:
		if Input.is_action_just_pressed("_attack"):
			attack()
		elif is_attacking:
			is_attacking = false
			was_attacking = true
	
	#Process animation
	process_animation()
	
	#Try and execute magic
	magic_cooldown -= delta
	if magic_cooldown <= 0:
		if Input.is_action_just_pressed("_magic"):
			magic()
	
	#Eat meat
	if Input.is_action_just_pressed("_eat") and GameManager.meat_counter>0:
		meat_eaten.emit()
		heal(meat_regeneration_amount)

func _physics_process(_delta: float) -> void:
	target_velocity = input_vector * speed * MOD_SPEED
	if is_attacking:
		target_velocity *=atk_speed_percent
	velocity = lerp(velocity, target_velocity, lerp_weight)
	move_and_slide()

func get_input_vector() -> void:
	input_vector =  Input.get_vector("_left", "_right", "_up", "_down")
	remove_deadzone()

func remove_deadzone() -> void:
	if abs(input_vector.x) < DEADZONE:
		input_vector.x = 0
	if abs(input_vector.y) < DEADZONE:
		input_vector.y = 0

func process_animation():
	if !is_attacking:
		was_running = is_running
		is_running = not input_vector.is_zero_approx()
		
		if was_running != is_running or was_attacking:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
			was_attacking = false

func rotate_sprite() -> void:
	#Check horizontal flip
	if velocity.x < 0 and not sprite.is_flipped_h():
		sprite.set_flip_h(true)
	elif velocity.x > 0 and sprite.is_flipped_h():
		sprite.set_flip_h(false)

func attack() -> void:
	is_attacking = true
	atk_cooldown = 0.6
	var player_direction = player_direction()
	
	if player_direction == Vector2.UP:
		animation_player.play("atk_up")
	elif player_direction == Vector2.DOWN:
			animation_player.play("atk_down")
	else:
		animation_player.play("atk_side")

func player_direction() -> Vector2:
	if abs(velocity.y) > abs(velocity.x):
		if velocity.y < 0:
			return Vector2.UP
		else:
			return Vector2.DOWN
	else:
		if !sprite.is_flipped_h():
			return Vector2.LEFT
		else:
			return Vector2.RIGHT

func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy_direction = (position - body.position).normalized()
			var attack_direction = player_direction()
			var dot_product = enemy_direction.dot(attack_direction)
			if dot_product >= dot_for_atk:
				body.damage(sword_damage)

func heal(amount: int) -> int:
	health += amount
	GameManager.player_health = health
	if health > health_max:
		health = health_max
	return health

func magic() -> void:
	var magic_object = magic_scene.instantiate()
	magic_object.damage_amount = magic_damage
	magic_object.cure_amount = magic_cure
	self.add_child(magic_object)
	magic_cooldown = magic_interval

func damage(amount: int) -> void:
	health -= amount
	GameManager.player_health = health
	#print("Player:\nDamage: ", amount, "\nHealth: ", health, "\n")
	
	#Animate damage
	self.modulate = Color.html("fa276a")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#Process death
	if health <= 0:
		die()

func die() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = self.position
		get_parent().add_child(death_object)
	GameManager.end_game()
	queue_free()
