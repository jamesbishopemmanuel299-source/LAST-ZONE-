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
var performance_label: Label
var performance_timer := 0.0
var world_clock := 0.0
var collected_count := 0
var collectible_label: Label
var environment_ref: WorldEnvironment
var sun_ref: DirectionalLight3D
var weather_mode := 0
var map_panel: PanelContainer
var nearby_interaction: Area3D
var interaction_hint: Label
var interaction_button: Button
var riding_bike := false
var bike_root: Node3D

func _ready() -> void:
    _make_materials()
    _make_paths()
    _make_expanded_island()
    _make_landmarks()
    _make_district_details()
    _make_forest()
    _make_beacon()
    environment_ref = get_node_or_null("WorldEnvironment") as WorldEnvironment
    sun_ref = get_node_or_null("Sun") as DirectionalLight3D
    _make_hud()
    _make_exploration_systems()
    _make_interactables()

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

# Extra low-poly district dressing: recognizable landmarks without heavy asset packs.
func _make_district_details() -> void:
    var trim := _mat(Color(0.72, 0.57, 0.31))
    var sign_glow := _mat(Color(0.12, 0.68, 0.88), true)
    var concrete := _mat(Color(0.25, 0.29, 0.31))
    # Harbor market awnings and loading crates.
    for i in range(4):
        var x := 64.0 + float(i % 2) * 34.0
        var z := 88.0 + float(i / 2) * 8.0
        _box(self, "MarketAwning_%02d" % i, Vector3(x, 3.25, z), Vector3(6.0, 0.22, 3.0), trim)
        _box(self, "MarketCrate_%02d" % i, Vector3(x + 4.0, 0.65, z + 3.0), Vector3(1.2, 1.2, 1.2), wood_material, true)
    # District identity signs.
    _district_sign("HARBOR VILLAGE", Vector3(85, 0, 28), trim, sign_glow)
    _district_sign("RESEARCH CAMPUS", Vector3(-78, 0, -82), concrete, sign_glow)
    _district_sign("NORTH LOOKOUT", Vector3(-38, 0, -45), wood_material, sign_glow)
    # Roadside lamps help landmarks read clearly at a distance.
    for i in range(12):
        var side := -1.0 if i % 2 == 0 else 1.0
        var z := -132.0 + float(i) * 24.0
        var pole := _box(self, "RoadLampPole_%02d" % i, Vector3(12 + side * 7.0, 2.2, z), Vector3(0.18, 4.4, 0.18), dark_material)
        _box(self, "RoadLampHead_%02d" % i, Vector3(12 + side * 7.0, 4.45, z), Vector3(0.8, 0.18, 0.35), sign_glow)
    # Small boulders and shrubs create a more natural coastal edge.
    for i in range(24):
        var angle := TAU * float(i) / 24.0
        var radius := 190.0 + float(i % 3) * 2.0
        var rock := MeshInstance3D.new()
        var rock_mesh := SphereMesh.new()
        rock_mesh.radius = 1.0
        rock_mesh.height = 1.2
        rock.mesh = rock_mesh
        rock.material_override = stone_material
        rock.scale = Vector3(1.5, 0.75, 1.0)
        rock.position = Vector3(cos(angle) * radius, 0.45, sin(angle) * radius)
        add_child(rock)

func _district_sign(title_text: String, at: Vector3, base_material: Material, lettering: Material) -> void:
    _box(self, title_text.replace(" ", "") + "SignPost", at + Vector3(0, 1.5, 0), Vector3(0.22, 3.0, 0.22), base_material)
    _box(self, title_text.replace(" ", "") + "Board", at + Vector3(0, 2.7, 0), Vector3(5.8, 1.1, 0.18), base_material)
    _box(self, title_text.replace(" ", "") + "Marker", at + Vector3(0, 2.7, -0.11), Vector3(4.8, 0.12, 0.05), lettering)

