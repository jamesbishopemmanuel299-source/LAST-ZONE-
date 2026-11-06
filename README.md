# LAST-ZONE

LAST-ZONE currently contains two C++ prototype paths:

- **Godot Android prototype:** open `Godot/project.godot`. This is the Android-first third-person exploration prototype, using C++ through GDExtension. See [Godot/README.md](Godot/README.md).
- **Unreal Engine prototype:** the original Unreal Engine 5.8 project remains in the repository root, with its C++ island exploration and rescue systems.

## Godot Android build

A GitHub Actions workflow builds the Android ARM64 C++ extension libraries:

1. Open the repository's **Actions** tab.
2. Run **Build LAST-ZONE Godot Android Extension**, or wait for the workflow triggered by a change in the Godot folder.
3. Download the `last-zone-android-arm64` artifact.
4. Extract the debug and release `.so` files into `Godot/bin/`.
5. Open `Godot/project.godot` using Godot Editor for Android.
6. Configure an Android export preset and export an APK.

The workflow builds the C++ extension only; it does not create an APK. For Gradle-based Android export from the Android editor, install the Godot Android Build Environment (GABE). The original Unreal project is not converted or deleted.

## Unreal Engine project

The Unreal project requires a compatible Unreal Engine installation and its Android SDK/NDK toolchain. The Unreal Editor is a desktop editor; for a phone-first workflow, use the Godot project in the `Godot/` folder.

## Current scope

The Godot project is an early playable foundation: third-person movement, camera control, touch movement/jump buttons, a simple 3D test island and collision. It is not a finished game and does not yet contain detailed environment art, missions, saves or multiplayer.
