#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "LastZoneCharacter.generated.h"

UCLASS()
class LASTZONE_API ALastZoneCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    ALastZoneCharacter();
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

    void AddSupply(int32 Amount);
    void ActivateRescueBeacon();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Progress")
    int32 SuppliesCollected = 0;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Progress")
    bool bRescueBeaconActivated = false;

private:
    void MoveForward(float Value);
    void MoveRight(float Value);
    void Turn(float Value);
    void LookUp(float Value);
    void Interact();
};