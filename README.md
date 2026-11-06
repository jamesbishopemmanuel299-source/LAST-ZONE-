# LAST-ZONE

LAST-ZONE contains a Godot Android-first 3D exploration game and an original Unreal Engine C++ prototype.

## Godot Android game

Open `Godot/project.godot` with Godot 4.4.1 or a compatible 4.4+ editor.

Current prototype systems include:
- Large island with a harbor village, cabins, research district, pier, lookout, forest, trails and coastal scenery.
- Explorer avatar, third-person camera, movement, sprint, jump and Android touch controls.
- Walk-in cabin interiors and simple furnishings.
- Day/night lighting cycle and selectable clear/mist weather effects.
- Eight collectible discoveries with local save progress.
- Island field guide, objective HUD, FPS counter and graphics settings.
- Experimental private ENet sessions with basic position synchronization. This is not public matchmaking or production multiplayer.

## Build an Android APK with GitHub Actions

The workflow **Build LAST-ZONE Android APK** builds the C++ GDExtension libraries, downloads the matching Godot editor/export templates, and attempts an ARM64 Android APK export.

1. Open the repository **Actions** tab.
2. Select **Build LAST-ZONE Android APK** and choose **Run workflow**, or wait for a push to the Godot project.
3. Open the completed run and download **LAST-ZONE-Android-APK** from Artifacts.

The workflow must finish successfully before an installable APK is available. If it fails, open the failed step and share its log for correction. The APK is ARM64 and is not guaranteed to install on 32-bit-only phones.

## Multiplayer limitations

Private ENet host/join is an early LAN experiment. It has no dedicated server, matchmaking, account identity, server-side validation, reconnection, relay/NAT traversal, moderation or hosted infrastructure. Do not expose a personal device directly to untrusted internet traffic.

## Device testing

A successful CI export does not replace testing on a real Android device. Check touch controls, screen layout, collision, frame rate, heat, battery use, memory use and session connectivity before release.

The Unreal Engine C++ project remains in the repository root and is separate from the Godot Android build.
