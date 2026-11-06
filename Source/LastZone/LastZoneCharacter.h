#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "LastZoneArsenalComponent.h"
#include "LastZoneWeaponVisual.h"
#include "LastZoneInventoryWidget.h"
#include "LastZoneCharacter.generated.h"

UCLASS()
class LASTZONE_API ALastZoneCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    ALastZoneCharacter();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Arsenal")
    TObjectPtr<ULastZoneArsenalComponent> ArsenalComponent;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Arsenal")
    TObjectPtr<ALastZoneWeaponVisual> WeaponVisual;

    UPROPERTY()
    TObjectPtr<ULastZoneInventoryWidget> InventoryWidget;
    virtual void BeginPlay() override;
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;
    void AddSupply(int32 Amount);
    void ActivateRescueBeacon();
    void SetScoutAlert(bool bAlerted);

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Progress")
    int32 SuppliesCollected = 0;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Progress")
    bool bRescueBeaconActivated = false;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Stealth")
    bool bStealthMode = false;

private:
    void MoveForward(float Value);
    void MoveRight(float Value);
    void Turn(float Value);
    void LookUp(float Value);
    void Interact();
    void FireWeapon();
    void ReloadWeapon();
    void NextWeapon();
    void PreviousWeapon();
    void StartSprint();
    void StopSprint();
    void ToggleStealth();
    float NormalWalkSpeed = 480.f;
    float SprintWalkSpeed = 720.f;
    float StealthWalkSpeed = 220.f;
};