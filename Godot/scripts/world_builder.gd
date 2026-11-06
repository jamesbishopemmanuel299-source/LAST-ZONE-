extends Node3D

# Lightweight procedural scenery for the Android prototype.
# Built from primitive meshes so the project needs no large external assets.

var grass_material: StandardMaterial3D
var dark_material: StandardMaterial3D
var wall_material: StandardMaterial3D
var roof_material: StandardMaterial3D
var wood_material: StandardMaterial3D
var leaf_material: StandardMaterial3D
var stone_material: StandardMaterial3D
var beacon_material: StandardMaterial3D

func _ready() -> void:
    _make_materials()
    _make_paths()
    _make_landmarks()
    _make_forest()
    _make_beacon()
    _make_hud()

func _make_materials() -> void:
    grass_material = _mat(Color(0.16, 0.31, 0.19))
    dark_material = _mat(Color(0.075, 0.095, 0.11))
    wall_material = _mat(Color(0.48, 0.39, 0.27))
    roof_material = _mat(Color(0.12, 0.17, 0.21))
    wood_material = _mat(Color(0.25, 0.15, 0.085))
    leaf_material = _mat(Color(0.09, 0.25, 0.15))
    stone_material = _mat(Color(0.31, 0.34, 0.36))
    beacon_material = _mat(Color(0.12, 0.72, 1.0), true)

