extends CanvasLayer
## Battle-royale inspired LAST-ZONE interface.
## Original layout and styling; no copied game assets or branding.

const GOLD := Color(1.0, 0.72, 0.20)
const ORANGE := Color(1.0, 0.39, 0.12)
const CYAN := Color(0.20, 0.82, 0.96)
const WHITE := Color(0.96, 0.97, 0.99)
const MUTED := Color(0.66, 0.72, 0.79)
const DARK := Color(0.025, 0.035, 0.052, 0.985)
const CARD := Color(0.075, 0.09, 0.115, 0.98)

var shade: ColorRect
var content: VBoxContainer
var status_label: Label
var selected_map := 0
var selected_mode := 0
var selected_bots := 2
var match_minutes := 5
var selected_outfit := 0
var maps := ["ISLAND FRONTIER", "DESERT OUTPOST", "HARBOR CITY"]
var modes := ["SOLO", "DUO", "SQUAD"]
var outfits := ["FIELD EXPLORER", "ARCTIC RUNNER", "SUNSET NOMAD", "URBAN SCOUT"]

func _ready() -> void:
    layer = 10
    call_deferred("_show_frontend")

func _show_frontend() -> void:
    var old_hud := get_parent().get_node_or_null("ExpeditionHUD")
    if old_hud != null:
        var old_menu := old_hud.get_node_or_null("MainMenu")
        var old_shade := old_hud.get_node_or_null("MenuShade")
        if old_menu != null:
            old_menu.hide()
        if old_shade != null:
            old_shade.hide()
    _build_shell()
    _show_main()

func _style(bg: Color = CARD, border: Color = Color(0.25, 0.29, 0.34, 1.0)) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(1)
    s.set_corner_radius_all(9)
    s.content_margin_left = 12
    s.content_margin_right = 12
    s.content_margin_top = 9
    s.content_margin_bottom = 9
    return s

func _build_shell() -> void:
    shade = ColorRect.new()
    shade.name = "FrontEndShade"
    shade.color = Color(0.008, 0.012, 0.02, 0.985)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)

    var frame := PanelContainer.new()
    frame.name = "BattleLobbyFrame"
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    frame.offset_left = 7
    frame.offset_top = 7
    frame.offset_right = -7
    frame.offset_bottom = -7
    var frame_style := _style(Color(0.025, 0.032, 0.045, 0.99), Color(0.34, 0.27, 0.16, 1.0))
    frame_style.set_border_width_all(2)
    frame.add_theme_stylebox_override("panel", frame_style)
    shade.add_child(frame)

    var scroll := ScrollContainer.new()
    scroll.name = "LobbyScroll"
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    frame.add_child(scroll)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 8)
    scroll.add_child(content)

func _clear() -> void:
    for child in content.get_children():
        child.queue_free()

func _label(text_value: String, size: int = 13, color: Color = MUTED, centered: bool = false) -> Label:
    var l := Label.new()
    l.text = text_value
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    if centered:
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(l)
    return l

func _button(text_value: String, callback: Callable, primary: bool = false) -> Button:
    var b := Button.new()
    b.text = text_value
    b.custom_minimum_size = Vector2(0, 45)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size", 14)
    b.add_theme_color_override("font_color", WHITE)
    b.add_theme_color_override("font_hover_color", WHITE)
    var normal := _style(Color(0.12, 0.13, 0.15, 1.0), Color(0.35, 0.36, 0.38, 1.0))
    if primary:
        normal.bg_color = Color(0.78, 0.30, 0.075, 1.0)
        normal.border_color = GOLD
        normal.set_border_width_all(2)
    var hover := normal.duplicate()
    hover.bg_color = Color(0.94, 0.43, 0.10, 1.0) if primary else Color(0.20, 0.23, 0.27, 1.0)
    hover.border_color = GOLD
    b.add_theme_stylebox_override("normal", normal)
    b.add_theme_stylebox_override("hover", hover)
    b.add_theme_stylebox_override("pressed", _style(Color(0.34, 0.18, 0.10, 1.0), GOLD))
    b.pressed.connect(func():
        var sound = get_node_or_null("/root/SoundFX")
        if sound != null:
            sound.play_ui()
        callback.call()
    )
    content.add_child(b)
    return b

func _card(title_text: String, detail: String, accent: Color = GOLD) -> void:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel", _style(Color(0.075, 0.085, 0.105, 0.99), accent))
    content.add_child(panel)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 4)
    panel.add_child(stack)
    var title := Label.new()
    title.text = title_text
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 17)
    title.add_theme_color_override("font_color", accent)
    stack.add_child(title)
    var detail_label := Label.new()
    detail_label.text = detail
    detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.add_theme_font_size_override("font_size", 12)
    detail_label.add_theme_color_override("font_color", WHITE)
    stack.add_child(detail_label)

