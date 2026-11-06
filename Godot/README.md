# LAST-ZONE — Android-first exploration prototype

The Godot project under this folder is the phone-first playable path. The Unreal Engine C++ project remains in the repository root.

## Current prototype features

- Expanded 420 × 420 island floor surrounded by water, with coastal sand, roads and distinct exploration districts.
- Harbor village, pier, ranger cabins, visitor centre, research hall, lookout tower, hills, forests and signal landmarks.
- Procedural low-poly explorer character with a basic walk/run animation cycle.
- Camera-relative movement, jump, sprint and touch controls.
- Start lobby with private ENet host/join controls and a graphics-quality selector.
- Live FPS counter for on-device performance checks.
- Godot Mobile renderer, limited shadow distance and simple primitive materials.

## Multiplayer status

The ENet layer provides private room hosting/client connection on port 7777 and basic remote explorer position/yaw synchronization with lightweight remote avatars. It is suitable as an early LAN/private-session prototype. It is not production-ready: there is no dedicated authoritative server, matchmaking, account identity, server-side validation, reconnection flow, moderation, relay/NAT traversal or hosted infrastructure. Do not expose a home device directly to untrusted internet traffic.

## Android build status

The GitHub Actions workflow in this repository currently compiles the Android ARM64 C++ GDExtension libraries. It does **not** export a complete APK. A matching Godot 4.4+ editor, Android export templates, SDK/NDK and export preset are still required to package the full game.

## Device QA checklist

Test on real Android devices before release:

1. Confirm the app opens and the lobby buttons fit the screen in portrait and landscape.
2. Walk the coastline, village, research district and lookout area; check collisions and missing geometry.
3. Test touch movement, camera drag, jump and sprint.
4. Record FPS after 5 minutes in the village and forest; check heat, battery use and memory pressure.
5. Compare Low, Medium and High settings on low-, mid- and high-range devices.
6. Verify host/join on two devices connected to the same network; then test across separate networks only after a reachable server and firewall rules are configured.

The FPS label is a diagnostic aid, not a substitute for profiling on physical devices. No physical-device test has been run by this workflow.
