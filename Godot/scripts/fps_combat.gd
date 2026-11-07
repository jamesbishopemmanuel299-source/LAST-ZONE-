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
var hit_marker: Label
var damage_overlay: ColorRect
var muzzle_light: OmniLight3D
var weapon_label: Label
var weapon_index := 0
var weapon_names := ["RIFLE", "SMG"]

func _ready() -> void:
    ammo = magazine_size
    var arm := get_parent().get_node_or_null("SpringArm3D") as SpringArm3D
    if arm != null:
        camera = arm.get_node_or_null("Camera3D") as Camera3D
    var visual := get_parent().get_node_or_null("Visual")
    if visual != null:
        visual.hide()
    player_health = get_parent().get_node_or_null("PlayerHealth")
    if player_health != null and player_health.has_signal("health_changed"):
        player_health.health_changed.connect(_on_health_changed)
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
    var grip := MeshInstance3D.new()
    var grip_mesh := BoxMesh.new()
    grip_mesh.size = Vector3(0.11, 0.22, 0.14)
    grip.mesh = grip_mesh
    grip.position = Vector3(0, -0.16, -0.02)
    grip.rotation.x = -0.18
    grip.material_override = _mat(Color(0.055, 0.065, 0.07), 0.05)
    weapon_root.add_child(grip)
    var magazine := MeshInstance3D.new()
    var magazine_mesh := BoxMesh.new()
    magazine_mesh.size = Vector3(0.12, 0.28, 0.17)
    magazine.mesh = magazine_mesh
    magazine.position = Vector3(0, -0.2, 0.18)
    magazine.rotation.x = -0.18
    magazine.material_override = _mat(Color(0.12, 0.15, 0.13), 0.18)
    weapon_root.add_child(magazine)
    muzzle_light = OmniLight3D.new()
    muzzle_light.position = Vector3(0, 0.015, -0.72)
    muzzle_light.light_color = Color(1.0, 0.68, 0.28)
    muzzle_light.light_energy = 0.0
    muzzle_light.omni_range = 3.2
    muzzle_light.shadow_enabled = false
    weapon_root.add_child(muzzle_light)

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
    hit_marker = Label.new()
    hit_marker.text = "×"
    hit_marker.set_anchors_preset(Control.PRESET_CENTER)
    hit_marker.position = Vector2(-12, -25)
    hit_marker.add_theme_font_size_override("font_size", 42)
    hit_marker.add_theme_color_override("font_color", Color(1.0, 0.22, 0.2, 0.0))
    layer.add_child(hit_marker)
    damage_overlay = ColorRect.new()
    damage_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    damage_overlay.color = Color(0.8, 0.015, 0.025, 0.0)
    layer.add_child(damage_overlay)
    damage_overlay.show_behind_parent = true
    weapon_label = Label.new()
    weapon_label.position = Vector2(26, 48)
    weapon_label.add_theme_font_size_override("font_size", 18)
    weapon_label.add_theme_color_override("font_color", Color(0.35, 0.82, 1.0))
    layer.add_child(weapon_label)
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
    fire_button = _make_button(layer, "SHOOT", Vector2(1080, 500), Vector2(150, 86))
    fire_button.button_down.connect(_start_firing)
    fire_button.button_up.connect(_stop_firing)
    reload_button = _make_button(layer, "RELOAD", Vector2(1080, 610), Vector2(125, 54))
    reload_button.pressed.connect(_begin_reload)
    aim_button = _make_button(layer, "AIM", Vector2(930, 515), Vector2(112, 62))
    aim_button.toggle_mode = true
    aim_button.toggled.connect(_set_aim)
    var jump_button := _make_button(layer, "JUMP", Vector2(1100, 390), Vector2(105, 58))
    _bind_hold_action(jump_button, "jump")
    var sprint_button := _make_button(layer, "SPRINT", Vector2(940, 390), Vector2(120, 58))
    _bind_hold_action(sprint_button, "sprint")
    var switch_button := _make_button(layer, "SWITCH", Vector2(930, 610), Vector2(120, 54))
    switch_button.pressed.connect(_switch_weapon)
    var forward_button := _make_button(layer, "▲", Vector2(104, 450), Vector2(64, 54))
    _bind_hold_action(forward_button, "move_forward")
    var back_button := _make_button(layer, "▼", Vector2(104, 575), Vector2(64, 54))
    _bind_hold_action(back_button, "move_back")
    var left_button := _make_button(layer, "◀", Vector2(34, 512), Vector2(64, 54))
    _bind_hold_action(left_button, "move_left")
    var right_button := _make_button(layer, "▶", Vector2(174, 512), Vector2(64, 54))
    _bind_hold_action(right_button, "move_right")
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
    Input.action_press("fire")

func _stop_firing() -> void:
    Input.action_release("fire")

func _bind_hold_action(button: Button, action_name: String) -> void:
    button.button_down.connect(func(): Input.action_press(action_name))
    button.button_up.connect(func(): Input.action_release(action_name))

func _switch_weapon() -> void:
    weapon_index = (weapon_index + 1) % weapon_names.size()
    if weapon_index == 0:
        magazine_size = 30
        damage_per_shot = 34.0
        fire_interval = 0.12
    else:
        magazine_size = 40
        damage_per_shot = 22.0
        fire_interval = 0.075
    ammo = mini(ammo, magazine_size)
    reserve_ammo = 120 if weapon_index == 0 else 160
    _refresh_hud()

func _fire() -> void:
    if reloading or fire_timer > 0.0 or (player_health != null and player_health.defeated):
        return
    if ammo <= 0:
        status_label.text = "MAGAZINE EMPTY — RELOAD"
        return
    ammo -= 1
    fire_timer = fire_interval
    if muzzle_light != null:
        muzzle_light.light_energy = 2.8
        var flash_tween := create_tween()
        flash_tween.tween_property(muzzle_light, "light_energy", 0.0, 0.075)
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
        status_label.text = "TARGET HIT"
        _show_hit_marker()
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
        ammo_label.text = "%s   %02d / %03d" % [weapon_names[weapon_index], ammo, reserve_ammo]
    if weapon_label != null:
        weapon_label.text = "LOADOUT  /  " + weapon_names[weapon_index]
    if status_label != null and not reloading:
        status_label.text = "READY  •  " + ("AIMING" if aiming else "HIP FIRE")

func _show_hit_marker() -> void:
    if hit_marker == null:
        return
    hit_marker.add_theme_color_override("font_color", Color(1.0, 0.22, 0.18, 1.0))
    var tween := create_tween()
    tween.tween_interval(0.12)
    tween.tween_callback(func():
        if is_instance_valid(hit_marker):
            hit_marker.add_theme_color_override("font_color", Color(1.0, 0.22, 0.18, 0.0))
    )

func _on_health_changed(current_health: float, maximum_health: float) -> void:
    if damage_overlay == null:
        return
    if current_health < maximum_health:
        damage_overlay.color = Color(0.78, 0.015, 0.025, 0.2)
        var tween := create_tween()
        tween.tween_property(damage_overlay, "color", Color(0.78, 0.015, 0.025, 0.0), 0.32)
