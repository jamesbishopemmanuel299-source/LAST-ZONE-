extends Node3D
## LAST-ZONE visual pass: mobile-scaled PBR materials, atmosphere, weather and set dressing.

@export_enum("LOW", "BALANCED", "HIGH") var quality := 1
var weather_particles: GPUParticles3D
var smoke_particles: GPUParticles3D

func _ready() -> void:
    call_deferred("_apply_visual_upgrade")

func _apply_visual_upgrade() -> void:
    _upgrade_environment()
    _upgrade_sun()
    _upgrade_ground()
    _add_weather()
    _add_fire_effect()
    _add_environmental_detail()
    _apply_quality(quality)

func _upgrade_environment() -> void:
    var world := get_node_or_null("WorldEnvironment") as WorldEnvironment
    if world == null or world.environment == null:
        return
    var env := world.environment
    var sky := Sky.new()
    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color(0.055, 0.16, 0.29)
    sky_material.sky_horizon_color = Color(0.48, 0.63, 0.72)
    sky_material.ground_bottom_color = Color(0.055, 0.075, 0.07)
    sky_material.ground_horizon_color = Color(0.31, 0.38, 0.36)
    sky_material.sun_angle_max = 18.0
    sky.sky_material = sky_material
    env.background_mode = Environment.BG_SKY
    env.sky = sky
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.tonemap_exposure = 1.08
    env.tonemap_white = 5.0
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.48, 0.57, 0.68)
    env.ambient_light_energy = 0.72
    env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
    env.glow_enabled = true
    env.glow_intensity = 0.32
    env.glow_strength = 0.55
    env.glow_bloom = 0.08
    env.adjustment_enabled = true
    env.adjustment_brightness = 1.02
    env.adjustment_contrast = 1.08
    env.adjustment_saturation = 1.12
    env.fog_enabled = true
    env.fog_light_color = Color(0.38, 0.48, 0.58)
    env.fog_density = 0.0022
    env.fog_sky_affect = 0.35

func _upgrade_sun() -> void:
    var sun := get_node_or_null("Sun") as DirectionalLight3D
    if sun == null:
        return
    sun.light_color = Color(1.0, 0.91, 0.79)
    sun.light_energy = 1.15
    sun.shadow_enabled = true
    sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
    sun.directional_shadow_max_distance = 75.0
    sun.shadow_bias = 0.035
    sun.shadow_normal_bias = 1.4

func _upgrade_ground() -> void:
    var ground_mesh := get_node_or_null("Ground/Mesh") as MeshInstance3D
    if ground_mesh == null:
        return
    var ground_mat := StandardMaterial3D.new()
    ground_mat.albedo_color = Color(0.19, 0.24, 0.19)
    ground_mat.roughness = 0.82
    ground_mat.metallic = 0.02
    ground_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    ground_mesh.material_override = ground_mat

func _add_weather() -> void:
    weather_particles = GPUParticles3D.new()
    weather_particles.name = "RainWeather"
    weather_particles.amount = 420
    weather_particles.lifetime = 1.8
    weather_particles.explosiveness = 0.0
    weather_particles.visibility_aabb = AABB(Vector3(-70, -30, -70), Vector3(140, 90, 140))
    var rain_process := ParticleProcessMaterial.new()
    rain_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    rain_process.emission_box_extents = Vector3(48, 22, 48)
    rain_process.direction = Vector3(-0.12, -1.0, -0.08)
    rain_process.spread = 5.0
    rain_process.initial_velocity_min = 15.0
    rain_process.initial_velocity_max = 22.0
    rain_process.gravity = Vector3(0, -3.0, 0)
    rain_process.scale_min = 0.025
    rain_process.scale_max = 0.045
    rain_process.color = Color(0.63, 0.77, 0.9, 0.45)
    weather_particles.process_material = rain_process
    var rain_mesh := BoxMesh.new()
    rain_mesh.size = Vector3(0.012, 0.22, 0.012)
    weather_particles.draw_pass_1 = rain_mesh
    weather_particles.position = Vector3(0, 14, 0)
    add_child(weather_particles)
    weather_particles.set_meta("weather_active", false)
    weather_particles.emitting = false

    smoke_particles = GPUParticles3D.new()
    smoke_particles.name = "DistantAmbientSmoke"
    smoke_particles.amount = 34
    smoke_particles.lifetime = 8.0
    smoke_particles.preprocess = 4.0
    smoke_particles.visibility_aabb = AABB(Vector3(-12, -2, -12), Vector3(24, 24, 24))
    var smoke_process := ParticleProcessMaterial.new()
    smoke_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    smoke_process.emission_box_extents = Vector3(2.0, 0.5, 2.0)
    smoke_process.direction = Vector3(0.1, 1.0, 0.0)
    smoke_process.spread = 22.0
    smoke_process.initial_velocity_min = 0.4
    smoke_process.initial_velocity_max = 1.4
    smoke_process.gravity = Vector3(0, -0.08, 0)
    smoke_process.scale_min = 0.8
    smoke_process.scale_max = 2.1
    smoke_process.color = Color(0.25, 0.29, 0.32, 0.32)
    smoke_particles.process_material = smoke_process
    var smoke_mesh := SphereMesh.new()
    smoke_mesh.radius = 0.55
    smoke_mesh.height = 1.1
    smoke_particles.draw_pass_1 = smoke_mesh
    smoke_particles.position = Vector3(-18, 1, -24)
    add_child(smoke_particles)
    smoke_particles.emitting = true