func _top_bar() -> void:
    var bar := PanelContainer.new()
    bar.add_theme_stylebox_override("panel", _style(Color(0.055, 0.065, 0.08, 1.0), Color(0.35, 0.28, 0.16, 1.0)))
    content.add_child(bar)
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    bar.add_child(row)
    var brand := Label.new()
    brand.text = "LAST-ZONE"
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    brand.add_theme_font_size_override("font_size", 19)
    brand.add_theme_color_override("font_color", GOLD)
    row.add_child(brand)
    var profile := Label.new()
    profile.text = "PLAYER 01  •  LV.1"
    profile.add_theme_font_size_override("font_size", 11)
    profile.add_theme_color_override("font_color", WHITE)
    row.add_child(profile)

func _show_main() -> void:
    _clear()
    _top_bar()
    _label("SEASON 01   /   FRONTIER RISING", 11, CYAN, true)
    _card("WELCOME TO THE FRONTIER", "Your island adventure starts here. Explore, team up and complete challenges.", GOLD)

    var avatar := PanelContainer.new()
    avatar.custom_minimum_size = Vector2(0, 170)
    avatar.add_theme_stylebox_override("panel", _style(Color(0.12, 0.14, 0.17, 1.0), Color(0.48, 0.34, 0.17, 1.0)))
    content.add_child(avatar)
    var avatar_stack := VBoxContainer.new()
    avatar_stack.alignment = BoxContainer.ALIGNMENT_CENTER
    avatar_stack.add_theme_constant_override("separation", 4)
    avatar.add_child(avatar_stack)
    _make_avatar_preview(avatar_stack)
    var outfit_label := Label.new()
    outfit_label.text = outfits[selected_outfit]
    outfit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    outfit_label.add_theme_font_size_override("font_size", 12)
    outfit_label.add_theme_color_override("font_color", GOLD)
    avatar_stack.add_child(outfit_label)

    _card("FEATURED MODE", modes[selected_mode] + "  •  " + maps[selected_map], ORANGE)
    _button("▶   START MATCH", _show_lobby, true)

    var nav := HBoxContainer.new()
    nav.add_theme_constant_override("separation", 5)
    content.add_child(nav)
    _small_nav(nav, "EVENTS", _show_events)
    _small_nav(nav, "MISSIONS", _show_missions)
    _small_nav(nav, "COLLECTION", _show_collection)

    _button("PLAY WITH FRIENDS  /  MULTIPLAYER", _show_multiplayer)
    _button("PROFILE & PLAYER STATS", _show_profile)
    _button("SETTINGS", _show_settings)
    _label("DAILY BONUS   •   COMPLETE MISSIONS TO EARN XP", 10, MUTED, true)

func _make_avatar_preview(parent: VBoxContainer) -> void:
    var preview_box := SubViewportContainer.new()
    preview_box.custom_minimum_size = Vector2(0, 132)
    preview_box.stretch = true
    preview_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    parent.add_child(preview_box)
    var viewport := SubViewport.new()
    viewport.size = Vector2i(320, 220)
    viewport.transparent_bg = true
    viewport.world_3d = World3D.new()
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    preview_box.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var avatar := MeshInstance3D.new()
    avatar.name = "LobbyCharacterPreview"
    avatar.set_script(load("res://scripts/character_visual.gd"))
    stage.add_child(avatar)
    var camera := Camera3D.new()
    camera.position = Vector3(0, 1.12, 4.8)
    camera.look_at(Vector3(0, 1.05, 0), Vector3.UP)
    camera.fov = 38.0
    stage.add_child(camera)
    camera.current = true
    var key_light := DirectionalLight3D.new()
    key_light.rotation_degrees = Vector3(-28, -25, 0)
    key_light.light_energy = 1.35
    key_light.shadow_enabled = false
    stage.add_child(key_light)
    var fill_light := OmniLight3D.new()
    fill_light.position = Vector3(2.0, 1.5, 2.0)
    fill_light.light_color = CYAN
    fill_light.light_energy = 0.7
    fill_light.omni_range = 7.0
    fill_light.shadow_enabled = false
    stage.add_child(fill_light)

