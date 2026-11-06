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
                      float Cooldown, int32 Magazine, int32 Reserve, float Range)
    {
        FLastZoneWeaponData Item;
        Item.Id = Id;
        Item.DisplayName = FText::FromString(Name);
        Item.WeaponClass = Class;
        Item.GameDamage = Damage;
        Item.Cooldown = Cooldown;
        Item.MagazineSize = Magazine;
        Item.ReserveAmmo = Reserve;
        Item.Range = Range;
        Arsenal.Add(Item);
    };

    Add("pulse_smg", TEXT("Pulse SMG"), ELastZoneWeaponClass::PulseSMG, 12.f, .09f, 36, 180, 6500.f);
    Add("arc_rifle", TEXT("Arc Rifle"), ELastZoneWeaponClass::ArcRifle, 24.f, .22f, 28, 140, 9000.f);
    Add("nova_carbine", TEXT("Nova Carbine"), ELastZoneWeaponClass::NovaCarbine, 20.f, .15f, 32, 160, 8500.f);
    Add("comet_launcher", TEXT("Comet Launcher"), ELastZoneWeaponClass::CometLauncher, 70.f, .9f, 5, 25, 5000.f);
    Add("prism_marksman", TEXT("Prism Marksman"), ELastZoneWeaponClass::PrismMarksman, 48.f, .55f, 10, 60, 12000.f);
    Add("rift_shotcaster", TEXT("Rift Shotcaster"), ELastZoneWeaponClass::RiftShotcaster, 9.f, .65f, 8, 48, 2800.f);
    Add("sentinel_sidearm", TEXT("Sentinel Sidearm"), ELastZoneWeaponClass::SentinelSidearm, 16.f, .2f, 15, 90, 5000.f);
    Add("vortex_cannon", TEXT("Vortex Cannon"), ELastZoneWeaponClass::VortexCannon, 42.f, .48f, 12, 72, 7500.f);
    Add("echo_repeater", TEXT("Echo Repeater"), ELastZoneWeaponClass::EchoRepeater, 14.f, .12f, 40, 200, 7000.f);
    Add("solar_burst", TEXT("Solar Burst"), ELastZoneWeaponClass::SolarBurst, 30.f, .35f, 20, 100, 8000.f);
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
    UGameplayStatics::PlaySound2D(this, nullptr);
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