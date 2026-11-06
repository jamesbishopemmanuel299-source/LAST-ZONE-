# LAST-ZONE — Godot C++ Android prototype

This folder is the Android-first Godot prototype. The existing Unreal Engine project remains in the repository root and is not overwritten.

## Engine and target
- Godot 4.4+ (GDExtension API)
- C++17 via godot-cpp
- Android ARM64
- Third-person exploration prototype
- Mobile renderer with a scalable 3D scene

## Included
- C++ third-person character movement and gravity
- Camera-relative movement
- Right-side touch-drag camera look
- On-screen touch movement and jump buttons
- A 3D test island, player capsule, lighting and collision

## Build the Android C++ extension

The C++ extension must be compiled for Android before the project can load it on an Android device.

1. Push this folder to GitHub.
2. Open the repository Actions tab.
3. Run or wait for the workflow named Build LAST-ZONE Godot Android Extension.
4. Download the artifact named last-zone-android-arm64.
5. Extract both .so files into this folder's bin/ directory.
6. Open Godot/project.godot with Godot Editor for Android.

The workflow builds debug and release ARM64 libraries using the Godot 4.4 godot-cpp bindings. The extension API compatibility minimum is 4.4.

## Export an APK on Android

Install Godot's Android export templates in the editor, create an Android export preset, select ARM64, and export a debug APK for device testing. If using the Gradle export path, install the Godot Android Build Environment (GABE) companion app. GABE handles Gradle export dependencies; it does not compile this C++ extension.

## Limitations

- This is a playable movement/environment foundation, not a finished game.
- The scene uses placeholder geometry; cinematic assets and detailed island terrain are later work.
- The Android C++ library is a separate build artifact. A successful GitHub Actions build is not the same as a complete APK export.
- The Unreal project in the repository root is preserved.
