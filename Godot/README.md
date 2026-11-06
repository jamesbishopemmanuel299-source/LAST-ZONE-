# LAST-ZONE — Android-first exploration prototype

## Current features

- Expanded 420 × 420 island with ocean, beaches, roads, village, cabins, pier, visitor centre, research hall, lookout tower, hills and forest.
- Procedural low-poly explorer avatar with walk/run animation.
- Third-person camera, keyboard movement, Android touch movement, camera drag, jump and sprint.
- Walk-in cabin interiors with simple furnishings.
- Dynamic day/night lighting and clear/mist weather settings.
- Eight glowing discovery objects; collected discoveries save locally in `user://last_zone_save.cfg`.
- Island field guide, discovery counter, lobby, graphics-quality selector and FPS display.
- Private ENet host/join experiment with basic remote explorer position and yaw synchronization.

## Android build

The GitHub Actions workflow **Build LAST-ZONE Android APK** builds the Linux editor GDExtension, Android ARM64 debug/release libraries, and exports an Android ARM64 APK using Godot 4.4.1 export templates. Download the `LAST-ZONE-Android-APK` artifact only after the workflow completes successfully.

The APK is ARM64-only. The workflow has not tested the app on a physical phone. If export fails, the failing GitHub Actions step is the source of truth; do not assume an APK was produced.

## Multiplayer scope

The ENet code is an early private/LAN foundation only. There is no dedicated authoritative server, matchmaking, account identity, server-side validation, reconnection, moderation, relay/NAT traversal or hosted infrastructure. Do not expose a home device directly to untrusted internet traffic.

## Android QA checklist

1. Install the APK on a compatible ARM64 Android device.
2. Check the lobby and HUD in portrait and landscape.
3. Test movement, camera drag, jump and sprint.
4. Enter cabins and inspect collisions and interior layout.
5. Collect discoveries, close and reopen the app, and verify saved progress.
6. Test day/night, weather and each graphics preset.
7. Check FPS, heat, battery and memory after a longer session.
8. Test private host/join only on a trusted local network.