func _mat(color: Color, glow: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.92
    if glow:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 1.6
    return material

func _box(parent: Node3D, label: String, at: Vector3, dimensions: Vector3, material: Material, solid: bool = false) -> Node3D:
    var holder: Node3D
    if solid:
        var body := StaticBody3D.new()
        body.name = label
        parent.add_child(body)
        holder = body
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = dimensions
        collision.shape = shape
        body.add_child(collision)
    else:
        holder = Node3D.new()
        holder.name = label
        parent.add_child(holder)

    holder.position = at
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    holder.add_child(mesh_instance)
    return holder

func _make_paths() -> void:
    _box(self, "NorthTrail", Vector3(0, 0.015, -24), Vector3(7, 0.04, 58), dark_material)
    _box(self, "EastTrail", Vector3(23, 0.02, 4), Vector3(48, 0.04, 5), dark_material)
    _box(self, "SouthTrail", Vector3(-16, 0.02, 28), Vector3(5, 0.04, 48), dark_material)
    for index in range(12):
        var marker_z := -48.0 + float(index) * 8.0
        _box(self, "TrailMarker", Vector3(0, 0.08, marker_z), Vector3(0.22, 0.08, 1.1), _mat(Color(0.72, 0.67, 0.48)))

func _make_cabin(at: Vector3, label: String) -> void:
    var building := Node3D.new()
    building.name = label
    add_child(building)
    building.position = at
    _box(building, "Walls", Vector3(0, 1.6, 0), Vector3(7, 3.2, 6), wall_material, true)
    _box(building, "Roof", Vector3(0, 3.45, 0), Vector3(8, 0.55, 7), roof_material, false)
    _box(building, "Door", Vector3(0, 0.95, -3.04), Vector3(1.15, 1.9, 0.12), wood_material, false)
    _box(building, "WindowLeft", Vector3(-2.15, 1.9, -3.08), Vector3(1.0, 0.9, 0.12), beacon_material, false)
    _box(building, "WindowRight", Vector3(2.15, 1.9, -3.08), Vector3(1.0, 0.9, 0.12), beacon_material, false)

func _make_landmarks() -> void:
    _make_cabin(Vector3(25, 0, -18), "RangerStation")
    _make_cabin(Vector3(-28, 0, 12), "ForestCabin")
    _box(self, "LookoutTower", Vector3(-38, 4, -34), Vector3(3.2, 8, 3.2), wood_material, true)
    _box(self, "LookoutDeck", Vector3(-38, 8.2, -34), Vector3(6, 0.45, 6), roof_material)
    for corner in [Vector3(-40.3, 10, -36.3), Vector3(-35.7, 10, -36.3), Vector3(-40.3, 10, -31.7), Vector3(-35.7, 10, -31.7)]:
        _box(self, "TowerPost", corner, Vector3(0.25, 4, 0.25), wood_material)

func _make_tree(at: Vector3, scale_factor: float = 1.0) -> void:
    var tree := Node3D.new()
    add_child(tree)
    tree.position = at
    tree.scale = Vector3.ONE * scale_factor

    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.28
    trunk_mesh.bottom_radius = 0.42
    trunk_mesh.height = 3.1
    trunk.mesh = trunk_mesh
    trunk.material_override = wood_material
    trunk.position.y = 1.55
    tree.add_child(trunk)

    var crown := MeshInstance3D.new()
    var crown_mesh := ConeMesh.new()
    crown_mesh.top_radius = 0.0
    crown_mesh.bottom_radius = 2.0
    crown_mesh.height = 4.3
    crown.mesh = crown_mesh
    crown.material_override = leaf_material
    crown.position.y = 4.0
    tree.add_child(crown)

func _make_forest() -> void:
    for index in range(30):
        var angle := float(index) * 2.399
        var radius := 28.0 + float(index % 6) * 5.2
        var x := cos(angle) * radius
        var z := sin(angle) * radius
        if absf(x) < 13.0 and absf(z) < 13.0:
            continue
        _make_tree(Vector3(x, 0, z), 0.8 + float(index % 4) * 0.12)

    for index in range(14):
        var x := -52.0 + float((index * 17) % 104)
        var z := -50.0 + float((index * 29) % 100)
        if absf(x) < 14.0 and absf(z) < 14.0:
            continue
        var rock := MeshInstance3D.new()
        var rock_mesh := SphereMesh.new()
        rock_mesh.radius = 1.0 + float(index % 3) * 0.35
        rock_mesh.height = 1.2 + float(index % 3) * 0.4
        rock.mesh = rock_mesh
        rock.material_override = stone_material
        rock.position = Vector3(x, 0.55, z)
        rock.rotation_degrees = Vector3(float(index * 13), float(index * 31), 0)
        add_child(rock)

func _make_beacon() -> void:
    var base := MeshInstance3D.new()
    var base_mesh := CylinderMesh.new()
    base_mesh.top_radius = 1.1
    base_mesh.bottom_radius = 1.5
    base_mesh.height = 3.2
    base.mesh = base_mesh
    base.material_override = dark_material
    base.position = Vector3(0, 1.6, -58)
    add_child(base)

    var signal := MeshInstance3D.new()
    var signal_mesh := SphereMesh.new()
    signal_mesh.radius = 0.9
    signal_mesh.height = 1.8
    signal.mesh = signal_mesh
    signal.material_override = beacon_material
    signal.position = Vector3(0, 4.0, -58)
    add_child(signal)

    var light := OmniLight3D.new()
    light.position = Vector3(0, 5.0, -58)
    light.light_color = Color(0.15, 0.65, 1.0)
    light.light_energy = 1.8
    light.omni_range = 13.0
    light.shadow_enabled = false
    add_child(light)

func _make_hud() -> void:
    var layer := CanvasLayer.new()
    layer.name = "ExpeditionHUD"
    add_child(layer)

    var title := Label.new()
    title.text = "LAST-ZONE  /  ISLAND EXPEDITION"
    title.position = Vector2(26, 20)
    title.add_theme_font_size_override("font_size", 22)
    title.add_theme_color_override("font_color", Color(0.72, 0.91, 1.0))
    layer.add_child(title)

    var objective := Label.new()
    objective.text = "OBJECTIVE  •  Reach the blue signal beacon"
    objective.position = Vector2(28, 54)
    objective.add_theme_font_size_override("font_size", 16)
    objective.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
    layer.add_child(objective)

    var controls := Label.new()
    controls.text = "LEFT: MOVE     RIGHT: LOOK     JUMP: UP BUTTON     SPRINT: RUN"
    controls.anchor_left = 0.0
    controls.anchor_top = 1.0
    controls.anchor_right = 1.0
    controls.anchor_bottom = 1.0
    controls.offset_left = 24
    controls.offset_top = -38
    controls.offset_right = -24
    controls.offset_bottom = -12
    controls.add_theme_font_size_override("font_size", 14)
    controls.add_theme_color_override("font_color", Color(0.82, 0.89, 0.96))
    layer.add_child(controls)

    var reticle := Label.new()
    reticle.text = "+"
    reticle.set_anchors_preset(Control.PRESET_CENTER)
    reticle.position = Vector2(-7, -13)
    reticle.add_theme_font_size_override("font_size", 24)
    reticle.add_theme_color_override("font_color", Color(0.75, 0.91, 1.0, 0.85))
    layer.add_child(reticle)
