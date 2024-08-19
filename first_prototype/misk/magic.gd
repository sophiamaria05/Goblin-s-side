extends Node2D

@onready var area2d: Area2D = $Area2D

@export var damage_amount: int
@export var cure_amount: int

func _ready():
	$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.damage(damage_amount)

func heal_player():
	GameManager.player.heal(cure_amount)

'''
func deal_damage():
	var bodies = area2d.body_shape_entered()
	for body in bodies:
		if body.is_in_group("enemies"):
			body.damage(damage_amount)
'''
