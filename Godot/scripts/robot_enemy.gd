extends CharacterBody3D

# Lightweight autonomous security robot for LAST-ZONE.
# Uses primitive meshes and simple steering to keep Android performance stable.

@export var move_speed := 2.8
@export var detection_range := 24.0
@export var return_range := 34.0
@export var patrol_radius := 9.0
@export var max_health := 100.0

var health := 100.0
var player: Node3D
var patrol_origin := Vector3.ZERO
var patrol_target := Vector3.ZERO
var patrol_clock := 0.0
var attack_cooldown := 0.0
var body_mesh: MeshInstance3D
var eye_material: StandardMaterial3D
var status_label: Label3D

func _ready() -> void:
    health = max_health
    patrol_origin = get_meta("patrol_origin", global_position)
    patrol_target = patrol_origin
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.58
    shape.height = 2.1
    collision.shape = shape
    collision.position.y = 1.05
    add_child(collision)
    _build_robot()
    player = get_tree().get_first_node_in_group("player") as Node3D
    if player == null:
        player = get_tree().current_scene.get_node_or_null("Player") as Node3D

func _material(color: Color, glow: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = 0.72
    material.roughness = 0.32
    if glow:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 2.0
    return material

func _part(label: String, mesh_resource: PrimitiveMesh, at: Vector3, scale_value: Vector3, material: Material) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = label
    part.mesh = mesh_resource
    part.position = at
    part.scale = scale_value
    part.material_override = material
    add_child(part)
    return part

func _build_robot() -> void:
    var armor := _material(Color(0.16, 0.22, 0.29))
    var trim := _material(Color(0.34, 0.43, 0.51))
    eye_material = _material(Color(0.1, 0.85, 1.0), true)
    _part("ArmoredCore", BoxMesh.new(), Vector3(0, 1.22, 0), Vector3(0.95, 0.95, 0.55), armor)
    _part("ChestPlate", BoxMesh.new(), Vector3(0, 1.34, -0.29), Vector3(0.72, 0.55, 0.12), trim)
    _part("Head", BoxMesh.new(), Vector3(0, 1.98, 0), Vector3(0.62, 0.48, 0.5), armor)
    _part("Visor", BoxMesh.new(), Vector3(0, 2.0, -0.27), Vector3(0.48, 0.13, 0.06), eye_material)
    _part("LeftShoulder", SphereMesh.new(), Vector3(-0.62, 1.55, 0), Vector3(0.42, 0.42, 0.42), trim)
    _part("RightShoulder", SphereMesh.new(), Vector3(0.62, 1.55, 0), Vector3(0.42, 0.42, 0.42), trim)
    _part("LeftLeg", BoxMesh.new(), Vector3(-0.25, 0.48, 0), Vector3(0.25, 0.78, 0.32), armor)
    _part("RightLeg", BoxMesh.new(), Vector3(0.25, 0.48, 0), Vector3(0.25, 0.78, 0.32), armor)
    _part("LeftFoot", BoxMesh.new(), Vector3(-0.25, 0.12, -0.1), Vector3(0.34, 0.18, 0.5), trim)
    _part("RightFoot", BoxMesh.new(), Vector3(0.25, 0.12, -0.1), Vector3(0.34, 0.18, 0.5), trim)
    status_label = Label3D.new()
    status_label.text = "SECURITY BOT"
    status_label.position = Vector3(0, 2.65, 0)
    status_label.font_size = 32
    status_label.modulate = Color(0.55, 0.88, 1.0)
    add_child(status_label)

func _physics_process(delta: float) -> void:
    patrol_clock += delta
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    if player == null or not is_instance_valid(player):
        player = get_tree().current_scene.get_node_or_null("Player") as Node3D
    var target := patrol_origin + Vector3(
        cos(patrol_clock * 0.32) * patrol_radius,
        0.0,
        sin(patrol_clock * 0.32) * patrol_radius
    )
    var state_text := "PATROL"
    if player != null:
        var distance := global_position.distance_to(player.global_position)
        if distance <= detection_range:
            target = player.global_position
            state_text = "ALERT"
        elif distance >= return_range:
            target = patrol_origin
    var flat_target := Vector3(target.x, global_position.y, target.z)
    var offset := flat_target - global_position
    if offset.length() > 1.2:
        var direction := offset.normalized()
        velocity.x = direction.x * move_speed * (1.25 if state_text == "ALERT" else 1.0)
        velocity.z = direction.z * move_speed * (1.25 if state_text == "ALERT" else 1.0)
        look_at(global_position + Vector3(direction.x, 0.0, direction.z), Vector3.UP)
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 3.0)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * delta * 3.0)
    if not is_on_floor():
        velocity.y -= 9.8 * delta
    else:
        velocity.y = 0.0
    move_and_slide()
    if status_label != null:
        status_label.text = state_text + "  •  " + str(roundi(health)) + "%"
    if body_mesh != null:
        body_mesh.rotation.z = sin(patrol_clock * 5.0) * 0.025

func apply_damage(amount: float) -> void:
    if amount <= 0.0:
        return
    health = maxf(0.0, health - amount)
    if health <= 0.0:
        queue_free()