func _small_nav(parent: HBoxContainer, caption: String, callback: Callable) -> void:
    var b := Button.new()
    b.text = caption
    b.custom_minimum_size = Vector2(0, 42)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size", 10)
    b.add_theme_color_override("font_color", WHITE)
    b.add_theme_stylebox_override("normal", _style(Color(0.13, 0.14, 0.16, 1.0), Color(0.36, 0.32, 0.25, 1.0)))
    b.pressed.connect(callback)
    parent.add_child(b)

func _show_lobby() -> void:
    _clear()
    _top_bar()
    _label("MATCHMAKING  /  BATTLE ARENA", 11, CYAN, true)
    _card("MATCH SETUP", "Choose your map and team size before entering the island.")
    _button("MAP  •  " + maps[selected_map], func():
        selected_map = (selected_map + 1) % maps.size()
        _show_lobby()
    )
    _button("TEAM  •  " + modes[selected_mode], func():
        selected_mode = (selected_mode + 1) % modes.size()
        _show_lobby()
    )
    _button("PRACTICE PARTICIPANTS  •  " + str(selected_bots), func():
        selected_bots = 1 if selected_bots >= 20 else selected_bots + 1
        _show_lobby()
    )
    _button("MATCH LENGTH  •  " + str(match_minutes) + " MIN", func():
        match_minutes = 5 if match_minutes >= 15 else match_minutes + 5
        _show_lobby()
    )
    _card("READY CHECK", "Map: " + maps[selected_map] + "\nTeam: " + modes[selected_mode] + "\nPractice participants: " + str(selected_bots), GOLD)
    _button("CONFIRM & ENTER", _start_match, true)
    _button("BACK TO LOBBY", _show_main)

func _show_multiplayer() -> void:
    _clear()
    _top_bar()
    _label("SQUAD ROOM", 23, GOLD, true)
    _card("PRIVATE WI-FI ROOM", "Invite friends on the same Wi-Fi network. Share the host address with your team.")
    _button("CREATE ROOM", _host_room, true)
    _label("JOIN A FRIEND", 12, WHITE, true)
    var address := LineEdit.new()
    address.placeholder_text = "Host IP address"
    address.custom_minimum_size.y = 45
    address.add_theme_stylebox_override("normal", _style(Color(0.04, 0.05, 0.07, 1.0)))
    address.add_theme_color_override("font_color", WHITE)
    content.add_child(address)
    _button("JOIN ROOM", func(): _join_room(address))
    status_label = _label("ROOM STATUS  •  NOT CONNECTED", 11, CYAN, true)
    _button("BACK", _show_main)

func _host_room() -> void:
    var network = get_node_or_null("/root/SessionNetwork")
    if network == null:
        status_label.text = "NETWORK SERVICE UNAVAILABLE"
        return
    var result: int = network.host_session()
    status_label.text = "ROOM READY  •  " + network.get_local_ipv4() + ":7777" if result == OK else "ROOM ERROR: " + str(result)

func _join_room(address: LineEdit) -> void:
    var network = get_node_or_null("/root/SessionNetwork")
    if network == null:
        status_label.text = "NETWORK SERVICE UNAVAILABLE"
        return
    var result: int = network.join_session(address.text.strip_edges())
    status_label.text = "CONNECTING TO TEAM..." if result == OK else "JOIN ERROR: " + str(result)

func _show_collection() -> void:
    _clear()
    _top_bar()
    _label("COLLECTION", 24, GOLD, true)
    _card("CHARACTER OUTFITS", "Choose an appearance for your player. These are cosmetic selections.")
    _button("‹  PREVIOUS OUTFIT", func():
        selected_outfit = posmod(selected_outfit - 1, outfits.size())
        _show_collection()
    )
    _card("SELECTED LOOK", outfits[selected_outfit], CYAN)
    _button("NEXT OUTFIT  ›", func():
        selected_outfit = (selected_outfit + 1) % outfits.size()
        _show_collection()
    )
    _button("BACK TO LOBBY", _show_main)

func _show_events() -> void:
    _clear()
    _top_bar()
    _label("FRONTIER EVENTS", 23, GOLD, true)
    _card("ISLAND DISCOVERY", "Explore landmarks and discover hidden locations.")
    _card("WEEKLY EXPLORER", "Visit three regions to complete this challenge.")
    _card("TEAM-UP BONUS", "Play a session with friends to earn bonus experience.")
    _button("BACK", _show_main)

