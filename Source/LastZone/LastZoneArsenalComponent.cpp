#include "LastZoneArsenalComponent.h"
#include "GameFramework/Character.h"
#include "GameFramework/Controller.h"
#include "Kismet/GameplayStatics.h"
#include "Engine/World.h"

ULastZoneArsenalComponent::ULastZoneArsenalComponent()
{
    PrimaryComponentTick.bCanEverTick = false;
}

void ULastZoneArsenalComponent::BeginPlay()
{
    Super::BeginPlay();
    BuildArsenal();
    if (Arsenal.Num() > 0) AmmoInMagazine = Arsenal[0].MagazineSize;
}

void ULastZoneArsenalComponent::BuildArsenal()
{
    Arsenal.Reset();
    auto Add = [this](FName Id, const TCHAR* Name, ELastZoneWeaponClass Class, float Damage,
                      float Cooldown, int32 Magazine, int32 Reserve, float Range,
                      const TCHAR* Design, const TCHAR* Rarity)
    {
        FLastZoneWeaponData Item;
        Item.Id = Id;
        Item.DisplayName = FText::FromString(Name);
        Item.VisualDesign = FText::FromString(Design);
        Item.Rarity = FName(Rarity);
        Item.WeaponClass = Class;
        Item.GameDamage = Damage;
        Item.Cooldown = Cooldown;
        Item.MagazineSize = Magazine;
        Item.ReserveAmmo = Reserve;
        Item.Range = Range;
        Arsenal.Add(Item);
    };

    Add("kestrel_9", TEXT("Kestrel-9"), ELastZoneWeaponClass::PulseSMG, 10.f, 0.09f, 34, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; cyan accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("razor_finch", TEXT("Razor Finch"), ELastZoneWeaponClass::PulseSMG, 12.f, 0.09f, 36, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; amber accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("static_moth", TEXT("Static Moth"), ELastZoneWeaponClass::PulseSMG, 14.f, 0.09f, 38, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; violet accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("blue_comet", TEXT("Blue Comet"), ELastZoneWeaponClass::PulseSMG, 16.f, 0.09f, 34, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; crimson accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("night_circuit", TEXT("Night Circuit"), ELastZoneWeaponClass::PulseSMG, 10.f, 0.09f, 36, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; teal accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("volt_wisp", TEXT("Volt Wisp"), ELastZoneWeaponClass::PulseSMG, 12.f, 0.09f, 38, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; silver accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("ghost_current", TEXT("Ghost Current"), ELastZoneWeaponClass::PulseSMG, 14.f, 0.09f, 34, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; cyan accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("neon_jackal", TEXT("Neon Jackal"), ELastZoneWeaponClass::PulseSMG, 16.f, 0.09f, 36, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; amber accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("rapid_halo", TEXT("Rapid Halo"), ELastZoneWeaponClass::PulseSMG, 10.f, 0.09f, 38, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; violet accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("ion_cricket", TEXT("Ion Cricket"), ELastZoneWeaponClass::PulseSMG, 12.f, 0.09f, 34, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; crimson accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("flash_lynx", TEXT("Flash Lynx"), ELastZoneWeaponClass::PulseSMG, 14.f, 0.09f, 36, 180, 6500.f, TEXT("Compact game-stylized close-range silhouette; rounded shell, oversized energy cell and cyan status lights; teal accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("thunder_loom", TEXT("Thunder Loom"), ELastZoneWeaponClass::ArcRifle, 22.f, 0.22f, 26, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; cyan accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("stormglass", TEXT("Stormglass"), ELastZoneWeaponClass::ArcRifle, 24.f, 0.22f, 28, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; amber accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("arc_monarch", TEXT("Arc Monarch"), ELastZoneWeaponClass::ArcRifle, 26.f, 0.22f, 30, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; violet accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("skybreaker", TEXT("Skybreaker"), ELastZoneWeaponClass::ArcRifle, 28.f, 0.22f, 26, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; crimson accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("blue_tempest", TEXT("Blue Tempest"), ELastZoneWeaponClass::ArcRifle, 22.f, 0.22f, 28, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; teal accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("ion_crown", TEXT("Ion Crown"), ELastZoneWeaponClass::ArcRifle, 24.f, 0.22f, 30, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; silver accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("cloud_ripper", TEXT("Cloud Ripper"), ELastZoneWeaponClass::ArcRifle, 26.f, 0.22f, 26, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; cyan accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("tesla_bloom", TEXT("Tesla Bloom"), ELastZoneWeaponClass::ArcRifle, 28.f, 0.22f, 28, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; amber accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("storm_herald", TEXT("Storm Herald"), ELastZoneWeaponClass::ArcRifle, 22.f, 0.22f, 30, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; violet accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("aether_lance", TEXT("Aether Lance"), ELastZoneWeaponClass::ArcRifle, 24.f, 0.22f, 26, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; crimson accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("voltage_warden", TEXT("Voltage Warden"), ELastZoneWeaponClass::ArcRifle, 26.f, 0.22f, 28, 140, 9000.f, TEXT("Fictional modern service-rifle silhouette; angular panels and luminous blue power spine; teal accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("nova_viper", TEXT("Nova Viper"), ELastZoneWeaponClass::NovaCarbine, 18.f, 0.15f, 30, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; cyan accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("dawnstrike", TEXT("Dawnstrike"), ELastZoneWeaponClass::NovaCarbine, 20.f, 0.15f, 32, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; amber accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("emberline", TEXT("Emberline"), ELastZoneWeaponClass::NovaCarbine, 22.f, 0.15f, 34, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; violet accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("solar_jackal", TEXT("Solar Jackal"), ELastZoneWeaponClass::NovaCarbine, 24.f, 0.15f, 30, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; crimson accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("aurora_7", TEXT("Aurora-7"), ELastZoneWeaponClass::NovaCarbine, 18.f, 0.15f, 32, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; teal accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("starling_core", TEXT("Starling Core"), ELastZoneWeaponClass::NovaCarbine, 20.f, 0.15f, 34, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; silver accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("radiant_fang", TEXT("Radiant Fang"), ELastZoneWeaponClass::NovaCarbine, 22.f, 0.15f, 30, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; cyan accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("helio_drift", TEXT("Helio Drift"), ELastZoneWeaponClass::NovaCarbine, 24.f, 0.15f, 32, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; amber accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("sunforge", TEXT("Sunforge"), ELastZoneWeaponClass::NovaCarbine, 18.f, 0.15f, 34, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; violet accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("daybreak_vector", TEXT("Daybreak Vector"), ELastZoneWeaponClass::NovaCarbine, 20.f, 0.15f, 30, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; crimson accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("brightfall", TEXT("Brightfall"), ELastZoneWeaponClass::NovaCarbine, 22.f, 0.15f, 32, 160, 8500.f, TEXT("Streamlined futuristic carbine silhouette; warm orange accents and glowing side chamber; teal accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("meteor_choir", TEXT("Meteor Choir"), ELastZoneWeaponClass::CometLauncher, 68.f, 0.90f, 3, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; cyan accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("orbit_hammer", TEXT("Orbit Hammer"), ELastZoneWeaponClass::CometLauncher, 70.f, 0.90f, 5, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; amber accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("crater_king", TEXT("Crater King"), ELastZoneWeaponClass::CometLauncher, 72.f, 0.90f, 7, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; violet accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("asteroid_bloom", TEXT("Asteroid Bloom"), ELastZoneWeaponClass::CometLauncher, 74.f, 0.90f, 3, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; crimson accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("skyfall_engine", TEXT("Skyfall Engine"), ELastZoneWeaponClass::CometLauncher, 68.f, 0.90f, 5, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; teal accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("gravity_bell", TEXT("Gravity Bell"), ELastZoneWeaponClass::CometLauncher, 70.f, 0.90f, 7, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; silver accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("comet_shepherd", TEXT("Comet Shepherd"), ELastZoneWeaponClass::CometLauncher, 72.f, 0.90f, 3, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; cyan accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("impact_halo", TEXT("Impact Halo"), ELastZoneWeaponClass::CometLauncher, 74.f, 0.90f, 5, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; amber accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("red_giant", TEXT("Red Giant"), ELastZoneWeaponClass::CometLauncher, 68.f, 0.90f, 7, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; violet accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("moonquake", TEXT("Moonquake"), ELastZoneWeaponClass::CometLauncher, 70.f, 0.90f, 3, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; crimson accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("star_crusher", TEXT("Star Crusher"), ELastZoneWeaponClass::CometLauncher, 72.f, 0.90f, 5, 25, 5000.f, TEXT("Chunky sci-fi launcher silhouette; fictional energy pod, broad casing and bright decals; teal accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("glass_horizon", TEXT("Glass Horizon"), ELastZoneWeaponClass::PrismMarksman, 46.f, 0.55f, 8, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; cyan accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("longview_spectre", TEXT("Longview Spectre"), ELastZoneWeaponClass::PrismMarksman, 48.f, 0.55f, 10, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; amber accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("mirage_needle", TEXT("Mirage Needle"), ELastZoneWeaponClass::PrismMarksman, 50.f, 0.55f, 12, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; violet accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("frost_meridian", TEXT("Frost Meridian"), ELastZoneWeaponClass::PrismMarksman, 52.f, 0.55f, 8, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; crimson accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("quiet_zenith", TEXT("Quiet Zenith"), ELastZoneWeaponClass::PrismMarksman, 46.f, 0.55f, 10, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; teal accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("farstar", TEXT("Farstar"), ELastZoneWeaponClass::PrismMarksman, 48.f, 0.55f, 12, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; silver accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("crystal_watch", TEXT("Crystal Watch"), ELastZoneWeaponClass::PrismMarksman, 50.f, 0.55f, 8, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; cyan accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("blue_distant", TEXT("Blue Distant"), ELastZoneWeaponClass::PrismMarksman, 52.f, 0.55f, 10, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; amber accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("hollow_peak", TEXT("Hollow Peak"), ELastZoneWeaponClass::PrismMarksman, 46.f, 0.55f, 12, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; violet accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("polar_sight", TEXT("Polar Sight"), ELastZoneWeaponClass::PrismMarksman, 48.f, 0.55f, 8, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; crimson accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("duskline", TEXT("Duskline"), ELastZoneWeaponClass::PrismMarksman, 50.f, 0.55f, 10, 60, 12000.f, TEXT("Long precision-game silhouette; slim profile, large stylized optic housing and violet crystal detail; teal accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("rift_bloom", TEXT("Rift Bloom"), ELastZoneWeaponClass::RiftShotcaster, 7.f, 0.65f, 6, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; cyan accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("shatterwave", TEXT("Shatterwave"), ELastZoneWeaponClass::RiftShotcaster, 9.f, 0.65f, 8, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; amber accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("echo_scatter", TEXT("Echo Scatter"), ELastZoneWeaponClass::RiftShotcaster, 11.f, 0.65f, 10, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; violet accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("void_petal", TEXT("Void Petal"), ELastZoneWeaponClass::RiftShotcaster, 13.f, 0.65f, 6, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; crimson accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("phase_burst", TEXT("Phase Burst"), ELastZoneWeaponClass::RiftShotcaster, 7.f, 0.65f, 8, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; teal accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("glitch_garden", TEXT("Glitch Garden"), ELastZoneWeaponClass::RiftShotcaster, 9.f, 0.65f, 10, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; silver accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("rift_rattle", TEXT("Rift Rattle"), ELastZoneWeaponClass::RiftShotcaster, 11.f, 0.65f, 6, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; cyan accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("warp_blossom", TEXT("Warp Blossom"), ELastZoneWeaponClass::RiftShotcaster, 13.f, 0.65f, 8, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; amber accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("prism_scatter", TEXT("Prism Scatter"), ELastZoneWeaponClass::RiftShotcaster, 7.f, 0.65f, 10, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; violet accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("quasar_bloom", TEXT("Quasar Bloom"), ELastZoneWeaponClass::RiftShotcaster, 9.f, 0.65f, 6, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; crimson accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("dimensional_rain", TEXT("Dimensional Rain"), ELastZoneWeaponClass::RiftShotcaster, 11.f, 0.65f, 8, 48, 2800.f, TEXT("Wide futuristic scatter-caster silhouette; faceted shroud, twin glowing vents and compact stock; teal accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("pocket_sentinel", TEXT("Pocket Sentinel"), ELastZoneWeaponClass::SentinelSidearm, 14.f, 0.20f, 13, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; cyan accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("nova_flicker", TEXT("Nova Flicker"), ELastZoneWeaponClass::SentinelSidearm, 16.f, 0.20f, 15, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; amber accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("silver_finch", TEXT("Silver Finch"), ELastZoneWeaponClass::SentinelSidearm, 18.f, 0.20f, 17, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; violet accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("orbit_spark", TEXT("Orbit Spark"), ELastZoneWeaponClass::SentinelSidearm, 20.f, 0.20f, 13, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; crimson accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("warden_2", TEXT("Warden-2"), ELastZoneWeaponClass::SentinelSidearm, 14.f, 0.20f, 15, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; teal accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("little_eclipse", TEXT("Little Eclipse"), ELastZoneWeaponClass::SentinelSidearm, 16.f, 0.20f, 17, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; silver accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("pulse_whisper", TEXT("Pulse Whisper"), ELastZoneWeaponClass::SentinelSidearm, 18.f, 0.20f, 13, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; cyan accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("comet_pin", TEXT("Comet Pin"), ELastZoneWeaponClass::SentinelSidearm, 20.f, 0.20f, 15, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; amber accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("astra_compact", TEXT("Astra Compact"), ELastZoneWeaponClass::SentinelSidearm, 14.f, 0.20f, 17, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; violet accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("echo_guard", TEXT("Echo Guard"), ELastZoneWeaponClass::SentinelSidearm, 16.f, 0.20f, 13, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; crimson accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("bright_signal", TEXT("Bright Signal"), ELastZoneWeaponClass::SentinelSidearm, 18.f, 0.20f, 15, 90, 5000.f, TEXT("Small fictional sidearm silhouette; smooth grip, bright energy indicator and polished silver trim; teal accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("maelstrom_core", TEXT("Maelstrom Core"), ELastZoneWeaponClass::VortexCannon, 40.f, 0.48f, 10, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; cyan accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("gravity_maw", TEXT("Gravity Maw"), ELastZoneWeaponClass::VortexCannon, 42.f, 0.48f, 12, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; amber accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("cyclone_heart", TEXT("Cyclone Heart"), ELastZoneWeaponClass::VortexCannon, 44.f, 0.48f, 14, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; violet accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("vortex_crown", TEXT("Vortex Crown"), ELastZoneWeaponClass::VortexCannon, 46.f, 0.48f, 10, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; crimson accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("blue_whirlpool", TEXT("Blue Whirlpool"), ELastZoneWeaponClass::VortexCannon, 40.f, 0.48f, 12, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; teal accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("singularity_drum", TEXT("Singularity Drum"), ELastZoneWeaponClass::VortexCannon, 42.f, 0.48f, 14, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; silver accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("abyss_engine", TEXT("Abyss Engine"), ELastZoneWeaponClass::VortexCannon, 44.f, 0.48f, 10, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; cyan accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("tempest_coil", TEXT("Tempest Coil"), ELastZoneWeaponClass::VortexCannon, 46.f, 0.48f, 12, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; amber accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("void_current", TEXT("Void Current"), ELastZoneWeaponClass::VortexCannon, 40.f, 0.48f, 14, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; violet accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("tidal_reactor", TEXT("Tidal Reactor"), ELastZoneWeaponClass::VortexCannon, 42.f, 0.48f, 10, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; crimson accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("spiral_titan", TEXT("Spiral Titan"), ELastZoneWeaponClass::VortexCannon, 44.f, 0.48f, 12, 72, 7500.f, TEXT("Heavy energy-cannon silhouette; broad frame, circular vortex chamber and animated teal light rings; teal accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("echo_runner", TEXT("Echo Runner"), ELastZoneWeaponClass::EchoRepeater, 12.f, 0.12f, 38, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; cyan accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("twinwave", TEXT("Twinwave"), ELastZoneWeaponClass::EchoRepeater, 14.f, 0.12f, 40, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; amber accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("repeat_halo", TEXT("Repeat Halo"), ELastZoneWeaponClass::EchoRepeater, 16.f, 0.12f, 42, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; violet accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("resonance_5", TEXT("Resonance-5"), ELastZoneWeaponClass::EchoRepeater, 18.f, 0.12f, 38, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; crimson accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("soundless_loop", TEXT("Soundless Loop"), ELastZoneWeaponClass::EchoRepeater, 12.f, 0.12f, 40, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; teal accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("pulse_parrot", TEXT("Pulse Parrot"), ELastZoneWeaponClass::EchoRepeater, 14.f, 0.12f, 42, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; silver accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("afterglow", TEXT("Afterglow"), ELastZoneWeaponClass::EchoRepeater, 16.f, 0.12f, 38, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; cyan accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("reverb_fox", TEXT("Reverb Fox"), ELastZoneWeaponClass::EchoRepeater, 18.f, 0.12f, 40, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; amber accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("wave_circuit", TEXT("Wave Circuit"), ELastZoneWeaponClass::EchoRepeater, 12.f, 0.12f, 42, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; violet accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("signal_drift", TEXT("Signal Drift"), ELastZoneWeaponClass::EchoRepeater, 14.f, 0.12f, 38, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; crimson accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("harmonic_rush", TEXT("Harmonic Rush"), ELastZoneWeaponClass::EchoRepeater, 16.f, 0.12f, 40, 200, 7000.f, TEXT("Retro-futurist repeater silhouette; rounded casing, repeating light bars and yellow accent stripe; teal accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("sunflare", TEXT("Sunflare"), ELastZoneWeaponClass::SolarBurst, 28.f, 0.35f, 18, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; cyan accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("solar_choir", TEXT("Solar Choir"), ELastZoneWeaponClass::SolarBurst, 30.f, 0.35f, 20, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; amber accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("radiant_bloom", TEXT("Radiant Bloom"), ELastZoneWeaponClass::SolarBurst, 32.f, 0.35f, 22, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; violet accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("daystar_pulse", TEXT("Daystar Pulse"), ELastZoneWeaponClass::SolarBurst, 34.f, 0.35f, 18, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; crimson accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("golden_circuit", TEXT("Golden Circuit"), ELastZoneWeaponClass::SolarBurst, 28.f, 0.35f, 20, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; teal accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
    Add("corona_bloom", TEXT("Corona Bloom"), ELastZoneWeaponClass::SolarBurst, 30.f, 0.35f, 22, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; silver accent finish; original LAST-ZONE markings"), TEXT("Rare"));
    Add("helios_arc", TEXT("Helios Arc"), ELastZoneWeaponClass::SolarBurst, 32.f, 0.35f, 18, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; cyan accent finish; original LAST-ZONE markings"), TEXT("Epic"));
    Add("sunburst_echo", TEXT("Sunburst Echo"), ELastZoneWeaponClass::SolarBurst, 34.f, 0.35f, 20, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; amber accent finish; original LAST-ZONE markings"), TEXT("Legendary"));
    Add("dawn_engine", TEXT("Dawn Engine"), ELastZoneWeaponClass::SolarBurst, 28.f, 0.35f, 22, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; violet accent finish; original LAST-ZONE markings"), TEXT("Mythic"));
    Add("lightstorm", TEXT("Lightstorm"), ELastZoneWeaponClass::SolarBurst, 30.f, 0.35f, 18, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; crimson accent finish; original LAST-ZONE markings"), TEXT("Common"));
    Add("solar_mirage", TEXT("Solar Mirage"), ELastZoneWeaponClass::SolarBurst, 32.f, 0.35f, 20, 100, 8000.f, TEXT("Elegant burst-energy silhouette; sculpted body, gold edge panels and radiant central core; teal accent finish; original LAST-ZONE markings"), TEXT("Uncommon"));
}

FLastZoneWeaponData ULastZoneArsenalComponent::GetEquippedWeapon() const
{
    return Arsenal.IsValidIndex(EquippedIndex) ? Arsenal[EquippedIndex] : FLastZoneWeaponData();
}

void ULastZoneArsenalComponent::EquipNext()
{
    if (Arsenal.Num() < 1) return;
    EquippedIndex = (EquippedIndex + 1) % Arsenal.Num();
    AmmoInMagazine = Arsenal[EquippedIndex].MagazineSize;
}

void ULastZoneArsenalComponent::EquipPrevious()
{
    if (Arsenal.Num() < 1) return;
    EquippedIndex = (EquippedIndex - 1 + Arsenal.Num()) % Arsenal.Num();
    AmmoInMagazine = Arsenal[EquippedIndex].MagazineSize;
}

void ULastZoneArsenalComponent::ReloadArcadeWeapon()
{
    if (!Arsenal.IsValidIndex(EquippedIndex)) return;
    const FLastZoneWeaponData& Weapon = Arsenal[EquippedIndex];
    const int32 Needed = Weapon.MagazineSize - AmmoInMagazine;
    const int32 Loaded = FMath::Min(Needed, Weapon.ReserveAmmo);
    AmmoInMagazine += Loaded;
    Arsenal[EquippedIndex].ReserveAmmo -= Loaded;
}

void ULastZoneArsenalComponent::FireArcadePulse()
{
    if (!Arsenal.IsValidIndex(EquippedIndex) || AmmoInMagazine <= 0) return;
    const FLastZoneWeaponData& Weapon = Arsenal[EquippedIndex];
    const float Now = GetWorld() ? GetWorld()->GetTimeSeconds() : 0.f;
    if (Now - LastPulseTime < Weapon.Cooldown) return;
    LastPulseTime = Now;
    --AmmoInMagazine;

    ACharacter* Character = Cast<ACharacter>(GetOwner());
    if (!Character || !Character->GetController()) return;

    FVector ViewLocation;
    FRotator ViewRotation;
    Character->GetController()->GetPlayerViewPoint(ViewLocation, ViewRotation);
    const FVector End = ViewLocation + ViewRotation.Vector() * Weapon.Range;
    FHitResult Hit;
    FCollisionQueryParams Params(SCENE_QUERY_STAT(LastZoneArcadePulse), true, Character);
    if (GetWorld()->LineTraceSingleByChannel(Hit, ViewLocation, End, ECC_Visibility, Params))
    {
        AActor* Target = Hit.GetActor();
        if (Target && Target != Character)
        {
            UGameplayStatics::ApplyDamage(Target, Weapon.GameDamage, Character->GetController(),
                                           Character, UDamageType::StaticClass());
        }
    }
}