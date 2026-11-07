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
    shade.color = Color(0.015, 0.025, 0.04, 0.88)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.025, 0.055, 0.085, 0.52)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.add_child(backdrop)
    var frame := PanelContainer.new()
    frame.name = "MenuFrame"
    frame.set_anchors_preset(Control.PRESET_CENTER)
    frame.offset_left = -330
    frame.offset_top = -300
    frame.offset_right = 330
    frame.offset_bottom = 300
    var style := StyleBoxFlat.new()
    style.bg_color = PANEL
    style.border_color = Color(0.52, 0.67, 0.78, 0.95)
    style.set_border_width_all(2)
    style.set_corner_radius_all(12)
    style.content_margin_left = 28
    style.content_margin_right = 28
    style.content_margin_top = 22
    style.content_margin_bottom = 22
    frame.add_theme_stylebox_override("panel", style)
    shade.add_child(frame)
    content = VBoxContainer.new()
    content.add_theme_constant_override("separation", 12)
    frame.add_child(content)

func _clear() -> void:
    for child in content.get_children():
        child.queue_free()

func _heading(title_text: String, subtitle_text: String = "") -> void:
    var title := Label.new()
    title.text = title_text
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 34)
    title.add_theme_color_override("font_color", Color.WHITE)
    content.add_child(title)
    if not subtitle_text.is_empty():
        var subtitle := Label.new()
        subtitle.text = subtitle_text
        subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        subtitle.add_theme_font_size_override("font_size", 14)
        subtitle.add_theme_color_override("font_color", MUTED)
        content.add_child(subtitle)

func _button(caption: String, callback: Callable, accent: bool = false) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(0, 48)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 18)
    button.add_theme_color_override("font_color", Color.WHITE)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.04, 0.62, 0.43, 0.96) if accent else Color(0.10, 0.14, 0.18, 0.96)
    style.border_color = Color(0.88, 0.92, 0.96, 0.85)
    style.set_border_width_all(1)
    style.set_corner_radius_all(7)
    button.add_theme_stylebox_override("normal", style)
    button.add_theme_stylebox_override("hover", style)
    button.add_theme_stylebox_override("pressed", style)
    button.pressed.connect(callback)
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
    _heading("LAST ZONE", "TACTICAL FPS  •  ANDROID EDITION")
    _label("PLAYER  /  " + str(OS.get_name()), 13)
    _button("SINGLE PLAYER", _show_lobby, true)
    _button("MULTIPLAYER", _show_multiplayer)
    _button("WEAPON LOADOUT", _show_weapons)
    _button("SETTINGS", _show_settings)
    _button("STORE", func(): _show_notice("STORE", "The in-game store will be added in a later update."))
    _label("Offline practice available  •  Version 2.0", 12)

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
    _button("BOTS   " + str(selected_bots) + "   (+)", func():
        selected_bots = (selected_bots + 1) % 9
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
