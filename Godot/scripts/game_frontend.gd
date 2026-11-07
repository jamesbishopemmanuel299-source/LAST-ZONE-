extends CanvasLayer
## Mobile-first LAST-ZONE front end inspired by the supplied FPS menu references.

const BLUE := Color(0.20, 0.67, 0.91)
const PANEL := Color(0.055, 0.075, 0.095, 0.96)
const MUTED := Color(0.72, 0.78, 0.84)
var shade: ColorRect
var content: VBoxContainer
var status_label: Label
var selected_weapon := 0
var selected_map := 0
var selected_mode := 0
var selected_bots := 2
var match_minutes := 5
var weapons := ["AKM", "P90", "M4A1", "SCAR-L", "UMP45"]
var maps := ["WARMART", "DESERT OUTPOST", "HARBOR"]
var modes := ["DEATH MATCH", "TEAM DEATH MATCH", "SURVIVAL"]

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

func _build_shell() -> void:
    shade = ColorRect.new()
    shade.name = "FrontEndShade"
    shade.color = Color(0.008, 0.016, 0.028, 0.94)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)

    var backdrop := ColorRect.new()
    backdrop.color = Color(0.025, 0.075, 0.11, 0.42)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.add_child(backdrop)

    var frame := PanelContainer.new()
    frame.name = "MenuFrame"
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    frame.offset_left = 18
    frame.offset_top = 18
    frame.offset_right = -18
    frame.offset_bottom = -18
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.025, 0.045, 0.065, 0.98)
    style.border_color = Color(0.16, 0.55, 0.76, 0.95)
    style.set_border_width_all(2)
    style.set_corner_radius_all(18)
    style.content_margin_left = 20
    style.content_margin_right = 20
    style.content_margin_top = 18
    style.content_margin_bottom = 18
    frame.add_theme_stylebox_override("panel", style)
    shade.add_child(frame)

    var scroll := ScrollContainer.new()
    scroll.name = "MenuScroll"
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    frame.add_child(scroll)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 12)
    scroll.add_child(content)

func _clear() -> void:
    for child in content.get_children():
        child.queue_free()

func _heading(title_text: String, subtitle_text: String = "") -> void:
    var eyebrow := Label.new()
    eyebrow.text = "◈  LAST-ZONE  /  TACTICAL OPERATIONS"
    eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    eyebrow.add_theme_font_size_override("font_size", 12)
    eyebrow.add_theme_color_override("font_color", BLUE)
    content.add_child(eyebrow)

    var title := Label.new()
    title.text = title_text
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 34)
    title.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0))
    content.add_child(title)

    if not subtitle_text.is_empty():
        var subtitle := Label.new()
        subtitle.text = subtitle_text
        subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        subtitle.add_theme_font_size_override("font_size", 13)
        subtitle.add_theme_color_override("font_color", MUTED)
        content.add_child(subtitle)

    var line := ColorRect.new()
    line.custom_minimum_size = Vector2(0, 2)
    line.color = Color(0.12, 0.48, 0.68, 0.8)
    content.add_child(line)

func _button(caption: String, callback: Callable, accent: bool = false) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(0, 54)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 17)
    button.add_theme_color_override("font_color", Color.WHITE)
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.035, 0.42, 0.58, 0.98) if accent else Color(0.075, 0.12, 0.16, 0.98)
    normal.border_color = Color(0.18, 0.62, 0.82, 0.9) if accent else Color(0.20, 0.30, 0.38, 0.95)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(11)
    normal.content_margin_left = 12
    normal.content_margin_right = 12
    var hover := normal.duplicate()
    hover.bg_color = Color(0.05, 0.53, 0.70, 1.0) if accent else Color(0.11, 0.19, 0.25, 1.0)
    var pressed := normal.duplicate()
    pressed.bg_color = Color(0.025, 0.32, 0.45, 1.0)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)
    button.pressed.connect(func():
        var sound = get_node_or_null("/root/SoundFX")
        if sound != null:
            sound.play_ui()
        callback.call()
    )
    content.add_child(button)
    return button

func _label(caption: String, size: int = 17) -> Label:
    var label := Label.new()
    label.text = caption
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", MUTED)
    content.add_child(label)
    return label

func _show_main() -> void:
    _clear()
    _heading("ENTER THE LAST ZONE", "TACTICAL COMBAT  •  ANDROID EDITION")

    var feature := PanelContainer.new()
    var feature_style := StyleBoxFlat.new()
    feature_style.bg_color = Color(0.045, 0.11, 0.15, 0.98)
    feature_style.border_color = Color(0.12, 0.47, 0.65, 0.95)
    feature_style.set_border_width_all(1)
    feature_style.set_corner_radius_all(14)
    feature_style.content_margin_left = 14
    feature_style.content_margin_right = 14
    feature_style.content_margin_top = 14
    feature_style.content_margin_bottom = 14
    feature.add_theme_stylebox_override("panel", feature_style)
    content.add_child(feature)

    var feature_box := VBoxContainer.new()
    feature_box.add_theme_constant_override("separation", 6)
    feature.add_child(feature_box)

    var feature_title := Label.new()
    feature_title.text = "OPERATION: LAST STAND"
    feature_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    feature_title.add_theme_font_size_override("font_size", 20)
    feature_title.add_theme_color_override("font_color", Color(0.88, 0.96, 1.0))
    feature_box.add_child(feature_title)

    var feature_info := Label.new()
    feature_info.text = "Choose your arena, set the challenge and deploy."
    feature_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    feature_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    feature_info.add_theme_font_size_override("font_size", 13)
    feature_info.add_theme_color_override("font_color", MUTED)
    feature_box.add_child(feature_info)

    _label("QUICK DEPLOY  •  " + maps[selected_map] + "  •  " + str(selected_bots) + " BOTS", 12)
    _button("▶   PLAY NOW", _show_lobby, true)
    _button("◈   MULTIPLAYER", _show_multiplayer)
    _button("▣   WEAPON LOADOUT", _show_weapons)
    _button("⚙   SETTINGS", _show_settings)

    var footer := Label.new()
    footer.text = "OFFLINE PRACTICE AVAILABLE     •     BUILD 2.1"
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.add_theme_font_size_override("font_size", 11)
    footer.add_theme_color_override("font_color", Color(0.43, 0.57, 0.66))
    content.add_child(footer)

