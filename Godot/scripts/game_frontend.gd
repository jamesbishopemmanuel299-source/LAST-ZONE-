extends CanvasLayer
## Unified LAST-ZONE interface theme for menus, lobby, multiplayer and settings.

const BLUE := Color(0.18, 0.68, 0.94)
const CYAN := Color(0.22, 0.88, 0.96)
const PANEL := Color(0.035, 0.065, 0.09, 0.98)
const MUTED := Color(0.68, 0.77, 0.85)
const WHITE := Color(0.94, 0.98, 1.0)
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

func _panel_style(bg: Color = PANEL, border: Color = Color(0.12, 0.43, 0.59, 0.9)) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.set_border_width_all(1)
    style.set_corner_radius_all(14)
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    return style

func _build_shell() -> void:
    shade = ColorRect.new()
    shade.name = "FrontEndShade"
    shade.color = Color(0.006, 0.014, 0.025, 0.96)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)

    var backdrop := ColorRect.new()
    backdrop.color = Color(0.025, 0.12, 0.18, 0.28)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.add_child(backdrop)

    var frame := PanelContainer.new()
    frame.name = "MenuFrame"
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    frame.offset_left = 12
    frame.offset_top = 12
    frame.offset_right = -12
    frame.offset_bottom = -12
    var frame_style := _panel_style(Color(0.018, 0.034, 0.052, 0.985), Color(0.12, 0.48, 0.68, 0.95))
    frame_style.set_border_width_all(2)
    frame_style.set_corner_radius_all(20)
    frame_style.content_margin_left = 16
    frame_style.content_margin_right = 16
    frame_style.content_margin_top = 14
    frame_style.content_margin_bottom = 14
    frame.add_theme_stylebox_override("panel", frame_style)
    shade.add_child(frame)

    var scroll := ScrollContainer.new()
    scroll.name = "MenuScroll"
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    frame.add_child(scroll)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 11)
    scroll.add_child(content)

func _clear() -> void:
    for child in content.get_children():
        child.queue_free()

func _heading(title_text: String, subtitle_text: String = "") -> void:
    var eyebrow := Label.new()
    eyebrow.text = "◈  LAST-ZONE     /     TACTICAL OPERATIONS"
    eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    eyebrow.add_theme_font_size_override("font_size", 12)
    eyebrow.add_theme_color_override("font_color", CYAN)
    content.add_child(eyebrow)

    var title := Label.new()
    title.text = title_text
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 31)
    title.add_theme_color_override("font_color", WHITE)
    title.add_theme_color_override("font_shadow_color", Color(0.04, 0.35, 0.55, 0.65))
    title.add_theme_constant_override("shadow_offset_x", 0)
    title.add_theme_constant_override("shadow_offset_y", 2)
    content.add_child(title)

    if not subtitle_text.is_empty():
        var subtitle := Label.new()
        subtitle.text = subtitle_text
        subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        subtitle.add_theme_font_size_override("font_size", 12)
        subtitle.add_theme_color_override("font_color", MUTED)
        content.add_child(subtitle)

    var line := ColorRect.new()
    line.custom_minimum_size = Vector2(0, 2)
    line.color = Color(0.12, 0.58, 0.78, 0.85)
    content.add_child(line)

func _button(caption: String, callback: Callable, accent: bool = false) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(0, 50)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 15)
    button.add_theme_color_override("font_color", WHITE)
    button.add_theme_color_override("font_hover_color", WHITE)
    button.add_theme_color_override("font_pressed_color", CYAN)
    var normal := _panel_style(Color(0.045, 0.09, 0.125, 0.98), Color(0.13, 0.29, 0.39, 0.95))
    normal.set_corner_radius_all(10)
    if accent:
        normal.bg_color = Color(0.025, 0.34, 0.49, 1.0)
        normal.border_color = BLUE
        normal.set_border_width_all(2)
    var hover := normal.duplicate()
    hover.bg_color = Color(0.055, 0.20, 0.27, 1.0) if not accent else Color(0.035, 0.47, 0.62, 1.0)
    hover.border_color = CYAN
    var pressed := normal.duplicate()
    pressed.bg_color = Color(0.025, 0.27, 0.37, 1.0)
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

func _label(caption: String, size: int = 16) -> Label:
    var label := Label.new()
    label.text = caption
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", MUTED)
    content.add_child(label)
    return label

func _section_card(title_text: String, detail: String) -> void:
    var card := PanelContainer.new()
    card.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.085, 0.12, 0.98), Color(0.10, 0.40, 0.56, 0.9)))
    content.add_child(card)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 5)
    card.add_child(box)
    var title := Label.new()
    title.text = title_text
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 19)
    title.add_theme_color_override("font_color", WHITE)
    box.add_child(title)
    var description := Label.new()
    description.text = detail
    description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.add_theme_font_size_override("font_size", 12)
    description.add_theme_color_override("font_color", MUTED)
    box.add_child(description)