func _make_cabin(at: Vector3, label: String) -> void:
    var building := Node3D.new()
    building.name = label
    add_child(building)
    building.position = at
    _box(building, "BackWall", Vector3(0, 1.6, 2.94), Vector3(7, 3.2, 0.12), wall_material, true)
    _box(building, "LeftWall", Vector3(-3.44, 1.6, 0), Vector3(0.12, 3.2, 6), wall_material, true)
    _box(building, "RightWall", Vector3(3.44, 1.6, 0), Vector3(0.12, 3.2, 6), wall_material, true)
    _box(building, "FrontLeftWall", Vector3(-2.45, 1.6, -2.94), Vector3(2.1, 3.2, 0.12), wall_material, true)
    _box(building, "FrontRightWall", Vector3(2.45, 1.6, -2.94), Vector3(2.1, 3.2, 0.12), wall_material, true)
    _box(building, "Floor", Vector3(0, 0.05, 0), Vector3(6.8, 0.12, 5.8), wood_material, true)
    _box(building, "InteriorDesk", Vector3(0, 0.8, 0.8), Vector3(2.2, 0.15, 0.9), wood_material, true)
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
    var crown_mesh := CylinderMesh.new()
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

    var signal_orb := MeshInstance3D.new()
    var signal_mesh := SphereMesh.new()
    signal_mesh.radius = 0.9
    signal_mesh.height = 1.8
    signal_orb.mesh = signal_mesh
    signal_orb.material_override = beacon_material
    signal_orb.position = Vector3(0, 4.0, -58)
    add_child(signal_orb)

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

    performance_label = Label.new()
    performance_label.position = Vector2(-190, 20)
    performance_label.anchor_left = 1.0
    performance_label.anchor_right = 1.0
    performance_label.add_theme_font_size_override("font_size", 14)
    performance_label.add_theme_color_override("font_color", Color(0.65, 0.9, 1.0))
    layer.add_child(performance_label)

    var objective := Label.new()
    objective.text = "OBJECTIVE  •  Reach the blue signal beacon"
    objective.position = Vector2(28, 54)
    objective.add_theme_font_size_override("font_size", 16)
    objective.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
    layer.add_child(objective)

    collectible_label = Label.new()
    collectible_label.text = "DISCOVERIES  " + str(collected_count) + " / 8"
    collectible_label.position = Vector2(28, 82)
    collectible_label.add_theme_font_size_override("font_size", 16)
    collectible_label.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
    layer.add_child(collectible_label)

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
    _make_menu(layer)

