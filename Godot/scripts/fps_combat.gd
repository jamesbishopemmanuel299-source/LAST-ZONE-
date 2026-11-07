extends Node

# Mobile-first FPS controls and hitscan practice weapon for LAST-ZONE.
@export var magazine_size := 30
@export var reserve_ammo := 120
@export var damage_per_shot := 34.0
@export var fire_interval := 0.12
@export var reload_duration := 1.6
@export var weapon_range := 110.0

var ammo := 30
var fire_timer := 0.0
var reload_timer := 0.0
var reloading := false
var aiming := false
var camera: Camera3D
var ammo_label: Label
var status_label: Label
var health_label: Label
var player_health: Node
var fire_button: Button
var reload_button: Button
var aim_button: Button
var weapon_root: Node3D

func _ready() -> void:
    ammo = magazine_size
    var arm := get_parent().get_node_or_null("SpringArm3D") as SpringArm3D
    if arm != null:
        camera = arm.get_node_or_null("Camera3D") as Camera3D
    var visual := get_parent().get_node_or_null("Visual")
    if visual != null:
        visual.hide()
    player_health = get_parent().get_node_or_null("PlayerHealth")
    _setup_input()
    _build_weapon()
    _build_hud()

func _setup_input() -> void:
    if not InputMap.has_action("fire"):
        InputMap.add_action("fire")
        var mouse := InputEventMouseButton.new()
        mouse.button_index = MOUSE_BUTTON_LEFT
        InputMap.action_add_event("fire", mouse)
    if not InputMap.has_action("reload"):
        InputMap.add_action("reload")
        var key := InputEventKey.new()
        key.physical_keycode = KEY_R
        InputMap.action_add_event("reload", key)
    if not InputMap.has_action("aim"):
        InputMap.add_action("aim")

func _build_weapon() -> void:
    if camera == null:
        return
    weapon_root = Node3D.new()
    weapon_root.name = "TrainingRifle"
    weapon_root.position = Vector3(0.32, -0.27, -0.48)
    camera.add_child(weapon_root)
    var body := MeshInstance3D.new()
    var body_mesh := BoxMesh.new()
    body_mesh.size = Vector3(0.16, 0.18, 0.62)
    body.mesh = body_mesh
    body.material_override = _mat(Color(0.075, 0.095, 0.12), 0.35)
    weapon_root.add_child(body)
    var barrel := MeshInstance3D.new()
    var barrel_mesh := CylinderMesh.new()
    barrel_mesh.top_radius = 0.035
    barrel_mesh.bottom_radius = 0.045
    barrel_mesh.height = 0.38
    barrel.mesh = barrel_mesh
    barrel.rotation.x = PI / 2.0
    barrel.position.z = -0.43
    barrel.material_override = _mat(Color(0.24, 0.29, 0.34), 0.6)
    weapon_root.add_child(barrel)
    var sight := MeshInstance3D.new()
    var sight_mesh := BoxMesh.new()
    sight_mesh.size = Vector3(0.08, 0.06, 0.12)
    sight.mesh = sight_mesh
    sight.position = Vector3(0, 0.12, -0.08)
    sight.material_override = _mat(Color(0.1, 0.72, 0.95), 0.2)
    weapon_root.add_child(sight)

func _mat(color: Color, metal: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metal
    material.roughness = 0.38
    return material

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    layer.name = "CombatHUD"
    get_tree().current_scene.add_child(layer)
    var crosshair := Label.new()
    crosshair.text = "+"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.position = Vector2(-8, -18)
    crosshair.add_theme_font_size_override("font_size", 30)
    crosshair.add_theme_color_override("font_color", Color(0.45, 0.92, 1.0))
    layer.add_child(crosshair)
    ammo_label = Label.new()
    ammo_label.position = Vector2(26, 118)
    ammo_label.add_theme_font_size_override("font_size", 20)
    ammo_label.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0))
    layer.add_child(ammo_label)
    health_label = Label.new()
    health_label.position = Vector2(26, 86)
    health_label.add_theme_font_size_override("font_size", 20)
    health_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.65))
    layer.add_child(health_label)
    status_label = Label.new()
    status_label.position = Vector2(26, 148)
    status_label.add_theme_font_size_override("font_size", 14)
    status_label.add_theme_color_override("font_color", Color(0.45, 0.85, 1.0))
    layer.add_child(status_label)
    fire_button = _make_button(layer, "FIRE", Vector2(1090, 500), Vector2(150, 76))
    fire_button.button_down.connect(_start_firing)
    fire_button.button_up.connect(_stop_firing)
    reload_button = _make_button(layer, "RELOAD", Vector2(1010, 600), Vector2(125, 54))
    reload_button.pressed.connect(_begin_reload)
    aim_button = _make_button(layer, "AIM", Vector2(1150, 600), Vector2(90, 54))
    aim_button.toggle_mode = true
    aim_button.toggled.connect(_set_aim)
    _refresh_hud()

