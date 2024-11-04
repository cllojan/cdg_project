extends Node3D

@onready var player = $Player
func _physics_process(delta: float) -> void:
	get_tree().call_group("enemy","update_target-location", player.global_transform.origin )
