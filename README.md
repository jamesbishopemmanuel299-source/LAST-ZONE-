# LAST ZONE — Android Island Exploration Prototype

An original, non-combat 3D island exploration and rescue game built with Unreal Engine 5 and C++.

## Prototype loop
- Explore a remote island in third person.
- Collect five supply caches.
- Activate the island rescue beacon.
- Stay inside the marked safe exploration area as the environment changes.
- Use AI companion explorers for ambient activity.

## Current scope
This repository is the C++ source foundation. It is not yet a compiled game or Android APK. It does not include online matchmaking or a 100-player service. The initial build is a local single-player prototype designed to establish movement, camera, pickups, objectives and Android input. Cinematic environment art, final character assets, UI polish and multiplayer services are later milestones.

## Requirements
- Unreal Engine 5.5 or newer
- Visual Studio 2022 with C++ game development workload (Windows)
- Android Studio and the SDK/NDK versions recommended for your Unreal Engine version

## Open and run
1. Download/clone the repository.
2. Right-click `LastZone.uproject` and generate IDE project files.
3. Build the `Development Editor` target.
4. Open the project in Unreal Editor.
5. Create a level and set it as the startup map, then press Play.
6. Keyboard testing: WASD to move, mouse to look, Space to jump, E to interact.

## Android
Configure Android SDK/NDK in Unreal's Project Settings and package through Platforms > Android. Test on a physical Android device. Use scalable mobile settings and profile performance on the target device before increasing visual quality.

## Planned milestones
1. Playable exploration prototype (this repository foundation).
2. Island landscape, foliage, buildings, weather and cinematic lighting.
3. Touch HUD, objectives, inventory and accessibility options.
4. Companion AI, save system and mission progression.
5. Optional cooperative networking, only after the offline game is stable.
