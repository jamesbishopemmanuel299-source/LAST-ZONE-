extends Node

signal health_changed(current_health: float, maximum_health: float)

@export var max_health := 100.0
@export var respawn_delay := 3.0

var health := 100.0
var defeated := false
var spawn_position := Vector3.ZERO

func _ready() -> void:
    health = max_health
    var player := get_parent() as Node3D
    if player != null:
        spawn_position = player.global_position
    health_changed.emit(health, max_health)

func take_damage(amount: float) -> void:
    if amount <= 0.0 or defeated:
        return
    health = maxf(0.0, health - amount)
    health_changed.emit(health, max_health)
    if health <= 0.0:
        _respawn()

func restore_health(amount: float) -> void:
    if amount <= 0.0 or defeated:
        return
    health = minf(max_health, health + amount)
    health_changed.emit(health, max_health)

func _respawn() -> void:
    defeated = true
    var player := get_parent() as Node3D
    if player != null:
        player.set_physics_process(false)
    await get_tree().create_timer(respawn_delay).timeout
    if not is_inside_tree():
        return
    if player != null and is_instance_valid(player):
        player.global_position = spawn_position
        if player is CharacterBody3D:
            (player as CharacterBody3D).velocity = Vector3.ZERO
        player.set_physics_process(true)
    health = max_health
    defeated = false
    health_changed.emit(health, max_health)
