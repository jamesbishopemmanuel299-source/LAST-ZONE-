#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "LastZonePatrolScout.generated.h"

UCLASS()
class LASTZONE_API ALastZonePatrolScout : public AActor
{
    GENERATED_BODY()
public:
    ALastZonePatrolScout();
    virtual void Tick(float DeltaSeconds) override;
protected:
    virtual void BeginPlay() override;
private:
    UPROPERTY()
    class UStaticMeshComponent* ScoutMesh;
    FVector Origin;
    float PatrolPhase = 0.f;
    bool bWasAlerted = false;
    void UpdatePatrol(float DeltaSeconds);
    void CheckForPlayer();
};