#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "LastZoneArsenalComponent.generated.h"

UENUM(BlueprintType)
enum class ELastZoneWeaponClass : uint8
{
    PulseSMG,
    ArcRifle,
    NovaCarbine,
    CometLauncher,
    PrismMarksman,
    RiftShotcaster,
    SentinelSidearm,
    VortexCannon,
    EchoRepeater,
    SolarBurst
};

USTRUCT(BlueprintType)
struct FLastZoneWeaponData
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadOnly) FName Id = NAME_None;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FText DisplayName;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FText VisualDesign;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) FName Rarity = FName("Common");
    UPROPERTY(EditAnywhere, BlueprintReadOnly) ELastZoneWeaponClass WeaponClass = ELastZoneWeaponClass::PulseSMG;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) float GameDamage = 18.f;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) float Cooldown = 0.16f;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 MagazineSize = 30;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) int32 ReserveAmmo = 120;
    UPROPERTY(EditAnywhere, BlueprintReadOnly) float Range = 9000.f;
};

UCLASS(ClassGroup=(LastZone), meta=(BlueprintSpawnableComponent))
class LASTZONE_API ULastZoneArsenalComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    ULastZoneArsenalComponent();
    virtual void BeginPlay() override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Arsenal")
    TArray<FLastZoneWeaponData> Arsenal;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Arsenal")
    int32 EquippedIndex = 0;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Arsenal")
    int32 AmmoInMagazine = 0;

    UFUNCTION(BlueprintCallable, Category="Arsenal") void EquipNext();
    UFUNCTION(BlueprintCallable, Category="Arsenal") void EquipPrevious();
    UFUNCTION(BlueprintCallable, Category="Arsenal") void ReloadArcadeWeapon();
    UFUNCTION(BlueprintCallable, Category="Arsenal") void FireArcadePulse();
    UFUNCTION(BlueprintPure, Category="Arsenal") FLastZoneWeaponData GetEquippedWeapon() const;

private:
    float LastPulseTime = -1000.f;
    void BuildArsenal();
};