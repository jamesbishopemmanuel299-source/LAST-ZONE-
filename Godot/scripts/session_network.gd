extends Node
## ENet session layer for private exploration rooms.
## A dedicated authoritative server and replicated player entities are still required
## before this can be considered production multiplayer.

signal session_status_changed(message: String)

const DEFAULT_PORT := 7777
const MAX_CLIENTS := 16
var peer: ENetMultiplayerPeer

func host_session(port: int = DEFAULT_PORT) -> int:
    disconnect_session()
    peer = ENetMultiplayerPeer.new()
    var result := peer.create_server(port, MAX_CLIENTS)
    if result == OK:
        multiplayer.multiplayer_peer = peer
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
    if peer != null:
        peer.close()
        peer = null
    multiplayer.multiplayer_peer = null
    session_status_changed.emit("Offline session")