func _show_missions() -> void:
    _clear()
    _top_bar()
    _label("DAILY MISSIONS", 23, GOLD, true)
    _card("MISSION 01  •  EXPLORER", "Visit two landmarks.  Reward: 100 XP")
    _card("MISSION 02  •  TEAM PLAYER", "Join a multiplayer room.  Reward: 150 XP")
    _card("MISSION 03  •  COLLECTOR", "Find three island discoveries.  Reward: 200 XP")
    _button("BACK", _show_main)

func _show_profile() -> void:
    _clear()
    _top_bar()
    _label("PLAYER PROFILE", 23, GOLD, true)
    _card("PLAYER 01", "Level 1\nExperience: 0 XP\nTitle: Island Rookie\nStatus: Ready")
    _card("CAREER STATS", "Your match and exploration statistics will appear here as they are recorded.")
    _button("BACK", _show_main)

func _show_settings() -> void:
    _clear()
    _top_bar()
    _label("SETTINGS", 23, GOLD, true)
    var settings := ConfigFile.new()
    settings.load("user://last_zone_settings.cfg")
    _card("GRAPHICS QUALITY", "Choose the visual preset that best suits your phone.")
    var quality := OptionButton.new()
    quality.custom_minimum_size = Vector2(0, 46)
    quality.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    quality.add_item("LOW  •  PERFORMANCE")
    quality.add_item("MEDIUM  •  BALANCED")
    quality.add_item("HIGH  •  VISUAL QUALITY")
    var saved_quality := clampi(int(settings.get_value("graphics", "quality", 1)), 0, 2)
    quality.select(saved_quality)
    quality.add_theme_stylebox_override("normal", _style(Color(0.08, 0.09, 0.11, 1.0)))
    quality.add_theme_color_override("font_color", WHITE)
    quality.item_selected.connect(func(index: int):
        var world := get_parent()
        if world.has_method("_apply_quality"):
            world._apply_quality(index)
        _store_setting("graphics", "quality", index)
    )
    content.add_child(quality)
    _card("AUDIO", "Adjust interface and game sound effects.")
    var sound_enabled := bool(settings.get_value("audio", "enabled", true))
    var sound_toggle := CheckButton.new()
    sound_toggle.text = "SOUND EFFECTS"
    sound_toggle.button_pressed = sound_enabled
    sound_toggle.add_theme_color_override("font_color", WHITE)
    sound_toggle.toggled.connect(func(enabled: bool):
        var sound = get_node_or_null("/root/SoundFX")
        if sound != null:
            sound.set_enabled(enabled)
        _store_setting("audio", "enabled", enabled)
    )
    content.add_child(sound_toggle)
    var volume_label := _label("SOUND VOLUME  •  %d%%" % int(float(settings.get_value("audio", "volume", 0.65)) * 100.0), 12, CYAN)
    var volume_slider := HSlider.new()
    volume_slider.min_value = 0.0
    volume_slider.max_value = 1.0
    volume_slider.step = 0.05
    volume_slider.value = clampf(float(settings.get_value("audio", "volume", 0.65)), 0.0, 1.0)
    volume_slider.custom_minimum_size = Vector2(0, 36)
    volume_slider.value_changed.connect(func(value: float):
        volume_label.text = "SOUND VOLUME  •  %d%%" % int(value * 100.0)
        var sound = get_node_or_null("/root/SoundFX")
        if sound != null:
            sound.set_volume(value)
        _store_setting("audio", "volume", value)
    )
    content.add_child(volume_slider)
    var sound = get_node_or_null("/root/SoundFX")
    if sound != null:
        sound.set_enabled(sound_enabled)
        sound.set_volume(volume_slider.value)
    _button("BACK", _show_main)

func _store_setting(section: String, key: String, value: Variant) -> void:
    var settings := ConfigFile.new()
    settings.load("user://last_zone_settings.cfg")
    settings.set_value(section, key, value)
    var result := settings.save("user://last_zone_settings.cfg")
    if result != OK:
        push_warning("Could not save LAST-ZONE settings: " + str(result))

func _start_match() -> void:
    var sound = get_node_or_null("/root/SoundFX")
    if sound != null:
        sound.play_confirm()
    var world := get_parent()
    if world != null and world.has_method("configure_bots"):
        world.configure_bots(selected_bots)
    shade.hide()
    var old_hud := get_parent().get_node_or_null("ExpeditionHUD")
    if old_hud != null:
        var old_menu := old_hud.get_node_or_null("MainMenu")
        var old_shade := old_hud.get_node_or_null("MenuShade")
        if old_menu != null:
            old_menu.hide()
        if old_shade != null:
            old_shade.hide()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not OS.has_feature("mobile") else Input.MOUSE_MODE_VISIBLE
