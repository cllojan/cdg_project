extends CharacterBody3D

# SPEED MOVEMENT
var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 10.0
# JUMP 
const JUMP_VELOCITY = 5.0

#SENSITIVITY
const SENSITIVITY = 0.003

#BOB MOVEMENT
const BOB_FREQ =2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

#gravity 
var gravity =9.8


@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var anim_player = $AnimationPlayer
@onready var hitbox = %HitBox
@onready var WeaponCamera = %WeaponCamera
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _process(delta: float) -> void:
	WeaponCamera.global_transform = camera.global_transform
	if Input.is_action_just_pressed("attack"):
		anim_player.play("attack")
		
		hitbox.monitoring = true
				
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))
		
func knockback(k: Knockback):
	velocity += (global_transform.origin - k.knockback_origin).normalized() * k.knockback_force
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta	
	if Input.is_action_just_pressed('jump') and is_on_floor():
		velocity.y = JUMP_VELOCITY
	#sprint	
	if Input.is_action_pressed('sprint'):
		speed = SPRINT_SPEED
	else: 
		speed = WALK_SPEED
		
	var input_dir = Input.get_vector('left','right','up','down') 
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		
		if direction: 
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else: 
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	
	move_and_slide()
	
	#head bob	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#fov 
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta* 8.0)
	
	


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		anim_player.play('idle_state')
		hitbox.monitoring = false

				

func _on_hit_box_area_entered(area: Area3D) -> void:
	
	if area is HitboxComponent:	
		var hitbox: HitboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = 100.0
		attack.knockback_force = 100.0
		hitbox.damage(attack)