func _add_environmental_detail() -> void:
    var concrete := _pbr(Color(0.29, 0.32, 0.34), 0.05, 0.86)
    var dark_metal := _pbr(Color(0.075, 0.09, 0.105), 0.72, 0.3)
    var rust := _pbr(Color(0.28, 0.16, 0.095), 0.32, 0.76)
    var glass := _pbr(Color(0.16, 0.36, 0.43), 0.42, 0.18)
    _detail_box("DamagedConcreteA", Vector3(8, 0.7, -14), Vector3(3.2, 1.4, 0.55), concrete, true)
    _detail_box("DamagedConcreteB", Vector3(-8, 0.55, -18), Vector3(2.5, 1.1, 0.5), concrete, true)
    _detail_box("SteelContainer", Vector3(13, 1.1, -28), Vector3(5.0, 2.2, 2.4), dark_metal, true)
    _detail_box("WeatheredCrateA", Vector3(-5, 0.55, -10), Vector3(1.4, 1.1, 1.3), rust, true)
    _detail_box("WeatheredCrateB", Vector3(-3.7, 0.45, -10.4), Vector3(1.0, 0.9, 0.95), rust, true)
    _detail_box("GlassPanel", Vector3(18, 1.4, -22), Vector3(0.12, 2.8, 2.6), glass, false)
    for i in range(7):
        var shard := MeshInstance3D.new()
        var shard_mesh := BoxMesh.new()
        shard_mesh.size = Vector3(0.16 + float(i % 3) * 0.1, 0.025, 0.35 + float(i % 2) * 0.2)
        shard.mesh = shard_mesh
        shard.material_override = glass
        shard.position = Vector3(-12.0 + float(i) * 1.2, 0.035, -7.0 - float(i % 3) * 0.7)
        shard.rotation.y = float(i) * 0.63
        add_child(shard)

    var warm_light := OmniLight3D.new()
    warm_light.name = "WarmEnvironmentalBounce"
    warm_light.position = Vector3(-18, 5, -24)
    warm_light.light_color = Color(1.0, 0.48, 0.22)
    warm_light.light_energy = 1.1
    warm_light.omni_range = 18.0
    warm_light.shadow_enabled = false
    add_child(warm_light)

func _detail_box(label: String, at: Vector3, dimensions: Vector3, material: Material, collision: bool) -> void:
    var holder: Node3D
    if collision:
        var body := StaticBody3D.new()
        body.name = label
        add_child(body)
        holder = body
        var shape := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = dimensions
        shape.shape = box_shape
        body.add_child(shape)
    else:
        holder = Node3D.new()
        holder.name = label
        add_child(holder)
    holder.position = at
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    holder.add_child(mesh_instance)

func _pbr(color: Color, metal: float, rough: float) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metal
    mat.roughness = rough
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    return mat

func _apply_quality(level: int) -> void:
    quality = clampi(level, 0, 2)
    var sun := get_node_or_null("Sun") as DirectionalLight3D
    var world := get_node_or_null("WorldEnvironment") as WorldEnvironment
    if sun:
        sun.shadow_enabled = quality >= 1
        sun.directional_shadow_max_distance = 88.0 if quality >= 2 else 42.0
        sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS if quality >= 2 else DirectionalLight3D.SHADOW_ORTHOGONAL
    if world and world.environment:
        world.environment.glow_enabled = quality >= 1
        world.environment.fog_enabled = quality >= 1
        world.environment.ambient_light_energy = 0.72 if quality == 0 else (0.82 if quality == 1 else 0.9)
    if weather_particles:
        weather_particles.amount = 520 if quality >= 2 else (220 if quality == 1 else 0)
        weather_particles.emitting = quality >= 1 and weather_particles.get_meta("weather_active", false)
    if smoke_particles:
        smoke_particles.amount = 42 if quality >= 2 else (22 if quality == 1 else 8)
        smoke_particles.emitting = quality >= 1

func set_weather(mode: int) -> void:
    if weather_particles == null:
        return
    var raining := mode == 1
    weather_particles.set_meta("weather_active", raining)
    weather_particles.emitting = raining and quality >= 1

func _add_fire_effect() -> void:
    var fire := GPUParticles3D.new()
    fire.name = "DistantFireGlow"
    fire.amount = 26
    fire.lifetime = 1.1
    fire.explosiveness = 0.0
    fire.visibility_aabb = AABB(Vector3(-8, -2, -8), Vector3(16, 14, 16))
    var process := ParticleProcessMaterial.new()
    process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    process.emission_box_extents = Vector3(1.1, 0.15, 1.1)
    process.direction = Vector3(0.0, 1.0, 0.0)
    process.spread = 24.0
    process.initial_velocity_min = 0.6
    process.initial_velocity_max = 2.2
    process.gravity = Vector3(0.0, -0.25, 0.0)
    process.scale_min = 0.16
    process.scale_max = 0.48
    process.color = Color(1.0, 0.36, 0.08, 0.78)
    fire.process_material = process
    var flame_mesh := SphereMesh.new()
    flame_mesh.radius = 0.28
    flame_mesh.height = 0.56
    var flame_material := StandardMaterial3D.new()
    flame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    flame_material.albedo_color = Color(1.0, 0.42, 0.12, 0.78)
    flame_material.emission_enabled = true
    flame_material.emission = Color(1.0, 0.22, 0.035)
    flame_material.emission_energy_multiplier = 2.0
    flame_mesh.material = flame_material
    fire.draw_pass_1 = flame_mesh
    fire.position = Vector3(-18, 0.2, -24)
    add_child(fire)
    fire.emitting = true
    var glow := OmniLight3D.new()
    glow.name = "FireBounceLight"
    glow.position = Vector3(-18, 1.2, -24)
    glow.light_color = Color(1.0, 0.32, 0.1)
    glow.light_energy = 1.5
    glow.omni_range = 11.0
    glow.shadow_enabled = false
    add_child(glow)
