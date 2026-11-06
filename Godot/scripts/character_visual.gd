extends MeshInstance3D

# Lightweight procedural explorer avatar with a simple walk/run cycle.
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var torso: MeshInstance3D
var elapsed := 0.0

func _ready() -> void:
    mesh = null
    var skin := _material(Color(0.78, 0.57, 0.39))
    var jacket := _material(Color(0.08, 0.28, 0.42))
    var trousers := _material(Color(0.12, 0.16, 0.21))
    var boots := _material(Color(0.045, 0.055, 0.07))

    torso = _part("Torso", CapsuleMesh.new(), Vector3(0, 1.12, 0), Vector3(0.78, 0.9, 0.42), jacket)
    _part("Head", SphereMesh.new(), Vector3(0, 1.88, 0), Vector3(0.38, 0.42, 0.36), skin)
    _part("Hair", SphereMesh.new(), Vector3(0, 2.04, 0.015), Vector3(0.39, 0.18, 0.37), boots)

    left_arm = _limb("LeftArm", Vector3(-0.52, 1.35, 0), skin, jacket)
    right_arm = _limb("RightArm", Vector3(0.52, 1.35, 0), skin, jacket)
    left_leg = _leg("LeftLeg", Vector3(-0.2, 0.63, 0), trousers, boots)
    right_leg = _leg("RightLeg", Vector3(0.2, 0.63, 0), trousers, boots)

func _material(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.88
    return m

func _part(label: String, shape: PrimitiveMesh, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
    var item := MeshInstance3D.new()
    item.name = label
    item.mesh = shape
    item.position = at
    item.scale = size
    item.material_override = material
    add_child(item)
    return item

func _limb(label: String, at: Vector3, skin: Material, jacket: Material) -> Node3D:
    var pivot := Node3D.new()
    pivot.name = label
    pivot.position = at
    add_child(pivot)
    var sleeve := MeshInstance3D.new()
    var sleeve_mesh := CapsuleMesh.new()
    sleeve_mesh.radius = 0.13
    sleeve_mesh.height = 0.62
    sleeve.mesh = sleeve_mesh
    sleeve.material_override = jacket
    sleeve.position.y = -0.12
    pivot.add_child(sleeve)
    var hand := MeshInstance3D.new()
    var hand_mesh := SphereMesh.new()
    hand_mesh.radius = 0.13
    hand.mesh = hand_mesh
    hand.material_override = skin
    hand.position.y = -0.48
    pivot.add_child(hand)
    return pivot

func _leg(label: String, at: Vector3, trousers: Material, boots: Material) -> Node3D:
    var pivot := Node3D.new()
    pivot.name = label
    pivot.position = at
    add_child(pivot)
    var leg := MeshInstance3D.new()
    var leg_mesh := CapsuleMesh.new()
    leg_mesh.radius = 0.16
    leg_mesh.height = 0.7
    leg.mesh = leg_mesh
    leg.material_override = trousers
    leg.position.y = -0.22
    pivot.add_child(leg)
    var shoe := MeshInstance3D.new()
    var shoe_mesh := BoxMesh.new()
    shoe_mesh.size = Vector3(0.3, 0.16, 0.42)
    shoe.mesh = shoe_mesh
    shoe.material_override = boots
    shoe.position = Vector3(0, -0.55, -0.08)
    pivot.add_child(shoe)
    return pivot

func _process(delta: float) -> void:
    elapsed += delta
    var moving := Input.get_vector("move_left", "move_right", "move_forward", "move_back").length() > 0.12
    var sprinting := Input.is_action_pressed("sprint")
    var speed := 10.0 if sprinting else 7.0
    var swing := sin(elapsed * speed) * (0.72 if moving else 0.035)
    left_leg.rotation.x = swing
    right_leg.rotation.x = -swing
    left_arm.rotation.x = -swing * 0.72
    right_arm.rotation.x = swing * 0.72
    if torso:
        torso.position.y = 1.12 + (absf(sin(elapsed * speed * 2.0)) * 0.035 if moving else 0.0)
