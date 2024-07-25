extends Node2D



func _ready():
	$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.player.meat_collected.emit()
		queue_free()
