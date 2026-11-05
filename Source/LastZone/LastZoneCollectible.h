#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "LastZoneCollectible.generated.h"

UCLASS()
class LASTZONE_API ALastZoneCollectible : public AActor
{
    GENERATED_BODY()
public:
    ALastZoneCollectible();
protected:
    virtual void BeginPlay() override;
private:
    UPROPERTY(VisibleAnywhere)
    class USphereComponent* Trigger;
    UPROPERTY(VisibleAnywhere)
    class UStaticMeshComponent* Visual;
    UFUNCTION()
    void OnOverlap(UPrimitiveComponent* Overlapped, AActor* OtherActor,
        UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep,
        const FHitResult& SweepResult);
};