func _make_menu(layer: CanvasLayer) -> void:
    var shade := ColorRect.new()
    shade.name = "MenuShade"
    shade.color = Color(0.015, 0.035, 0.055, 0.88)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(shade)

    var panel := PanelContainer.new()
    panel.name = "MainMenu"
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-215, -285)
    panel.size = Vector2(430, 570)
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color(0.035, 0.075, 0.105, 0.98)
    panel_style.border_color = Color(0.16, 0.65, 0.9, 0.9)
    panel_style.set_border_width_all(2)
    panel_style.set_corner_radius_all(16)
    panel_style.content_margin_left = 24
    panel_style.content_margin_right = 24
    panel_style.content_margin_top = 22
    panel_style.content_margin_bottom = 22
    panel.add_theme_stylebox_override("panel", panel_style)
    layer.add_child(panel)

    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 14)
    panel.add_child(stack)

    var heading := Label.new()
    heading.text = "LAST-ZONE"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 34)
    heading.add_theme_color_override("font_color", Color(0.58, 0.86, 1.0))
    stack.add_child(heading)

    var subtitle := Label.new()
    subtitle.text = "ISLAND EXPEDITION  /  ANDROID"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 13)
    subtitle.add_theme_color_override("font_color", Color(0.75, 0.84, 0.91))
    stack.add_child(subtitle)

    var start_button := Button.new()
    start_button.text = "START EXPLORING"
    start_button.custom_minimum_size = Vector2(0, 54)
    start_button.add_theme_font_size_override("font_size", 18)
    start_button.pressed.connect(_start_game.bind(shade, panel))
    stack.add_child(start_button)

    var info := Label.new()
    info.text = "Explore the island with friends.\n\nWI-FI LAN MULTIPLAYER\nBoth phones must use the same Wi-Fi network.\nThe host shares the IP address shown below."
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.add_theme_font_size_override("font_size", 14)
    info.add_theme_color_override("font_color", Color(0.78, 0.85, 0.91))
    stack.add_child(info)

    var lobby_status := Label.new()
    lobby_status.name = "LobbyStatus"
    lobby_status.text = "OFFLINE SESSION"
    lobby_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lobby_status.add_theme_font_size_override("font_size", 12)
    lobby_status.add_theme_color_override("font_color", Color(0.55, 0.82, 0.96))
    stack.add_child(lobby_status)

    var host_button := Button.new()
    host_button.text = "HOST WI-FI GAME"
    host_button.custom_minimum_size = Vector2(0, 42)
    host_button.pressed.connect(_host_session.bind(lobby_status))
    stack.add_child(host_button)

    var address := LineEdit.new()
    address.name = "ServerAddress"
    address.placeholder_text = "Enter host Wi-Fi IP address"
    address.text = ""
    stack.add_child(address)

    var join_button := Button.new()
    join_button.text = "JOIN WI-FI GAME"
    join_button.custom_minimum_size = Vector2(0, 42)
    join_button.pressed.connect(_join_session.bind(address, lobby_status))
    stack.add_child(join_button)

    var map_button := Button.new()
    map_button.text = "ISLAND MAP & DISCOVERIES"
    map_button.custom_minimum_size = Vector2(0, 42)
    map_button.pressed.connect(_toggle_map.bind(layer))
    stack.add_child(map_button)

    var settings_button := Button.new()
    settings_button.text = "SETTINGS"
    settings_button.custom_minimum_size = Vector2(0, 42)
    settings_button.pressed.connect(_open_settings.bind(layer))
    stack.add_child(settings_button)

func _start_game(shade: ColorRect, panel: PanelContainer) -> void:
    shade.hide()
    panel.hide()


