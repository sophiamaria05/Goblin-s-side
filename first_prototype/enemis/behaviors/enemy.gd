class_name Enemy
extends Node

@export_category("Life")
@export var health: int = 10
@export var death_prefab: PackedScene
@export var hostil: bool = true
@export_category("Drops")
@export_range(0, 1) var drop_chance: float = 1
@export var drop_itens: Array[PackedScene]
@export var always_droped_itens: Array[PackedScene]
@export var drop_chances: Array[float]

@onready var damage_digit_prefab: PackedScene 
@onready var damage_digit_marker: Marker2D = $DamageDigitMarker

func _ready():
	damage_digit_prefab = preload("res://misk/damage_digit.tscn")

func damage(amount: int) -> void:
	health -= amount
	#print("Damage: ", amount, "\nHealth: ", health, "\n")
	
	#Animate damage
	self.modulate = Color.html("fa276a")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#Criar DamageDigit
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value =  amount 
	if damage_digit_marker:
		damage_digit.position =  damage_digit_marker.global_position
	else: 
		damage_digit.position = self.global_position
	get_parent().add_child(damage_digit)
	
	#Process death
	if health <= 0:
		die()

func die() -> void:
	#Caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = self.position
		get_parent().add_child(death_object)
	
	#Always droped itens
	
	
	#Random drop
	if drop_itens:
		if randf() <=drop_chance:
			drop_item()
	
	#GameManager monsters defeated
	if hostil:
		GameManager.monsters_defeated_counter+=1
	
	#Delete node
	queue_free()

func drop_item():
	if death_prefab:
		var drop_object = get_random_drop_item().instantiate()
		drop_object.position = self.position
		get_parent().add_child(drop_object)

func get_random_drop_item() -> PackedScene:
	if drop_itens.size() == 1:
		return drop_itens[0]
	
	
	var max_chance: float = 0
	for drop_chance_item in drop_chances:
		max_chance+=drop_chance_item
	
	var random_value = randf() * max_chance
	
	var needle:float = 0
	for i in drop_itens.size():
		var drop_item = drop_itens[i]
		var drop_chance_item = drop_chances[i] if drop_chances.size() > i else 1
		if random_value <= drop_chance_item + needle:
			return drop_item
		needle+=drop_chance_item
	return drop_itens[0]
