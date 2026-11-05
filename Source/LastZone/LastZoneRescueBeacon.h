#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "LastZoneRescueBeacon.generated.h"

UCLASS()
class LASTZONE_API ALastZoneRescueBeacon : public AActor
{
    GENERATED_BODY()
public:
    ALastZoneRescueBeacon();
    void TryActivate(class ALastZoneCharacter* Player);
private:
    UPROPERTY(VisibleAnywhere)
    class UStaticMeshComponent* Visual;
};