# Expanded island: distinct exploration regions, shoreline, roads and landmarks.
func _make_expanded_island() -> void:
    var sand := _mat(Color(0.58, 0.49, 0.32))
    var water := _mat(Color(0.035, 0.22, 0.31))
    var concrete := _mat(Color(0.30, 0.33, 0.34))
    var glass := _mat(Color(0.12, 0.48, 0.58), true)

    # Ocean surrounds the expanded landmass.
    var ocean := MeshInstance3D.new()
    var ocean_mesh := PlaneMesh.new()
    ocean_mesh.size = Vector2(560, 560)
    ocean.mesh = ocean_mesh
    ocean.material_override = water
    ocean.position = Vector3(0, -1.35, 0)
    add_child(ocean)

    # Sandy coastal strips frame the playable land.
    _box(self, "NorthBeach", Vector3(0, -0.02, -203), Vector3(410, 0.12, 12), sand)
    _box(self, "SouthBeach", Vector3(0, -0.02, 203), Vector3(410, 0.12, 12), sand)
    _box(self, "WestBeach", Vector3(-203, -0.02, 0), Vector3(12, 0.12, 410), sand)
    _box(self, "EastBeach", Vector3(203, -0.02, 0), Vector3(12, 0.12, 410), sand)

    # Main roads connect four named regions.
    _box(self, "WestEastRoad", Vector3(0, 0.025, 12), Vector3(330, 0.06, 8), dark_material)
    _box(self, "NorthSouthRoad", Vector3(12, 0.03, 0), Vector3(8, 0.06, 330), dark_material)
    _box(self, "HarborRoad", Vector3(105, 0.035, 120), Vector3(8, 0.07, 145), dark_material)
    _box(self, "HillRoad", Vector3(-105, 0.035, -105), Vector3(8, 0.07, 145), dark_material)

    # Village district.
    _make_cabin(Vector3(72, 0, 48), "HarborVillageHouseA")
    _make_cabin(Vector3(98, 0, 48), "HarborVillageHouseB")
    _make_cabin(Vector3(72, 0, 76), "HarborVillageHouseC")
    _make_cabin(Vector3(98, 0, 76), "HarborVillageHouseD")
    _box(self, "VillageSquare", Vector3(85, 0.04, 62), Vector3(18, 0.08, 18), concrete)
    _box(self, "HarborPier", Vector3(142, -0.05, 154), Vector3(9, 0.35, 46), wood_material, true)
    for i in range(6):
        _box(self, "PierPost", Vector3(138 + float(i % 2) * 8, 0.5, 135 + float(i) * 7), Vector3(0.65, 1.2, 0.65), wood_material)

    # Research campus and glass-roofed visitor centre.
    _box(self, "VisitorCentre", Vector3(-78, 2, -62), Vector3(22, 4, 16), wall_material, true)
    _box(self, "VisitorRoof", Vector3(-78, 4.2, -62), Vector3(24, 0.7, 18), roof_material)
    _box(self, "VisitorGlassFront", Vector3(-78, 2.1, -53.8), Vector3(13, 2.6, 0.18), glass)
    _box(self, "ResearchHall", Vector3(-118, 2.5, -70), Vector3(20, 5, 18), concrete, true)
    _box(self, "ResearchRoof", Vector3(-118, 5.2, -70), Vector3(22, 0.6, 20), roof_material)

    # Hills and rock formations use low-poly primitives.
    for i in range(14):
        var angle := float(i) * TAU / 14.0
        var ridge := MeshInstance3D.new()
        var ridge_mesh := SphereMesh.new()
        ridge_mesh.radius = 1.0
        ridge_mesh.height = 2.0
        ridge.mesh = ridge_mesh
        ridge.material_override = stone_material
        ridge.scale = Vector3(18.0 + float(i % 3) * 4.0, 7.0 + float(i % 4) * 1.5, 15.0)
        ridge.position = Vector3(cos(angle) * 158.0, 3.0, sin(angle) * 158.0)
        add_child(ridge)

    # Tree placements are deterministic and avoid the central roads.
    for i in range(110):
        var angle := float(i) * 2.399
        var radius := 78.0 + float(i % 8) * 13.0
        var tx := cos(angle) * radius
        var tz := sin(angle) * radius
        if absf(tx) < 24.0 or absf(tz) < 24.0:
            continue
        if absf(tx) > 190.0 or absf(tz) > 190.0:
            continue
        _make_tree(Vector3(tx, 0, tz), 0.85 + float(i % 5) * 0.1)

    # Scenic lighting at the harbour and visitor centre.
    for lamp_at in [Vector3(142, 4, 132), Vector3(85, 4, 62), Vector3(-78, 5, -62)]:
        var lamp := OmniLight3D.new()
        lamp.position = lamp_at
        lamp.light_color = Color(0.28, 0.68, 1.0)
        lamp.light_energy = 0.7
        lamp.omni_range = 12.0
        lamp.shadow_enabled = false
        add_child(lamp)


func _host_session(status: Label) -> void:
    var network = get_node_or_null("/root/SessionNetwork")
    if network == null:
        status.text = "NETWORK SERVICE UNAVAILABLE"
        return
    var result: int = network.host_session()
    status.text = "WI-FI HOST READY • " + network.get_local_ipv4() + ":7777" if result == OK else "HOST FAILED • ERROR " + str(result)

func _join_session(address: LineEdit, status: Label) -> void:
    var network = get_node_or_null("/root/SessionNetwork")
    if network == null:
        status.text = "NETWORK SERVICE UNAVAILABLE"
        return
    var result: int = network.join_session(address.text.strip_edges())
    status.text = "CONNECTING OVER WI-FI TO " + address.text if result == OK else "CONNECTION FAILED • ERROR " + str(result)

