extends RigidBody3D

const SPEED = 20.0
var velocity = Vector3()
var gravity = Vector3(0,-9.8,0)
var initial_speed = 10.0
var direction = Vector3()
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var rig = $RigidBody3D

func _process(delta):
	velocity += gravity * delta
	translate(velocity * delta)
	rig.position += transform.basis * Vector3(0,0,-SPEED ) * delta
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	
