extends Node
## ENet session layer for private exploration rooms.
## A dedicated authoritative server and replicated player entities are still required
## before this can be considered production multiplayer.

signal session_status_changed(message: String)

const DEFAULT_PORT := 7777
const MAX_CLIENTS := 16
var peer: ENetMultiplayerPeer
var sync_clock := 0.0
var remote_players: Dictionary = {}

func host_session(port: int = DEFAULT_PORT) -> int:
    disconnect_session()
    peer = ENetMultiplayerPeer.new()
    var result := peer.create_server(port, MAX_CLIENTS)
    if result == OK:
        multiplayer.multiplayer_peer = peer
        multiplayer.peer_disconnected.connect(_on_peer_disconnected)
        session_status_changed.emit("Hosting private room on port " + str(port))
    return result

func join_session(address: String, port: int = DEFAULT_PORT) -> int:
    if address.is_empty():
        return ERR_INVALID_PARAMETER
    disconnect_session()
    peer = ENetMultiplayerPeer.new()
    var result := peer.create_client(address, port)
    if result == OK:
        multiplayer.multiplayer_peer = peer
        session_status_changed.emit("Connecting to " + address)
    return result

func disconnect_session() -> void:
    for remote_id in remote_players.keys():
        _remove_remote_player(int(remote_id))
    if peer != null:
        peer.close()
        peer = null
    multiplayer.multiplayer_peer = null
    session_status_changed.emit("Offline session")


func _process(delta: float) -> void:
    if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
        return
    sync_clock += delta
    if sync_clock < 0.08:
        return
    sync_clock = 0.0
    var scene := get_tree().current_scene
    if scene == null:
        return
    var local_player := scene.get_node_or_null("Player")
    if local_player == null:
        return
    var pos: Vector3 = local_player.global_position
    var yaw: float = local_player.global_rotation.y
    if multiplayer.is_server():
        rpc("receive_player_state", multiplayer.get_unique_id(), pos, yaw)
    else:
        rpc_id(1, "submit_player_state", pos, yaw)

@rpc("any_peer", "call_remote", "unreliable")
func submit_player_state(pos: Vector3, yaw: float) -> void:
    if not multiplayer.is_server():
        return
    var sender_id := multiplayer.get_remote_sender_id()
    _set_remote_player(sender_id, pos, yaw)
    rpc("receive_player_state", sender_id, pos, yaw)

@rpc("authority", "call_remote", "unreliable")
func receive_player_state(peer_id: int, pos: Vector3, yaw: float) -> void:
    if peer_id == multiplayer.get_unique_id():
        return
    _set_remote_player(peer_id, pos, yaw)

func _set_remote_player(peer_id: int, pos: Vector3, yaw: float) -> void:
    var scene := get_tree().current_scene
    if scene == null:
        return
    var avatar: Node3D = remote_players.get(peer_id)
    if not is_instance_valid(avatar):
        avatar = Node3D.new()
        avatar.name = "Explorer_" + str(peer_id)
        var body := MeshInstance3D.new()
        var capsule := CapsuleMesh.new()
        capsule.radius = 0.42
        capsule.height = 1.75
        body.mesh = capsule
        var material := StandardMaterial3D.new()
        material.albedo_color = Color(0.18, 0.68, 0.88)
        body.material_override = material
        avatar.add_child(body)
        scene.add_child(avatar)
        remote_players[peer_id] = avatar
    avatar.global_position = pos
    avatar.global_rotation.y = yaw

func _on_peer_disconnected(peer_id: int) -> void:
    _remove_remote_player(peer_id)
    if multiplayer.is_server():
        rpc("remove_remote_player", peer_id)

@rpc("authority", "call_remote", "reliable")
func remove_remote_player(peer_id: int) -> void:
    _remove_remote_player(peer_id)

func _remove_remote_player(peer_id: int) -> void:
    var avatar: Node3D = remote_players.get(peer_id)
    if is_instance_valid(avatar):
        avatar.queue_free()
    remote_players.erase(peer_id)