func _open_settings(layer: CanvasLayer) -> void:
    if layer.get_node_or_null("SettingsPanel") != null:
        layer.get_node("SettingsPanel").queue_free()
        return
    var panel := PanelContainer.new()
    panel.name = "SettingsPanel"
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-190, -150)
    panel.size = Vector2(380, 300)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.025, 0.055, 0.08, 0.98)
    style.border_color = Color(0.18, 0.62, 0.88)
    style.set_border_width_all(2)
    style.set_corner_radius_all(14)
    style.content_margin_left = 22
    style.content_margin_right = 22
    style.content_margin_top = 18
    style.content_margin_bottom = 18
    panel.add_theme_stylebox_override("panel", style)
    layer.add_child(panel)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 14)
    panel.add_child(stack)
    var heading := Label.new()
    heading.text = "GAME SETTINGS"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 23)
    stack.add_child(heading)
    var quality := OptionButton.new()
    quality.add_item("LOW • Battery saver", 0)
    quality.add_item("MEDIUM • Balanced", 1)
    quality.add_item("HIGH • Visual quality", 2)
    quality.select(1)
    quality.item_selected.connect(_apply_quality)
    stack.add_child(quality)
    var hint := Label.new()
    hint.text = "Lower quality reduces lighting and visual effects to help older Android phones."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stack.add_child(hint)
    var close := Button.new()
    close.text = "CLOSE SETTINGS"
    close.pressed.connect(panel.queue_free)
    stack.add_child(close)

func _apply_quality(index: int) -> void:
    var sun := get_node_or_null("Sun")
    if sun is DirectionalLight3D:
        sun.shadow_enabled = index == 2
    var environment_node := get_node_or_null("WorldEnvironment")
    if environment_node is WorldEnvironment and environment_node.environment:
        environment_node.environment.glow_enabled = index == 2
        environment_node.environment.fog_enabled = index != 0


func _process(delta: float) -> void:
    world_clock += delta * 0.003
    if sun_ref != null:
        sun_ref.rotation_degrees.x = -28.0 - sin(world_clock) * 35.0
        sun_ref.light_energy = 0.55 + (0.7 * maxf(0.0, sin(world_clock)))
    performance_timer += delta
    if performance_timer >= 0.5 and is_instance_valid(performance_label):
        performance_timer = 0.0
        performance_label.text = str(Engine.get_frames_per_second()) + " FPS"

# Exploration layer: saved discoveries, map, waypoint guidance and weather.
func _make_exploration_systems() -> void:
    _load_progress()
    var sites := [
        Vector3(25, 1.1, -18), Vector3(-28, 1.1, 12),
        Vector3(-78, 1.1, -62), Vector3(-118, 1.1, -70),
        Vector3(85, 1.1, 62), Vector3(142, 1.1, 154),
        Vector3(-38, 1.1, -34), Vector3(0, 1.1, -58)
    ]
    for i in range(sites.size()):
        _make_discovery(i, sites[i])
    _make_weather_button()

func _make_discovery(index: int, at: Vector3) -> void:
    if _is_discovered(index):
        return
    var area := Area3D.new()
    area.name = "Discovery_" + str(index)
    area.position = at
    var orb := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.55
    mesh.height = 1.1
    orb.mesh = mesh
    orb.material_override = _mat(Color(0.25, 0.82, 1.0), true)
    area.add_child(orb)
    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 1.5
    collision.shape = shape
    area.add_child(collision)
    area.body_entered.connect(_on_discovery_entered.bind(index, area))
    add_child(area)

func _on_discovery_entered(body: Node3D, index: int, area: Area3D) -> void:
    if body.name != "Player" or _is_discovered(index):
        return
    var config := ConfigFile.new()
    config.load("user://last_zone_save.cfg")
    config.set_value("discoveries", str(index), true)
    config.save("user://last_zone_save.cfg")
    collected_count += 1
    if is_instance_valid(collectible_label):
        collectible_label.text = "DISCOVERIES  " + str(collected_count) + " / 8"
    area.queue_free()

func _is_discovered(index: int) -> bool:
    var config := ConfigFile.new()
    config.load("user://last_zone_save.cfg")
    return bool(config.get_value("discoveries", str(index), false))

