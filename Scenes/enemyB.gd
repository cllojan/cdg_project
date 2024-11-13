extends CharacterBody3D

var player = null
@onready var nav_agent = %NavigationAgent3D
@onready var anim_enemy = %AnimationEnemy
@export var player_path: NodePath
@onready var hitbox = $HitboxComponent
var raycast = null # RayCast3D aún no referenciado

@export var receives_knockback: bool = true
@export var knockback_modifier: float = 0.1

var SPEED = 3.0
var player_in_sight = false # Variable para saber si el jugador está en la vista del enemigo

func _ready() -> void:    
	player = get_node(player_path)
	raycast = $RayCast3D # Asegúrate de que esta ruta es correcta

	if raycast == null:
		print("Error: RayCast3D no encontrado. Revisa la ruta.")

func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	check_player_in_sight() # Verifica si el jugador está en la vista

	if player_in_sight:
		# Solo sigue al jugador si está en su campo de visión
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()

# Función para verificar si el RayCast3D está detectando al jugador
func check_player_in_sight() -> void:
	if raycast == null:
		print("No regristra")
		return
	
	raycast.force_raycast_update() # Actualiza el raycast

	# Verifica si el raycast está colisionando con el jugador
	if raycast.is_colliding() and raycast.get_collider() == player:
		player_in_sight = true
	else:
		player_in_sight = false

func _on_navigation_agent_3d_target_reached() -> void:
	anim_enemy.play("attack")    

func _on_animation_enemy_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		anim_enemy.play('idle_enemy')    

func knockback(playerVel: Vector3, damage: int):
	if damage: 
		var knockback_direction = playerVel.direction_to(self.global_position)
		var knockback_stregth = damage * knockback_modifier
		var knockback = knockback_direction * knockback_stregth
		self.global_position += knockback
	
func _on_hitbox_component_area_entered(area: Area3D) -> void:
	print("hit uwu")
	knockback(hitbox.global_position, 100)

func _on_ray_cast_3d_visibility_changed() -> void:
	check_player_in_sight()