func _make_button(layer: CanvasLayer, caption: String, at: Vector2, size: Vector2) -> Button:
    var button := Button.new()
    button.text = caption
    button.position = at
    button.size = size
    button.add_theme_font_size_override("font_size", 18)
    button.add_theme_color_override("font_color", Color(0.92, 0.97, 1.0))
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.035, 0.12, 0.19, 0.88)
    style.border_color = Color(0.12, 0.68, 0.92, 0.95)
    style.set_border_width_all(2)
    style.set_corner_radius_all(12)
    button.add_theme_stylebox_override("normal", style)
    button.add_theme_stylebox_override("hover", style)
    button.add_theme_stylebox_override("pressed", style)
    layer.add_child(button)
    return button

func _process(delta: float) -> void:
    fire_timer = maxf(0.0, fire_timer - delta)
    if health_label != null and player_health != null:
        health_label.text = "PLAYER HP  %03d / %03d" % [roundi(player_health.health), roundi(player_health.max_health)]
    if reloading:
        reload_timer -= delta
        if reload_timer <= 0.0:
            var needed := magazine_size - ammo
            var loaded := mini(needed, reserve_ammo)
            ammo += loaded
            reserve_ammo -= loaded
            reloading = false
            _refresh_hud()
    if Input.is_action_just_pressed("reload"):
        _begin_reload()
    if Input.is_action_pressed("fire") and fire_timer <= 0.0:
        _fire()
    if camera != null:
        camera.fov = lerpf(camera.fov, 57.0 if aiming else 82.0, minf(delta * 12.0, 1.0))
    if weapon_root != null:
        weapon_root.position.x = lerpf(weapon_root.position.x, 0.25 if aiming else 0.32, minf(delta * 10.0, 1.0))

func _start_firing() -> void:
    _fire()
    if not InputMap.has_action("fire_touch"):
        InputMap.add_action("fire_touch")

func _stop_firing() -> void:
    pass

func _fire() -> void:
    if reloading or fire_timer > 0.0 or (player_health != null and player_health.defeated):
        return
    if ammo <= 0:
        status_label.text = "MAGAZINE EMPTY — RELOAD"
        return
    ammo -= 1
    fire_timer = fire_interval
    _refresh_hud()
    if camera == null:
        return
    var origin := camera.global_position
    var end := origin + (-camera.global_transform.basis.z * weapon_range)
    var query := PhysicsRayQueryParameters3D.create(origin, end)
    query.exclude = [get_parent().get_rid()]
    query.collide_with_areas = true
    var world_3d: World3D = get_viewport().world_3d
    if world_3d == null:
        status_label.text = "WORLD PHYSICS UNAVAILABLE"
        return
    var hit: Dictionary = world_3d.direct_space_state.intersect_ray(query)
    if hit.is_empty():
        status_label.text = "SHOT FIRED"
        return
    var target: Object = hit.get("collider")
    if target != null and target.has_method("apply_damage"):
        target.call("apply_damage", damage_per_shot)
        status_label.text = "TARGET HIT  •  -" + str(roundi(damage_per_shot)) + " HP"
    else:
        status_label.text = "IMPACT"

func _begin_reload() -> void:
    if reloading or ammo >= magazine_size or reserve_ammo <= 0:
        return
    reloading = true
    reload_timer = reload_duration
    status_label.text = "RELOADING..."
    _refresh_hud()

func _set_aim(enabled: bool) -> void:
    aiming = enabled

func _refresh_hud() -> void:
    if ammo_label != null:
        ammo_label.text = "RIFLE   %02d / %03d" % [ammo, reserve_ammo]
    if status_label != null and not reloading:
        status_label.text = "READY  •  " + ("AIMING" if aiming else "HIP FIRE")