func _show_main() -> void:
    _clear()
    _heading("ENTER THE LAST ZONE", "ANDROID EDITION     •     OFFLINE PRACTICE + MULTIPLAYER")
    _section_card("OPERATION: LAST STAND", "Select an arena, configure your match and enter the zone.")
    _label("QUICK DEPLOY     •     " + maps[selected_map] + "     •     " + str(selected_bots) + " BOTS", 12)
    _button("▶     PLAY NOW", _show_lobby, true)
    _button("◈     MULTIPLAYER", _show_multiplayer)
    _button("▣     LOADOUT", _show_weapons)
    _button("⚙     SETTINGS", _show_settings)
    _label("PROFILE  •  LOCAL PLAYER       BUILD 2.2", 11)

func _show_weapons() -> void:
    _clear()
    _heading("LOADOUT", "Select your preferred equipment")
    _section_card("CURRENT SELECTION", weapons[selected_weapon])
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 10)
    content.add_child(row)
    var previous := Button.new()
    previous.text = "‹  PREVIOUS"
    previous.custom_minimum_size = Vector2(0, 48)
    previous.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    previous.add_theme_stylebox_override("normal", _panel_style(Color(0.045, 0.09, 0.125, 1)))
    previous.pressed.connect(func():
        selected_weapon = posmod(selected_weapon - 1, weapons.size())
        _show_weapons()
    )
    row.add_child(previous)
    var next := Button.new()
    next.text = "NEXT  ›"
    next.custom_minimum_size = Vector2(0, 48)
    next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    next.add_theme_stylebox_override("normal", _panel_style(Color(0.045, 0.09, 0.125, 1)))
    next.pressed.connect(func():
        selected_weapon = (selected_weapon + 1) % weapons.size()
        _show_weapons()
    )
    row.add_child(next)
    _button("CONTINUE TO LOBBY", _show_lobby, true)
    _button("BACK TO HOME", _show_main)

func _show_lobby() -> void:
    _clear()
    _heading("MATCH LOBBY", "Configure your session before starting")
    _section_card("MATCH PREVIEW", maps[selected_map] + "   •   " + modes[selected_mode])
    _button("ARENA     ‹   " + maps[selected_map] + "   ›", func():
        selected_map = (selected_map + 1) % maps.size()
        _show_lobby()
    )
    _button("GAME MODE     ‹   " + modes[selected_mode] + "   ›", func():
        selected_mode = (selected_mode + 1) % modes.size()
        _show_lobby()
    )
    _button("BOT COUNT     " + str(selected_bots) + " / 20     (+)", func():
        selected_bots = 1 if selected_bots >= 20 else selected_bots + 1
        _show_lobby()
    )
    _button("REDUCE BOTS     (−)", func():
        selected_bots = maxi(1, selected_bots - 1)
        _show_lobby()
    )
    _button("MATCH LENGTH     " + str(match_minutes) + " MIN     (+)", func():
        match_minutes = 5 if match_minutes >= 15 else match_minutes + 5
        _show_lobby()
    )
    _button("LOADOUT     •     " + weapons[selected_weapon], _show_weapons)
    _button("DEPLOY", _start_match, true)
    _button("BACK", _show_main)

func _show_multiplayer() -> void:
    _clear()
    _heading("MULTIPLAYER", "Create or join a private local network room")
    _section_card("PRIVATE ROOM", "Play together on the same Wi-Fi network.")
    _button("CREATE ROOM", _host_room, true)
    _label("JOIN AN EXISTING ROOM", 13)
    var address := LineEdit.new()
    address.name = "RoomAddress"
    address.placeholder_text = "Host IP address"
    address.custom_minimum_size.y = 48
    address.add_theme_stylebox_override("normal", _panel_style(Color(0.025, 0.05, 0.07, 1)))
    address.add_theme_color_override("font_color", WHITE)
    address.add_theme_color_override("font_placeholder_color", MUTED)
    content.add_child(address)
    _button("JOIN ROOM", func(): _join_room(address))
    status_label = _label("UP TO 16 PLAYERS     •     SAME WI-FI", 12)
    _button("BACK TO HOME", _show_main)

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
    _heading("SETTINGS", "Choose a balance between visuals and performance")
    _section_card("GRAPHICS PRESET", "Lower settings may improve performance on older phones.")
    var quality := OptionButton.new()
    quality.custom_minimum_size = Vector2(0, 48)
    quality.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    quality.add_item("LOW  •  PERFORMANCE")
    quality.add_item("MEDIUM  •  BALANCED")
    quality.add_item("HIGH  •  VISUAL QUALITY")
    quality.select(1)
    quality.add_theme_stylebox_override("normal", _panel_style(Color(0.035, 0.075, 0.10, 1)))
    quality.add_theme_color_override("font_color", WHITE)
    quality.item_selected.connect(func(index: int):
        var world := get_parent()
        if world.has_method("_apply_quality"):
            world._apply_quality(index)
    )
    content.add_child(quality)
    _button("BACK TO HOME", _show_main)

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