func _load_progress() -> void:
    collected_count = 0
    var config := ConfigFile.new()
    config.load("user://last_zone_save.cfg")
    for i in range(8):
        if bool(config.get_value("discoveries", str(i), false)):
            collected_count += 1

func _toggle_map(layer: CanvasLayer) -> void:
    if is_instance_valid(map_panel):
        map_panel.queue_free()
        map_panel = null
        return
    map_panel = PanelContainer.new()
    map_panel.name = "IslandMap"
    map_panel.set_anchors_preset(Control.PRESET_CENTER)
    map_panel.position = Vector2(-220, -190)
    map_panel.size = Vector2(440, 380)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.025, 0.07, 0.1, 0.98)
    style.border_color = Color(0.2, 0.7, 0.95)
    style.set_border_width_all(2)
    style.set_corner_radius_all(14)
    style.content_margin_left = 20
    style.content_margin_right = 20
    style.content_margin_top = 18
    style.content_margin_bottom = 18
    map_panel.add_theme_stylebox_override("panel", style)
    layer.add_child(map_panel)
    var stack := VBoxContainer.new()
    map_panel.add_child(stack)
    var title := Label.new()
    title.text = "ISLAND FIELD GUIDE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 23)
    stack.add_child(title)
    var guide := Label.new()
    guide.text = "NORTH  •  Signal Beacon & Lookout Tower\nWEST  •  Visitor Centre & Research Hall\nEAST  •  Harbor Village & Pier\nSOUTH  •  Coastal Trail & Forest\n\nDiscoveries: " + str(collected_count) + " / 8\nProgress saves automatically on this device."
    guide.add_theme_font_size_override("font_size", 16)
    guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stack.add_child(guide)
    var close := Button.new()
    close.text = "CLOSE MAP"
    close.pressed.connect(func():
        map_panel.queue_free()
        map_panel = null
    )
    stack.add_child(close)

func _make_weather_button() -> void:
    var layer := get_node_or_null("ExpeditionHUD") as CanvasLayer
    if layer == null:
        return
    var button := Button.new()
    button.text = "WEATHER: CLEAR"
    button.position = Vector2(28, 112)
    button.custom_minimum_size = Vector2(170, 38)
    button.pressed.connect(func():
        weather_mode = (weather_mode + 1) % 3
        if weather_mode == 0:
            button.text = "WEATHER: CLEAR"
            if environment_ref and environment_ref.environment:
                environment_ref.environment.fog_enabled = true
                environment_ref.environment.fog_density = 0.003
        elif weather_mode == 1:
            button.text = "WEATHER: MIST"
            if environment_ref and environment_ref.environment:
                environment_ref.environment.fog_enabled = true
                environment_ref.environment.fog_density = 0.012
        else:
            button.text = "WEATHER: CLEAR AIR"
            if environment_ref and environment_ref.environment:
                environment_ref.environment.fog_enabled = false
    )
    layer.add_child(button)



# Enterable house and motorcycle interaction points.
func _make_interactables() -> void:
    var layer := get_node_or_null("ExpeditionHUD") as CanvasLayer
    if layer == null:
        return
    interaction_hint = Label.new()
    interaction_hint.name = "InteractionHint"
    interaction_hint.anchor_left = 0.5
    interaction_hint.anchor_right = 0.5
    interaction_hint.anchor_top = 1.0
    interaction_hint.anchor_bottom = 1.0
    interaction_hint.offset_left = -180
    interaction_hint.offset_right = 180
    interaction_hint.offset_top = -118
    interaction_hint.offset_bottom = -84
    interaction_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    interaction_hint.add_theme_font_size_override("font_size", 16)
    interaction_hint.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
    layer.add_child(interaction_hint)

    interaction_button = Button.new()
    interaction_button.name = "InteractButton"
    interaction_button.text = "INTERACT"
    interaction_button.anchor_left = 1.0
    interaction_button.anchor_right = 1.0
    interaction_button.anchor_top = 1.0
    interaction_button.anchor_bottom = 1.0
    interaction_button.offset_left = -184
    interaction_button.offset_right = -24
    interaction_button.offset_top = -182
    interaction_button.offset_bottom = -116
    interaction_button.custom_minimum_size = Vector2(160, 58)
    interaction_button.visible = false
    interaction_button.pressed.connect(_use_interaction)
    layer.add_child(interaction_button)

    _add_interaction_area("HOUSE_ENTRY", Vector3(25, 1.0, -22.0), Vector3(3.8, 2.5, 2.2), "ENTER HOUSE", "house_enter")
    _add_interaction_area("HOUSE_EXIT", Vector3(25, 1.0, -16.0), Vector3(3.8, 2.5, 2.2), "EXIT HOUSE", "house_exit")
    _make_motorcycle(Vector3(7, 0.0, 5.0))

