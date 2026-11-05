# LAST ZONE — Android Island Exploration Prototype

An original, non-combat 3D island exploration and rescue game built with Unreal Engine 5 and C++.

## Prototype loop
- Explore a remote island in third person.
- Collect five supply caches.
- Activate the island rescue beacon.
- Use the island's landmarks to navigate the prototype area.

## Current scope
This repository contains the initial C++ source foundation. It has not yet been compiled or packaged as an Android APK. It is a local single-player prototype for movement, camera, pickups, objectives and basic mobile input. It does not include online matchmaking or a 100-player service. Cinematic environment art, final character assets, polished HUD, companion AI and multiplayer services are later milestones.

## Requirements
- Unreal Engine 5.8
- Visual Studio 2022 with the C++ game development workload (Windows)
- Android Studio and the SDK/NDK versions recommended by the installed Unreal Engine release

## Open and run
1. Clone or download this repository.
2. Right-click `LastZone.uproject` and generate IDE project files.
3. Build the `Development Editor` target.
4. Open the project in Unreal Editor.
5. Create and save a level, then press Play.
6. Keyboard test controls: WASD to move, mouse to look, Space to jump, E to interact.

## Android
Use Unreal's Android SDK setup workflow, configure the Android package name, and package from Platforms > Android. Test on a physical device and profile performance before increasing visual quality. Current Google Play target-SDK requirements mean using a recent Unreal release and its supported Android toolchain; see Epic's Android Quick Start documentation.

## Planned milestones
1. Compile and validate the source prototype.
2. Add a designed island landscape, foliage, buildings, weather and cinematic lighting.
3. Add touch HUD, objectives, inventory and accessibility options.
4. Add save data, companion exploration AI and mission progression.
5. Consider optional cooperative networking after the offline game is stable.
