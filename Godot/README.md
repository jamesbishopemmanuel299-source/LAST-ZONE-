# LAST-ZONE — Android-first C++ exploration prototype

The Godot project is the phone-first playable path. The Unreal Engine C++ project remains in the repository root.

## Current prototype upgrade
- Camera-relative third-person movement, jump and hold-to-sprint.
- Touch movement pad, jump and sprint controls; drag the right side to look around.
- Procedurally generated island scenery: ranger cabins, lookout tower, forest, rocks, marked trails and a glowing navigation beacon.
- On-screen objective and control HUD.
- Godot Mobile renderer, atmospheric fog and a bounded shadow distance to keep the scene suitable for Android.

## Run and build
1. Build the Android ARM64 GDExtension with the GitHub Actions workflow.
2. Download and extract the debug/release libraries from the `last-zone-android-arm64` artifact into `Godot/bin/`.
3. Open `Godot/project.godot` in Godot 4.4 or newer and run the project.
4. To export an APK, install the matching Godot export templates, configure an Android ARM64 export preset, and export a debug APK.

The workflow compiles the C++ extension only; it does not itself export a complete APK. For an Android-only workflow, use Godot Editor for Android and its documented Android export setup.

## Performance notes
The island is built from primitive meshes and does not require large downloaded assets. Keep shadows limited, avoid expensive transparent effects, and profile on the target phone before increasing scene density. Godot recommends choosing the Mobile renderer for newer mobile GPUs and Compatibility for older devices that need broader support.

## Scope
This is an exploration and navigation prototype. It does not yet include finished art assets, save data, or a production online matchmaking service.