func _add_interaction_area(label: String, at: Vector3, dimensions: Vector3, prompt: String, action: String) -> void:
    var area := Area3D.new()
    area.name = label
    area.position = at
    area.set_meta("prompt", prompt)
    area.set_meta("action", action)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = dimensions
    collision.shape = shape
    area.add_child(collision)
    area.body_entered.connect(_on_interaction_entered.bind(area))
    area.body_exited.connect(_on_interaction_exited.bind(area))
    add_child(area)

func _make_motorcycle(at: Vector3) -> void:
    bike_root = Node3D.new()
    bike_root.name = "FrontierMotorcycle"
    bike_root.position = at
    add_child(bike_root)
    var frame := _mat(Color(0.82, 0.25, 0.07), true)
    var rubber := _mat(Color(0.025, 0.03, 0.035))
    var metal := _mat(Color(0.48, 0.53, 0.57))
    var seat := _mat(Color(0.075, 0.065, 0.055))
    for z in [-1.05, 1.05]:
        var wheel := MeshInstance3D.new()
        var wheel_mesh := CylinderMesh.new()
        wheel_mesh.top_radius = 0.48
        wheel_mesh.bottom_radius = 0.48
        wheel_mesh.height = 0.2
        wheel.mesh = wheel_mesh
        wheel.material_override = rubber
        wheel.rotation_degrees.z = 90
        wheel.position = Vector3(0, 0.52, z)
        bike_root.add_child(wheel)
        var hub := MeshInstance3D.new()
        var hub_mesh := CylinderMesh.new()
        hub_mesh.top_radius = 0.16
        hub_mesh.bottom_radius = 0.16
        hub_mesh.height = 0.23
        hub.mesh = hub_mesh
        hub.material_override = metal
        hub.rotation_degrees.z = 90
        hub.position = Vector3(0, 0.52, z)
        bike_root.add_child(hub)
    _bike_box("BikeFrame", Vector3(0, 0.9, 0), Vector3(0.32, 0.3, 1.55), frame)
    _bike_box("FuelTank", Vector3(0, 1.18, -0.05), Vector3(0.72, 0.48, 0.8), frame)
    _bike_box("Seat", Vector3(0, 1.22, 0.63), Vector3(0.55, 0.18, 0.72), seat)
    _bike_box("Handlebar", Vector3(0, 1.48, -0.82), Vector3(1.0, 0.08, 0.12), metal)
    _bike_box("Headlight", Vector3(0, 1.25, -0.56), Vector3(0.36, 0.3, 0.12), _mat(Color(0.6, 0.88, 1.0), true))
    var area := Area3D.new()
    area.name = "MotorcycleInteraction"
    area.position = Vector3(0, 1.0, 0)
    area.set_meta("prompt", "RIDE MOTORCYCLE")
    area.set_meta("action", "bike_enter")
    var collision := CollisionShape3D.new()
    var sphere := SphereShape3D.new()
    sphere.radius = 3.0
    collision.shape = sphere
    area.add_child(collision)
    area.body_entered.connect(_on_interaction_entered.bind(area))
    area.body_exited.connect(_on_interaction_exited.bind(area))
    bike_root.add_child(area)

func _bike_box(label: String, at: Vector3, dimensions: Vector3, material: Material) -> void:
    var item := MeshInstance3D.new()
    item.name = label
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    item.mesh = mesh
    item.material_override = material
    item.position = at
    bike_root.add_child(item)