func _show_weapons() -> void:
    _clear()
    _heading("WEAPON LOADOUT", "Choose your primary weapon")
    _label("SELECTED WEAPON")
    _label(weapons[selected_weapon], 30)
    var row := HBoxContainer.new()
    content.add_child(row)
    var previous := Button.new()
    previous.text = "‹"
    previous.custom_minimum_size = Vector2(90, 52)
    previous.pressed.connect(func():
        selected_weapon = posmod(selected_weapon - 1, weapons.size())
        _show_weapons()
    )
    row.add_child(previous)
    var next := Button.new()
    next.text = "›"
    next.custom_minimum_size = Vector2(90, 52)
    next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    next.pressed.connect(func():
        selected_weapon = (selected_weapon + 1) % weapons.size()
        _show_weapons()
    )
    row.add_child(next)
    _label("Equipment selection is saved for this session.", 13)
    _button("CONTINUE TO LOBBY", _show_lobby, true)
    _button("BACK", _show_main)

func _show_lobby() -> void:
    _clear()
    _heading("MATCH LOBBY", maps[selected_map] + "  •  " + modes[selected_mode])
    _button("MAP  ‹   " + maps[selected_map] + "   ›", func():
        selected_map = (selected_map + 1) % maps.size()
        _show_lobby()
    )
    _button("MODE  ‹   " + modes[selected_mode] + "   ›", func():
        selected_mode = (selected_mode + 1) % modes.size()
        _show_lobby()
    )
    _button("BOTS   " + str(selected_bots) + " / 20", func():
        selected_bots = 1 if selected_bots >= 20 else selected_bots + 1
        _show_lobby()
    )
    _button("DECREASE BOTS   (-)", func():
        selected_bots = maxi(1, selected_bots - 1)
        _show_lobby()
    )
    _button("MATCH TIME   " + str(match_minutes) + " MIN   (+)", func():
        match_minutes = 5 if match_minutes >= 15 else match_minutes + 5
        _show_lobby()
    )
    _button("WEAPON: " + weapons[selected_weapon], _show_weapons)
    _button("START MATCH", _start_match, true)
    _button("CLOSE", _show_main)

func _show_multiplayer() -> void:
    _clear()
    _heading("MULTIPLAYER", "PRIVATE WI-FI ROOMS")
    _button("CREATE ROOM", _host_room, true)
    _label("JOIN AN EXISTING ROOM")
    var address := LineEdit.new()
    address.name = "RoomAddress"
    address.placeholder_text = "Host IP address (example: 192.168.1.10)"
    address.custom_minimum_size.y = 44
    content.add_child(address)
    _button("JOIN ROOM", func(): _join_room(address))
    status_label = _label("Up to 16 players  •  Same Wi-Fi network", 13)
    _button("BACK", _show_main)

func _host_room() -> void:
    var network = get_node_or_null("/root/SessionNetwork")
    if network == null:
        status_label.text = "NETWORK SERVICE UNAVAILABLE"
        return
    var result: int = network.host_session()
    status_label.text = "ROOM CREATED  •  " + network.get_local_ipv4() + ":7777" if result == OK else "ROOM CREATION FAILED: " + str(result)

func _join_room(address: LineEdit) -> void:
    var network = get_node_or_null("/root/SessionNetwork")
    if network == null:
        status_label.text = "NETWORK SERVICE UNAVAILABLE"
        return
    var result: int = network.join_session(address.text.strip_edges())
    status_label.text = "CONNECTING TO ROOM..." if result == OK else "JOIN FAILED: " + str(result)

func _show_settings() -> void:
    _clear()
    _heading("SETTINGS", "Graphics and performance")
    var quality := OptionButton.new()
    quality.add_item("LOW  •  Battery saver")
    quality.add_item("MEDIUM  •  Balanced")
    quality.add_item("HIGH  •  Visual quality")
    quality.select(1)
    quality.item_selected.connect(func(index: int):
        var world := get_parent()
        if world.has_method("_apply_quality"):
            world._apply_quality(index)
    )
    content.add_child(quality)
    _button("BACK", _show_main)

func _show_notice(title_text: String, message: String) -> void:
    _clear()
    _heading(title_text)
    _label(message, 15)
    _button("BACK", _show_main)

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
