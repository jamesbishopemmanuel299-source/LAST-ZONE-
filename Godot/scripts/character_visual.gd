extends MeshInstance3D
## Lightweight modern field-uniform avatar built from Android-friendly meshes.

var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var torso: MeshInstance3D
var elapsed := 0.0

func _ready() -> void:
    mesh = null
    var skin := _mat(Color(0.56, 0.43, 0.32), 0.0, 0.78)
    var camo := _mat(Color(0.25, 0.31, 0.22), 0.0, 0.92)
    var camo_light := _mat(Color(0.39, 0.42, 0.29), 0.0, 0.9)
    var vest := _mat(Color(0.13, 0.17, 0.14), 0.05, 0.8)
    var armor := _mat(Color(0.075, 0.095, 0.085), 0.12, 0.58)
    var boots := _mat(Color(0.035, 0.042, 0.038), 0.0, 0.72)
    var visor := _mat(Color(0.045, 0.075, 0.085), 0.35, 0.22)

    torso = _part("FieldUniform", CapsuleMesh.new(), Vector3(0, 1.12, 0), Vector3(0.78, 0.9, 0.48), camo)
    _part("TacticalVest", BoxMesh.new(), Vector3(0, 1.22, -0.235), Vector3(0.67, 0.62, 0.13), vest)
    _part("Helmet", SphereMesh.new(), Vector3(0, 1.98, 0.015), Vector3(0.43, 0.3, 0.4), camo_light)
    _part("HelmetBand", BoxMesh.new(), Vector3(0, 1.91, -0.01), Vector3(0.43, 0.06, 0.4), armor)
    _part("Face", SphereMesh.new(), Vector3(0, 1.77, -0.025), Vector3(0.29, 0.29, 0.3), skin)
    _part("ProtectiveGoggles", BoxMesh.new(), Vector3(0, 1.83, -0.17), Vector3(0.32, 0.09, 0.08), visor)
    for i in range(3):
        _part("VestPouch_%d" % i, BoxMesh.new(), Vector3(-0.22 + float(i) * 0.22, 1.08, -0.31), Vector3(0.16, 0.2, 0.11), armor)
    _part("Backpack", BoxMesh.new(), Vector3(0, 1.28, 0.27), Vector3(0.48, 0.56, 0.2), vest)

    left_arm = _limb("LeftArm", Vector3(-0.52, 1.35, 0), skin, camo, armor, boots)
    right_arm = _limb("RightArm", Vector3(0.52, 1.35, 0), skin, camo, armor, boots)
    left_leg = _leg("LeftLeg", Vector3(-0.2, 0.63, 0), camo, boots)
    right_leg = _leg("RightLeg", Vector3(0.2, 0.63, 0), camo, boots)

func _mat(color: Color, metal: float, rough: float) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metal
    m.roughness = rough
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

func _limb(label: String, at: Vector3, skin: Material, uniform: Material, armor: Material, boots: Material) -> Node3D:
    var pivot := Node3D.new()
    pivot.name = label
    pivot.position = at
    add_child(pivot)
    var sleeve := MeshInstance3D.new()
    var sleeve_mesh := CapsuleMesh.new()
    sleeve_mesh.radius = 0.14
    sleeve_mesh.height = 0.65
    sleeve.mesh = sleeve_mesh
    sleeve.material_override = uniform
    sleeve.position.y = -0.12
    pivot.add_child(sleeve)
    var elbow := MeshInstance3D.new()
    var elbow_mesh := SphereMesh.new()
    elbow_mesh.radius = 0.15
    elbow.mesh = elbow_mesh
    elbow.material_override = armor
    elbow.position = Vector3(0, -0.3, -0.015)
    pivot.add_child(elbow)
    var hand := MeshInstance3D.new()
    var hand_mesh := SphereMesh.new()
    hand_mesh.radius = 0.12
    hand.mesh = hand_mesh
    hand.material_override = skin
    hand.position.y = -0.48
    pivot.add_child(hand)
    return pivot

func _leg(label: String, at: Vector3, uniform: Material, boots: Material) -> Node3D:
    var pivot := Node3D.new()
    pivot.name = label
    pivot.position = at
    add_child(pivot)
    var leg := MeshInstance3D.new()
    var leg_mesh := CapsuleMesh.new()
    leg_mesh.radius = 0.17
    leg_mesh.height = 0.72
    leg.mesh = leg_mesh
    leg.material_override = uniform
    leg.position.y = -0.22
    pivot.add_child(leg)
    var knee_pad := MeshInstance3D.new()
    var pad_mesh := BoxMesh.new()
    pad_mesh.size = Vector3(0.27, 0.22, 0.12)
    knee_pad.mesh = pad_mesh
    knee_pad.material_override = boots
    knee_pad.position = Vector3(0, -0.28, -0.13)
    pivot.add_child(knee_pad)
    var shoe := MeshInstance3D.new()
    var shoe_mesh := BoxMesh.new()
    shoe_mesh.size = Vector3(0.32, 0.17, 0.43)
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