func _on_interaction_entered(body: Node3D, area: Area3D) -> void:
    if body.name != "Player":
        return
    nearby_interaction = area
    _refresh_interaction_prompt()

func _on_interaction_exited(body: Node3D, area: Area3D) -> void:
    if body.name != "Player":
        return
    if nearby_interaction == area:
        nearby_interaction = null
        _refresh_interaction_prompt()

func _refresh_interaction_prompt() -> void:
    var active := is_instance_valid(nearby_interaction)
    if is_instance_valid(interaction_button):
        interaction_button.visible = active
        if active:
            interaction_button.text = str(nearby_interaction.get_meta("prompt", "INTERACT"))
    if is_instance_valid(interaction_hint):
        interaction_hint.text = (str(nearby_interaction.get_meta("prompt", "")) + "  •  TAP / E") if active else ""

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact") and not event.is_echo():
        _use_interaction()

func _use_interaction() -> void:
    if not is_instance_valid(nearby_interaction):
        return
    var action := str(nearby_interaction.get_meta("action", ""))
    var player := get_node_or_null("Player") as CharacterBody3D
    if player == null:
        return
    match action:
        "house_enter":
            player.global_position = Vector3(25, 0.95, -20.0)
        "house_exit":
            player.global_position = Vector3(25, 0.95, -24.8)
        "bike_enter":
            if riding_bike:
                return
            riding_bike = true
            player.global_position = bike_root.global_position + Vector3(0, 0.95, 0)
            player.call("set_vehicle_mode", true)
            nearby_interaction.set_meta("prompt", "LEAVE MOTORCYCLE")
            nearby_interaction.set_meta("action", "bike_exit")
        "bike_exit":
            riding_bike = false
            player.global_position = bike_root.global_position + Vector3(2.0, 0.95, 0)
            player.call("set_vehicle_mode", false)
            nearby_interaction.set_meta("prompt", "RIDE MOTORCYCLE")
            nearby_interaction.set_meta("action", "bike_enter")
    _refresh_interaction_prompt()


# Spawn exactly the bot count selected in the match lobby.
func configure_bots(requested_count: int) -> void:
    var bot_count := clampi(requested_count, 1, 20)
    for existing in get_tree().get_nodes_in_group("match_bots"):
        if is_instance_valid(existing):
            existing.queue_free()
    var bot_script := load("res://scripts/robot_enemy.gd")
    if bot_script == null:
        push_error("Bot script could not be loaded: res://scripts/robot_enemy.gd")
        return
    var player := get_node_or_null("Player") as Node3D
    var center := Vector3.ZERO
    if player != null:
        center = player.global_position
    for index in range(bot_count):
        var angle := TAU * float(index) / float(bot_count)
        var radius := 13.0 + float(index % 3) * 3.0
        var spawn_position := center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
        var bot := CharacterBody3D.new()
        bot.name = "MatchBot_%02d" % (index + 1)
        bot.set_script(bot_script)
        bot.position = spawn_position
        bot.set_meta("patrol_origin", spawn_position)
        bot.add_to_group("match_bots")
        add_child(bot)
    print("LAST-ZONE match started with ", bot_count, " bots")

func _spawn_robot_patrols() -> void:
    var robot_script := load("res://scripts/robot_enemy.gd")
    if robot_script == null:
        push_warning("Robot enemy script could not be loaded.")
        return
    var patrol_points := [
        Vector3(38, 0.0, -28),
        Vector3(52, 0.0, -20),
        Vector3(68, 0.0, -34),
        Vector3(-42, 0.0, 42),
        Vector3(-58, 0.0, 28),
        Vector3(12, 0.0, 68)
    ]
    for index in range(patrol_points.size()):
        var robot := CharacterBody3D.new()
        robot.name = "IslandSecurityRobot_%02d" % (index + 1)
        robot.set_script(robot_script)
        robot.position = patrol_points[index]
        robot.set_meta("patrol_origin", patrol_points[index])
        add_child(robot)
